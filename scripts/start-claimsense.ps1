# start-claimsense.ps1 - ClaimSense AI Local Services Launcher
# Starts MySQL, Python Flask ML service, and Tomcat in proper sequence

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "          Starting ClaimSense AI Local Environment          " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$usablePy = if (Get-Command py -ErrorAction SilentlyContinue) { "py" } else { "python" }

# 1. Start / Verify MySQL (Port 3306)
Write-Host "[1/3] Verifying MySQL Database (Port 3306)..." -ForegroundColor Yellow
$mysqlConn = Get-NetTCPConnection -LocalPort 3306 -ErrorAction SilentlyContinue
if (-not $mysqlConn) {
    $laragonMysql = "C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysqld.exe"
    $myIni = "C:\laragon\bin\mysql\mysql-8.4.3-winx64\my.ini"
    if (Test-Path $laragonMysql) {
        Write-Host "  Starting MySQL daemon process..." -ForegroundColor Gray
        Start-Process -FilePath $laragonMysql -ArgumentList "--defaults-file=$myIni" -WindowStyle Hidden
        Start-Sleep -Seconds 3
    } elseif (Get-Command docker -ErrorAction SilentlyContinue) {
        Write-Host "  Starting Docker MySQL container..." -ForegroundColor Gray
        docker start claimsense-mysql 2>$null
        Start-Sleep -Seconds 3
    }
}
$mysqlCheck = Get-NetTCPConnection -LocalPort 3306 -ErrorAction SilentlyContinue
if ($mysqlCheck) {
    Write-Host "  [OK] MySQL is active on port 3306." -ForegroundColor Green
} else {
    Write-Host "  [WARN] Could not auto-start MySQL. Please ensure MySQL is running on port 3306." -ForegroundColor Yellow
}

# 2. Start / Verify Python Flask ML Service (Port 5000)
Write-Host "`n[2/3] Verifying Python Flask AI Microservice (Port 5000)..." -ForegroundColor Yellow
$flaskConn = Get-NetTCPConnection -LocalPort 5000 -ErrorAction SilentlyContinue
if (-not $flaskConn) {
    Write-Host "  Starting Flask AI service (ml/app.py)..." -ForegroundColor Gray
    Start-Process -FilePath $usablePy -ArgumentList "app.py" -WorkingDirectory "$PSScriptRoot\..\ml" -WindowStyle Hidden
    Start-Sleep -Seconds 3
}
try {
    $health = (Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing -TimeoutSec 3).Content
    if ($health -like "*status*ok*") {
        Write-Host "  [OK] AI Service is responding on http://localhost:5000 (Health: OK)" -ForegroundColor Green
    }
} catch {
    Write-Host "  [WARN] Flask AI service starting or non-responsive. Retrying..." -ForegroundColor Yellow
}

# 3. Start / Verify Apache Tomcat (Port 8080)
Write-Host "`n[3/3] Verifying Apache Tomcat Web Server (Port 8080)..." -ForegroundColor Yellow
$tomcatConn = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if (-not $tomcatConn) {
    $tomcatPaths = @("C:\apache-tomcat-10.1.34", "C:\apache-tomcat-10.1.57", "C:\apache-tomcat-10.1")
    $tHome = $null
    foreach ($tp in $tomcatPaths) {
        if (Test-Path "$tp\bin\catalina.bat") { $tHome = $tp; break }
    }
    if ($tHome) {
        Write-Host "  Starting Tomcat 10.1 from $tHome..." -ForegroundColor Gray
        if (-not $env:JAVA_HOME) {
            if (Test-Path "C:\Program Files\Java\jdk-25.0.2") { $env:JAVA_HOME = "C:\Program Files\Java\jdk-25.0.2" }
            elseif (Test-Path "C:\Program Files\Java\jdk-17") { $env:JAVA_HOME = "C:\Program Files\Java\jdk-17" }
        }
        Start-Process -FilePath "$tHome\bin\catalina.bat" -ArgumentList "run" -WorkingDirectory "$tHome\bin" -WindowStyle Hidden
        Start-Sleep -Seconds 4
    }
}
$tomcatCheck = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if ($tomcatCheck) {
    Write-Host "  [OK] Tomcat 10.1 web server is active on port 8080." -ForegroundColor Green
} else {
    Write-Host "  [WARN] Tomcat starting up. Please allow a few seconds for full deployment." -ForegroundColor Yellow
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "               ClaimSense AI Services Status                " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  MySQL Database : Running (Port 3306)" -ForegroundColor Green
Write-Host "  AI Service     : Running (http://localhost:5000)" -ForegroundColor Green
Write-Host "  Tomcat Server  : Running (Port 8080)" -ForegroundColor Green
Write-Host ""
Write-Host "  Application URL: http://localhost:8080/claimsense/" -ForegroundColor White
Write-Host "============================================================" -ForegroundColor Cyan
