# ClaimSense AI — Windows Local Setup & Developer Guide

This guide provides step-by-step instructions for setting up, configuring, running, and troubleshooting **ClaimSense AI** locally on Windows 11 / Windows 10.

---

## Technical Stack & Architecture

ClaimSense AI uses a Model-2 MVC architecture combining a Java Jakarta Servlet backend on Apache Tomcat 10.1 with a Python Flask AI microservice.

```text
Browser (JSP/JSTL)
   │  HTTP (Port 8080)
   ▼
Apache Tomcat 10.1
   │  Jakarta Servlets (controller/*)
   ▼
Services Layer (service/*) ─────── HTTP (Port 5000) ──────► Python Flask AI Service
   │                                                         ├── /ocr (Tesseract OCR)
   ▼                                                         ├── /predict (TF-IDF + LogReg)
DAO Layer (dao/*) ── JDBC                                   └── /anomaly (Isolation Forest)
   ▼
MySQL 8 (Port 3306)
```

---

## 1. System Requirements & Software Dependencies

Ensure the following software is installed on your Windows machine:

| Component | Minimum Version | Verified Version | Notes |
| :--- | :--- | :--- | :--- |
| **Java Development Kit** | JDK 17+ | JDK 17 / JDK 25 LTS | Code targets `--release 17` |
| **Python** | Python 3.10+ | Python 3.14 (via `py`) | Use `py` launcher on Windows |
| **MySQL Server** | MySQL 8.0+ | MySQL 8.4 (Laragon / Docker) | Native auth / JDBC compatible |
| **Apache Tomcat** | Tomcat 10.1.x | Apache Tomcat 10.1.34 | Requires `jakarta.servlet.*` |
| **Tesseract OCR** | Tesseract 5.x | UB-Mannheim v5.4.0 | Native binary required for OCR |

---

## 2. Environment & Repository Setup

1. **Clone the Repository:**
   ```powershell
   git clone https://github.com/Prempujara/ClaimsenseAI.git
   cd ClaimsenseAI
   ```

2. **Verify Python Launcher:**
   On Windows, Python App Execution Aliases can interfere with `python`. Use `py`:
   ```powershell
   py --version
   ```

3. **Install Python ML Dependencies:**
   ```powershell
   py -m pip install -r ml/requirements.txt
   ```
   *Dependencies installed:* `Flask`, `scikit-learn`, `pandas`, `joblib`, `pytesseract`, `Pillow`, `PyMuPDF`.

---

## 3. Database Initialization (MySQL 8)

The application connects to MySQL on `localhost:3306` with database `claimsense_ai`, user `root`, and password `root`.

### A. Start MySQL Server
- **Option 1 (Laragon / Standalone MySQL):** Start `mysqld.exe` with port `3306`.
- **Option 2 (Docker Desktop):**
  ```powershell
  docker run --name claimsense-mysql -e MYSQL_ROOT_PASSWORD=root -p 3306:3306 -d mysql:8
  ```

### B. Import Schema & Seed Data
> [!NOTE]
> In Windows PowerShell, `<` redirection is a reserved operator. Use `Get-Content -Raw` or `cmd /c` to run SQL imports.

```powershell
# 1. Base Schema & Initial Demo Accounts
cmd /c "mysql -u root -proot < database\schema.sql"

# 2. Profile Schema Migration
cmd /c "mysql -u root -proot claimsense_ai < database\migration_profile_fields.sql"

# 3. Demo Employee Users
cmd /c "mysql -u root -proot claimsense_ai < database\demo_users.sql"

# 4. Historical Expense Baseline Data for Anomaly Model
cmd /c "mysql -u root -proot claimsense_ai < database\demo_expenses.sql"
cmd /c "mysql -u root -proot claimsense_ai < database\demo_data.sql"
```

### C. Seeded Accounts & Credentials

| Role | Email | Password | Access Area |
| :--- | :--- | :--- | :--- |
| **Employee** | `prem@claimsense.com` | `123456` | Submit Claims & My Expenses |
| **Manager** | `manager@claimsense.com` | `123456` | Pending Approvals & AI Risk |
| **Demo Employees** | `prempujara@claimsense.com`, `yashvi@claimsense.com`, `mannan@claimsense.com`, `deev@claimsense.com`, `jay@claimsense.com` | `Claim@123` | Individual Expense Baselines |

---

## 4. Tesseract OCR Configuration

1. **Install Tesseract OCR for Windows:**
   Download and install the UB-Mannheim build (`tesseract-ocr-w64-setup-v5.4.0.exe`).

2. **Configure Executable Path:**
   `ml/ocr.py` looks for Tesseract at standard locations:
   - `C:\Program Files\Tesseract-OCR\tesseract.exe`
   - `C:\Users\<User>\Tesseract-OCR\tesseract.exe`

   Alternatively, set the environment variable:
   ```powershell
   $env:TESSERACT_CMD = "C:\Program Files\Tesseract-OCR\tesseract.exe"
   ```

---

## 5. Python Flask AI Microservice Setup

1. **Verify/Train ML Model:**
   The repository contains a pre-trained model `ml/model/expense_classifier.pkl`. To retrain if needed:
   ```powershell
   cd ml
   py generate_dataset.py
   py train_model.py
   ```

2. **Start the Flask AI Service (Port 5000):**
   ```powershell
   cd ml
   py app.py
   ```

3. **Verify Health Endpoint:**
   Open [http://localhost:5000/health](http://localhost:5000/health) or run:
   ```powershell
   (Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing).Content
   ```
   *Expected output:* `{"status":"ok"}`

---

## 6. Java Backend & Apache Tomcat 10.1 Setup

1. **Verify Runtime Configuration (`config.properties`):**
   Inspect `src/main/webapp/WEB-INF/classes/config.properties`:
   ```properties
   db.url=jdbc:mysql://localhost:3306/claimsense_ai?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=utf8
   db.user=root
   db.password=root
   db.driver=com.mysql.cj.jdbc.Driver

   ml.service.url=http://localhost:5000
   ml.service.timeoutMs=8000
   ```

2. **Compile Java Sources:**
   If rebuilding Java class files, compile with target Java 17 bytecode:
   ```powershell
   $cp = "src\main\webapp\WEB-INF\lib\*;C:\apache-tomcat-10.1.34\lib\*"
   $sources = Get-ChildItem -Path "src\main\java" -Recurse -Filter "*.java" | Select-Object -ExpandProperty FullName
   javac --release 17 -cp $cp -d "src\main\webapp\WEB-INF\classes" $sources
   ```

3. **Create Tomcat Context Descriptor:**
   Create `<Tomcat-Root>\conf\Catalina\localhost\claimsense.xml`:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <Context docBase="C:\Path\To\ClaimsenseAI\src\main\webapp" reloadable="true" />
   ```

4. **Start Tomcat Server (Port 8080):**
   ```powershell
   $env:JAVA_HOME = "C:\Program Files\Java\jdk-25.0.2"
   & "C:\apache-tomcat-10.1.34\bin\catalina.bat" run
   ```

---

## 7. Application Access & Verification

Open your web browser and navigate to:
**[http://localhost:8080/claimsense/](http://localhost:8080/claimsense/)**

- The login screen will load and automatically handle authentication.
- Test login with `prem@claimsense.com` / `123456` for the **Employee Dashboard**.
- Test login with `manager@claimsense.com` / `123456` for the **Manager Dashboard**.

---

## 8. Windows Troubleshooting Guide

| Issue | Root Cause | Solution |
| :--- | :--- | :--- |
| `python` command launches Microsoft Store | Windows App Execution Aliases | Use `py` launcher instead of `python` |
| `<` redirection syntax error in PowerShell | Reserved character in PowerShell | Use `cmd /c "mysql -u root -p < file.sql"` or `Get-Content -Raw file.sql \| mysql` |
| `ClassNotFoundException: controller...$EmployeeMetric` | Missing compiled inner classes | Recompile all Java sources using `javac --release 17` into `WEB-INF/classes` |
| `Tesseract OCR engine not found` | `tesseract.exe` not on PATH or missing DLLs | Ensure `tesseract.exe` directory is added to `PATH` and set `TESSERACT_CMD` |
| `HTTP 404` on `http://localhost:5000/` | Flask API has no HTML root page | Access `http://localhost:5000/health` (JSON health endpoint) |
