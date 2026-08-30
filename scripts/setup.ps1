# setup.ps1 - ClaimSense AI Environment Inspector & Initializer
# PowerShell-compatible idempotent environment checker

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "       ClaimSense AI - Environment Setup & Checker          " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Check Java & javac
Write-Host "[1/6] Checking Java Environment..." -ForegroundColor Yellow
$javaCmd = Get-Command java -ErrorAction SilentlyContinue
$javacCmd = Get-Command javac -ErrorAction SilentlyContinue

if ($javaCmd -and $javacCmd) {
    $javaVer = (java -version 2>&1 | Select-Object -First 1)
    Write-Host "  [OK] Java detected: $javaVer" -ForegroundColor Green
} else {
    Write-Host "  [ERROR] Java or javac not found on PATH. Please install JDK 17+." -ForegroundColor Red
}

# 2. Check Python & py launcher
Write-Host "`n[2/6] Checking Python Environment..." -ForegroundColor Yellow
$pyCmd = Get-Command py -ErrorAction SilentlyContinue
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
$usablePy = if ($pyCmd) { "py" } else { "python" }

if ($pyCmd -or $pythonCmd) {
    $pyVer = & $usablePy --version 2>&1
    Write-Host "  [OK] Python executable detected: $pyVer (using '$usablePy')" -ForegroundColor Green
    
    # Check Python dependencies
    if (Test-Path "ml/requirements.txt") {
        Write-Host "  Checking Python ML dependencies..." -ForegroundColor Gray
        & $usablePy -m pip install -r ml/requirements.txt --quiet
        Write-Host "  [OK] Python requirements verified." -ForegroundColor Green
    }
} else {
    Write-Host "  [ERROR] Python is not installed or not available on PATH." -ForegroundColor Red
}

# 3. Check MySQL
Write-Host "`n[3/6] Checking MySQL Server (Port 3306)..." -ForegroundColor Yellow
$mysqlPort = Get-NetTCPConnection -LocalPort 3306 -ErrorAction SilentlyContinue
if ($mysqlPort) {
    Write-Host "  [OK] MySQL server is listening on port 3306." -ForegroundColor Green
} else {
    $laragonMysql = "C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysqld.exe"
    if (Test-Path $laragonMysql) {
        Write-Host "  [WARN] MySQL is stopped. Found executable at $laragonMysql" -ForegroundColor Yellow
    } else {
        Write-Host "  [WARN] MySQL not detected on port 3306. (Start Docker container or local MySQL server)" -ForegroundColor Yellow
    }
}

# 4. Check Tesseract OCR
Write-Host "`n[4/6] Checking Tesseract OCR Engine..." -ForegroundColor Yellow
$tessPaths = @(
    "C:\Program Files\Tesseract-OCR\tesseract.exe",
    "C:\Users\$env:USERNAME\Tesseract-OCR\tesseract.exe"
)
$foundTess = $false
foreach ($tp in $tessPaths) {
    if (Test-Path $tp) {
        $tVer = & $tp --version 2>&1 | Select-Object -First 1
        Write-Host "  [OK] Tesseract OCR detected at $tp ($tVer)" -ForegroundColor Green
        $foundTess = $true
        break
    }
}
if (-not $foundTess) {
    Write-Host "  [WARN] Tesseract OCR not found in default paths. OCR fallback will report unavailable." -ForegroundColor Yellow
}

# 5. Check Apache Tomcat 10.1
Write-Host "`n[5/6] Checking Apache Tomcat Setup..." -ForegroundColor Yellow
$tomcatPaths = @(
    "C:\apache-tomcat-10.1.34",
    "C:\apache-tomcat-10.1.57",
    "C:\apache-tomcat-10.1"
)
$foundTomcat = $false
foreach ($tp in $tomcatPaths) {
    if (Test-Path "$tp\bin\catalina.bat") {
        Write-Host "  [OK] Tomcat 10.1 installation detected at $tp" -ForegroundColor Green
        $foundTomcat = $true
        break
    }
}
if (-not $foundTomcat) {
    Write-Host "  [WARN] Tomcat 10.1 directory not found in standard paths." -ForegroundColor Yellow
}

# 6. Check Project Configuration
Write-Host "`n[6/6] Checking Application Configuration..." -ForegroundColor Yellow
$configPath = "src/main/webapp/WEB-INF/classes/config.properties"
if (Test-Path $configPath) {
    Write-Host "  [OK] Runtime config.properties exists." -ForegroundColor Green
} else {
    Write-Host "  [WARN] Runtime config.properties missing in WEB-INF/classes." -ForegroundColor Yellow
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "  Setup Check Completed! Run .\scripts\start-claimsense.ps1  " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
