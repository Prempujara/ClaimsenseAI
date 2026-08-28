"""
ocr.py
------
Real OCR extraction for uploaded receipts using Tesseract (via pytesseract).

- Images (jpg/jpeg/png): read with Pillow and OCR directly.
- PDFs: try the embedded text layer first (PyMuPDF); if the PDF is a scanned
  image with no text, render each page to an image and OCR that.

After extracting raw text we pull out three fields with regex heuristics:
    merchant  - best-guess vendor name (usually near the top of the receipt)
    amount    - the total amount (prefers lines mentioning total/grand/amount)
    date      - first recognisable date string

Nothing is faked: if Tesseract or a dependency is missing, the caller gets a
clear error and the app degrades gracefully.
"""

import io
import os
import re

import pytesseract
from PIL import Image

# On Windows the tesseract binary is not on PATH by default. Point at the
# standard install location, but allow override via the TESSERACT_CMD env var.
_DEFAULT_WIN_TESSERACT = r"C:\Program Files\Tesseract-OCR\tesseract.exe"
_cmd = os.environ.get("TESSERACT_CMD")
if _cmd:
    pytesseract.pytesseract.tesseract_cmd = _cmd
elif os.path.exists(_DEFAULT_WIN_TESSERACT):
    pytesseract.pytesseract.tesseract_cmd = _DEFAULT_WIN_TESSERACT


# ------- amount / date extraction regexes -------

# 1,234.56  |  1234  |  1,23,456.00  (Indian grouping tolerated)
_NUM = r"(?:\d{1,3}(?:[,\d]{0,12})(?:\.\d{1,2})?)"
_AMOUNT_LINE = re.compile(
    r"(total|grand\s*total|amount\s*(?:payable|due)?|net\s*amount|balance)\D{0,15}("
    + _NUM + r")", re.IGNORECASE)
_ANY_MONEY = re.compile(r"(?:₹|rs\.?|inr)\s*(" + _NUM + r")", re.IGNORECASE)
_BARE_NUM = re.compile(_NUM)

_DATE = re.compile(
    r"(\d{1,2}[/\-.]\d{1,2}[/\-.]\d{2,4}"          # 12/08/2026, 12-8-26
    r"|\d{4}[/\-.]\d{1,2}[/\-.]\d{1,2}"            # 2026-08-12
    r"|\d{1,2}\s+[A-Za-z]{3,9}\s+\d{2,4}"          # 12 Aug 2026
    r"|[A-Za-z]{3,9}\s+\d{1,2},?\s+\d{2,4})"       # Aug 12, 2026
)


def _to_float(s):
    try:
        return float(s.replace(",", ""))
    except ValueError:
        return None


def _extract_amount(text):
    # Prefer a number explicitly labelled as a total.
    best = None
    for m in _AMOUNT_LINE.finditer(text):
        val = _to_float(m.group(2))
        if val is not None:
            best = val if best is None else max(best, val)
    if best is not None:
        return best
    # Next, any currency-prefixed number.
    money = [_to_float(m.group(1)) for m in _ANY_MONEY.finditer(text)]
    money = [m for m in money if m is not None]
    if money:
        return max(money)
    # Fall back to the largest plausible bare number on the receipt.
    nums = [_to_float(m.group(0)) for m in _BARE_NUM.finditer(text)]
    nums = [n for n in nums if n is not None and n >= 1]
    return max(nums) if nums else None


def _extract_date(text):
    m = _DATE.search(text)
    return m.group(1).strip() if m else None


def _extract_merchant(text):
    # Heuristic: first non-trivial line with letters is usually the store name.
    for line in text.splitlines():
        s = line.strip()
        if len(s) >= 3 and re.search(r"[A-Za-z]", s):
            # skip lines that are obviously headings for totals/receipts
            if re.search(r"(receipt|invoice|tax|gst|bill\s*no)", s, re.IGNORECASE):
                continue
            return s[:120]
    return None


def _ocr_image(image_bytes):
    img = Image.open(io.BytesIO(image_bytes))
    if img.mode not in ("L", "RGB"):
        img = img.convert("RGB")
    return pytesseract.image_to_string(img)


def _ocr_pdf(pdf_bytes):
    try:
        import pymupdf as fitz          # PyMuPDF >= 1.24 preferred import
    except ImportError:
        import fitz                     # older PyMuPDF fallback
    doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    try:
        # 1) Try the embedded text layer (fast, exact for digital PDFs).
        parts = [page.get_text() for page in doc]
        text = "\n".join(parts).strip()
        if len(text) >= 12:
            return text, "pdf-text"
        # 2) Scanned PDF -> render pages and OCR them.
        ocr_parts = []
        for page in doc:
            pix = page.get_pixmap(dpi=200)
            ocr_parts.append(_ocr_image(pix.tobytes("png")))
        return "\n".join(ocr_parts).strip(), "tesseract(pdf-render)"
    finally:
        doc.close()


def extract(image_bytes, filename):
    """
    Run OCR and field extraction.

    Returns a dict:
        {success, text, merchant, amount, date, engine, error}
    """
    ext = (filename or "").lower().rsplit(".", 1)[-1] if "." in (filename or "") else ""
    try:
        if ext == "pdf":
            text, engine = _ocr_pdf(image_bytes)
        else:
            text, engine = _ocr_image(image_bytes), "tesseract"
    except pytesseract.TesseractNotFoundError:
        return {"success": False, "text": "", "merchant": None, "amount": None,
                "date": None, "engine": None,
                "error": "Tesseract OCR engine not found on the server."}
    except Exception as e:  # noqa: BLE001 - report any decode/render failure cleanly
        return {"success": False, "text": "", "merchant": None, "amount": None,
                "date": None, "engine": None, "error": f"OCR failed: {e}"}

    text = text or ""
    ok = len(text.strip()) > 0
    return {
        "success": ok,
        "text": text,
        "merchant": _extract_merchant(text) if ok else None,
        "amount": _extract_amount(text) if ok else None,
        "date": _extract_date(text) if ok else None,
        "engine": engine,
        "error": None if ok else "No readable text detected in the receipt.",
    }
