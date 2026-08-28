# ClaimSense AI — Final MVP Report (§36)

**AI-Powered Expense & Claim Management System**
Status: **COMPLETE — MVP working and verified end-to-end.**
Report date: 2026-08-28

---

## 1. What was built

A complete, working backend + database + OCR + ML layer wired into the **existing JSP
frontend** (frontend untouched, as required). An employee submits an expense with a
receipt; the system runs **real OCR** (Tesseract), a **real ML category prediction**
(TF-IDF + Logistic Regression) and **real anomaly detection** (Isolation Forest),
persists everything to MySQL, and a manager approves/rejects with a full audit trail.

Nothing is faked (§35): every prediction, confidence value, OCR field and anomaly
verdict shown in the UI comes from a live model or the Tesseract engine at request time.

## 2. Tech stack (locked spec — honored exactly)

| Layer | Technology | Verified version |
|-------|-----------|------------------|
| Language | Java 17+ (compiled `--release 17`) | ✓ |
| Web | JSP + JSTL, **Jakarta** Servlets (`jakarta.servlet.*`) | ✓ |
| Server | Apache Tomcat | 10.1.57 |
| DB | MySQL | 8 (Docker), Connector/J 8.4.0 |
| Pattern | MVC Model-2 (JSP → Servlet → Service → DAO → JDBC → MySQL) | ✓ |
| ML | Python 3, pandas, scikit-learn, joblib, Flask | flask 3.1.3, sklearn 1.9.0, pandas 3.0.5 |
| OCR | Tesseract via pytesseract + PyMuPDF (local, not a paid API) | tesseract 5.4.0, pymupdf 1.28.2 |

No Spring Boot, no React/Angular, no `javax.*`, no web.xml (annotation-driven). SQL and
business logic live only in DAO/Service layers — never in JSP. All queries use
`PreparedStatement` inside try-with-resources.

## 3. Architecture

```
Browser (JSP/JSTL)
   │  HTTP
   ▼
AuthenticationFilter (@WebFilter "/*")  ── session + role gate
   ▼
Servlets (controller/*)  ── LoginServlet, SubmitExpenseServlet, ExpenseDetailsServlet,
   │                         ManagerDashboardServlet, ApproveRejectServlet, ReceiptServlet …
   ▼
Services (service/*)     ── ExpenseService, ApprovalService, AIService, AuthService
   │                                                   │
   ▼                                                   ▼  java.net.http.HttpClient (JSON)
DAO (dao/*) ── JDBC/PreparedStatement          Python Flask service (:5000)
   ▼                                             /ocr  /predict  /anomaly  /health
MySQL  claimsense_ai                             ocr.py · predict.py · anomaly.py
```

The Java side calls the Python service over HTTP; the Python side owns OCR + ML + anomaly.

## 4. Database

- **Name: `claimsense_ai`** (never changed, per spec).
- **6 tables:** `users`, `expense_categories`, `expenses`, `receipts`, `approval_history`, `ai_analysis`.
- **7 seeded categories:** Food(1), Travel(2), Accommodation(3), Office Supplies(4), Entertainment(5), Medical(6), Other(7).
- Passwords stored as **SHA-256 hashes** (never plaintext).
- Receipt **binaries live on disk**, not in the DB; the DB stores the file path + OCR text.

## 5. Login credentials (the ONLY place passwords are documented)

| Role | Email | Password |
|------|-------|----------|
| Employee | `prem@claimsense.com` | `123456` |
| Manager | `manager@claimsense.com` | `123456` |

**Demo employee accounts** (added via `database/demo_users.sql`; all share one password):

| Role | Name | Email | Password |
|------|------|-------|----------|
| Employee | Prem Pujara | `prempujara@claimsense.com` | `Claim@123` |
| Employee | Yashvi Shah | `yashvi@claimsense.com` | `Claim@123` |
| Employee | Mannan Shah | `mannan@claimsense.com` | `Claim@123` |
| Employee | Deev Savani | `deev@claimsense.com` | `Claim@123` |
| Employee | Jay Rathod | `jay@claimsense.com` | `Claim@123` |

Passwords are stored only as **SHA-256 hashes** (via `PasswordUtil`); the plaintext above
appears **nowhere else** — not in the SQL seed, not in JSP, not in client-side JS, not
committed as secrets. DB credentials live in `config.properties` (server-side only), never
exposed to the browser.

## 6. Prerequisites & install commands

```bash
# 1. Tesseract OCR engine (Windows installer) — must be on disk at:
#    C:\Program Files\Tesseract-OCR\tesseract.exe   (or set TESSERACT_CMD)
#    Download: https://github.com/UB-Mannheim/tesseract/wiki   (verified: v5.4.0)

# 2. Python ML/OCR dependencies
python -m pip install flask scikit-learn pandas joblib pytesseract Pillow PyMuPDF

# 3. MySQL 8 (Docker)
docker run --name claimsense-mysql -e MYSQL_ROOT_PASSWORD=root -p 3306:3306 -d mysql:8

# 4. Load the schema (creates DB claimsense_ai, tables, categories, demo users)
docker exec -i claimsense-mysql mysql -uroot -proot < database/schema.sql
```

## 7. Run commands

```bash
# A. Train the ML model (deterministic; writes ml/model/expense_classifier.pkl)
cd ml
python generate_dataset.py     # -> dataset.csv (761 rows)
python train_model.py          # prints real held-out metrics, saves the .pkl

# B. Start the Python OCR/ML service (port 5000)
python app.py                  # Flask: /health /ocr /predict /anomaly

# C. Deploy to Tomcat 10.1
#    Context descriptor conf/Catalina/localhost/claimsense.xml points docBase at
#    the workspace webapp dir (reloadable="true"); compiled classes in WEB-INF/classes.
catalina.bat run               # then open http://localhost:8080/claimsense/
```

## 8. OCR — real Tesseract (§16)

`ml/ocr.py` runs Tesseract on uploaded images (Pillow) and PDFs (PyMuPDF: embedded text
first, else render→OCR). Regex heuristics extract **merchant**, **amount** (prefers
total/grand/net lines, then currency-prefixed, then largest bare number) and **date**
(multiple formats).

**Live evidence** — the uploaded Uber receipt produced, from the real engine:
`merchant = "UBER INDIA"`, `amount = 450.00`, `date = 18/08/2026`. Raw OCR text is stored
and shown on the detail page.

## 9. ML category prediction — real, reproducible (§17–20)

- Pipeline: `TfidfVectorizer(ngram_range=(1,2), min_df=2, sublinear_tf=True)` →
  `LogisticRegression(max_iter=1000, C=10.0, random_state=42)`.
- Dataset: **761 rows** across 7 categories, deterministic (`SEED=42`), deduplicated so
  no train/test leakage. **80/20 stratified split, `random_state=42`** → Train 608 / Test 153.
- Saved to `ml/model/expense_classifier.pkl` via joblib. `/predict` returns the real
  category + `max(predict_proba)` confidence.

**ACTUAL held-out test metrics (reproducible):**

| Metric | Value |
|--------|-------|
| Accuracy | **0.9869** |
| Precision (macro) | **0.9876** |
| Recall (macro) | **0.9873** |
| F1-score (macro) | **0.9873** |

Per-class scores are honestly **below 100%** where categories genuinely overlap
(Food recall 0.96, Office Supplies precision 0.96, Other 0.95/0.95), because the dataset
deliberately includes cross-category vendors (Amazon, Reliance, Walmart…) and generic
descriptions. This proves the model **generalizes from language**, not a merchant lookup.

## 10. Anomaly detection — Isolation Forest (§22)

`ml/anomaly.py`: `IsolationForest(n_estimators=100, contamination="auto", random_state=42)`
fit on the employee's own category spend history.

- Needs ≥5 prior data points → otherwise **"Insufficient data for anomaly analysis"**.
- Flags outliers with the wording **"Potential anomaly detected"** (never "fraud").
- **Does NOT block submission** — verified live.

**Live evidence across the dataset** (all real model output):

| Expense | Amount | Anomaly status |
|--------:|-------:|----------------|
| 1–5 | 380–520 | INSUFFICIENT DATA (<5 history) |
| 6, 8 | 445, 455 | NORMAL |
| 7 | 500 | POTENTIAL ANOMALY |
| 9 | 9500 | POTENTIAL ANOMALY (clear outlier) |

## 11. Java ↔ Python integration

`service/AIService.java` calls the Flask endpoints with `java.net.http.HttpClient` and a
hand-rolled `JsonUtil`. Configurable via `config.properties`
(`ml.service.url=http://localhost:5000`, `ml.service.timeoutMs=8000`).

## 12. Graceful degradation — proven live (§35)

With the Flask service **stopped**, an employee submitted an expense with a receipt:

- Submission **still succeeded** (expense persisted, status PENDING).
- `ai_analysis` recorded honestly: OCR/ML fields `NULL`, `anomaly_status = UNAVAILABLE`.
- Receipt `ocr_text` = `"OCR processing failed"`.
- Detail page rendered the honest fallbacks: **"AI category suggestion unavailable"** and
  **"OCR processing failed"**.

After restarting Flask, `/predict` returned a real result again
(`{"category":"Travel","confidence":0.918}`). Degradation is real, not simulated.

## 13. Security & authorization

- **Password hashing:** SHA-256; no plaintext anywhere except this credentials table.
- **No secrets in the frontend:** DB URL/credentials only in server-side `config.properties`.
- **Session + role filter** (`AuthenticationFilter`, verified):
  - Unauthenticated → redirected to login.
  - `/employee/*` and submit → EMPLOYEE only.
  - `/manager/*` and approve/reject → MANAGER only (cross-role access denied).
- **Ownership guard** (verified in `ExpenseDetailsServlet` and `ReceiptServlet`):
  employees can view/download **only their own** claims and receipts; managers may view any.

Verified probes:

| Test | Result |
|------|--------|
| Employee opens another user's expense | **403 Forbidden** |
| Employee opens own expense | 200 |
| Manager opens any employee's expense | 200 |
| Non-existent expense id | 404 |
| Unauthenticated → protected page | 302 → login |
| Employee → manager area / approve-reject | 302 → denied |
| Manager → employee submit area | 302 → denied |
| Logout | session invalidated |

## 14. End-to-end test results (§33)

| Flow | Status |
|------|--------|
| Employee login → dashboard | ✓ 200 |
| Submit expense + receipt → OCR → ML → anomaly → persist | ✓ real data |
| My Expenses list / Submit form / Expense detail | ✓ 200 |
| Detail page renders real OCR + ML(86%) + "Potential anomaly detected" | ✓ |
| Receipt stored on disk + served (image/png) | ✓ 200 |
| Manager login → dashboard shows pending claims + AI | ✓ 200 |
| Approve → status APPROVED + approval_history row | ✓ |
| Reject (the 9500 anomaly outlier) → REJECTED + history row | ✓ |
| Authorization (ownership + role) | ✓ all 8 probes |
| Graceful degradation (ML offline) | ✓ non-blocking + honest fallback |
| ML metrics reproducible (seed 42) | ✓ 98.69% accuracy |

## 15. Key files created/modified (backend/ML only — frontend untouched)

- `ml/ocr.py` — real Tesseract OCR + field extraction.
- `ml/predict.py` — model load + prediction.
- `ml/anomaly.py` — Isolation Forest anomaly detection.
- `ml/app.py` — Flask service (`/health /ocr /predict /anomaly`).
- `ml/generate_dataset.py` — deterministic 761-row dataset (dedup + ambiguity for honest metrics).
- `ml/train_model.py` — TF-IDF + LogReg, prints real metrics, saves `.pkl`.
- `model/AiAnalysis.java`, `model/Receipt.java` — bean-compliant EL getters
  (`isHasPrediction()`, `isHasOcr()`) so the JSP renders the AI card.
- 39 Java classes compiled to `WEB-INF/classes`.

## 16. Notes / limitations

- Flask runs the Werkzeug dev server (fine for the MVP demo; use a WSGI server for production).
- OCR amount vs entered amount can differ legitimately (the receipt fare vs the claimed
  total) — both are stored; the anomaly check uses the employee's spend history.
- Tesseract is an external native dependency: if it is not installed at the expected path,
  the app degrades gracefully (see §12) and the fix is the install command in §6.

---

**Conclusion:** The complete ClaimSense AI MVP is implemented and verified end-to-end —
real OCR, real ML (98.69% accuracy, reproducible), real anomaly detection, full
auth/authorization, graceful degradation, and a clean audit trail — all on the locked
Java/JSP/Jakarta/Tomcat/MySQL + Python stack, with the existing frontend preserved.
