# stop-claimsense.ps1 - ClaimSense AI Local Services Safe Stopper
# Gracefully stops ClaimSense background processes without affecting unrelated system applications

Write-Host "Stopping ClaimSense AI background processes..." -ForegroundColor Yellow

# Stop Flask service process running app.py
$flaskProc = Get-WmiObject Win32_Process | Where-Object { $_.CommandLine -like "*app.py*" }
if ($flaskProc) {
    $flaskProc | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
    Write-Host "  [OK] Stopped Flask AI service." -ForegroundColor Green
} else {
    Write-Host "  [INFO] Flask service process was not active." -ForegroundColor Gray
}

# Stop Tomcat process running catalina.bat / Tomcat
$tomcatProc = Get-WmiObject Win32_Process | Where-Object { $_.CommandLine -like "*apache-tomcat*" }
if ($tomcatProc) {
    $tomcatProc | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
    Write-Host "  [OK] Stopped Tomcat 10.1 web server." -ForegroundColor Green
} else {
    Write-Host "  [INFO] Tomcat process was not active." -ForegroundColor Gray
}

Write-Host "ClaimSense AI background web services stopped." -ForegroundColor Green
