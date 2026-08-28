"""
app.py
------
ClaimSense AI - Python inference service.

A small Flask app that the Java/Tomcat backend calls over HTTP for the three
AI capabilities. It is intentionally framework-light and runs locally (no paid
external API):

    GET  /health   -> {"status":"ok"}
    POST /ocr      -> real Tesseract OCR + field extraction
    POST /predict  -> TF-IDF + LogisticRegression category prediction
    POST /anomaly  -> IsolationForest amount anomaly detection

The JSON request/response shapes match service.AIService on the Java side
exactly. Run with:

    python app.py            # serves on http://localhost:5000

Nothing here fabricates results: if the ML model has not been trained yet, or
Tesseract is not installed, the affected endpoint returns a clear, honest
payload and the Java layer degrades gracefully.
"""

import base64
import logging

from flask import Flask, jsonify, request

import anomaly
import ocr
import predict as predictor

logging.basicConfig(level=logging.INFO)
LOG = logging.getLogger("claimsense.ml")

app = Flask(__name__)


@app.get("/health")
def health():
    return jsonify({"status": "ok"})


@app.post("/ocr")
def ocr_endpoint():
    data = request.get_json(silent=True) or {}
    filename = data.get("filename") or "receipt"
    b64 = data.get("content_base64") or ""
    if not b64:
        return jsonify({
            "success": False, "text": "", "merchant": None, "amount": None,
            "date": None, "engine": None, "error": "No file content received.",
        })
    try:
        file_bytes = base64.b64decode(b64)
    except Exception as e:  # noqa: BLE001
        return jsonify({
            "success": False, "text": "", "merchant": None, "amount": None,
            "date": None, "engine": None,
            "error": f"Could not decode file content: {e}",
        })

    result = ocr.extract(file_bytes, filename)
    LOG.info("OCR %s -> success=%s engine=%s amount=%s",
             filename, result.get("success"), result.get("engine"),
             result.get("amount"))
    return jsonify(result)


@app.post("/predict")
def predict_endpoint():
    data = request.get_json(silent=True) or {}
    merchant = (data.get("merchant") or "").strip()
    description = (data.get("description") or "").strip()

    # Build the same "merchant + description" text the model was trained on.
    text = (merchant + " " + description).strip()
    if not text:
        return jsonify({"category": None, "confidence": 0.0,
                        "error": "No text to classify."}), 200
    try:
        category, confidence = predictor.predict(text)
        return jsonify({"category": category, "confidence": confidence})
    except FileNotFoundError as e:
        # Model not trained yet - be honest, don't invent a category.
        LOG.warning("Predict unavailable: %s", e)
        return jsonify({"category": None, "confidence": 0.0,
                        "error": str(e)}), 503
    except Exception as e:  # noqa: BLE001
        LOG.exception("Predict failed")
        return jsonify({"category": None, "confidence": 0.0,
                        "error": f"Prediction failed: {e}"}), 500


@app.post("/anomaly")
def anomaly_endpoint():
    data = request.get_json(silent=True) or {}
    amount = data.get("amount", 0)
    category = data.get("category") or ""
    history = data.get("history") or []
    try:
        result = anomaly.detect(amount, category, history)
        return jsonify(result)
    except Exception as e:  # noqa: BLE001
        LOG.exception("Anomaly detection failed")
        return jsonify({"status": "INSUFFICIENT DATA", "score": None,
                        "message": "Insufficient data for anomaly analysis",
                        "error": str(e)}), 200


if __name__ == "__main__":
    # threaded=True so OCR (slow) doesn't block predict/anomaly calls.
    app.run(host="0.0.0.0", port=5000, debug=False, threaded=True)
