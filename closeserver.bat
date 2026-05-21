@echo off
setlocal EnableExtensions

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$connections = @(Get-NetTCPConnection -State Listen -LocalPort 30415 -ErrorAction SilentlyContinue); " ^
  "$namedProcesses = @(Get-Process -Name 'ocrapp_pureray' -ErrorAction SilentlyContinue); " ^
  "$pids = @(); " ^
  "$pids += $connections | Select-Object -ExpandProperty OwningProcess -Unique; " ^
  "$pids += $namedProcesses | Select-Object -ExpandProperty Id -Unique; " ^
  "$pids = @($pids | Where-Object { $_ } | Select-Object -Unique); " ^
  "if (-not $pids) { Write-Host '[INFO] No listener is bound to port 30415 and no ocrapp_pureray process is running.'; exit 0 }; " ^
  "foreach ($pid in $pids) { " ^
  "  $process = Get-Process -Id $pid -ErrorAction SilentlyContinue; " ^
  "  if ($null -eq $process) { continue }; " ^
  "  Write-Host ('[INFO] Terminating PID ' + $pid + ' (' + $process.ProcessName + ').'); " ^
  "  Stop-Process -Id $pid -Force -ErrorAction Stop " ^
  "};"

exit /b %ERRORLEVEL%
