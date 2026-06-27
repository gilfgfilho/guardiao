c:
cd\data\sistemas\carsoft\exec

echo on

rem taskkill /f /im xenapiintegracaosrv.exe /t
rem taskkill /f /im XenWebCheckinSRV.exe /t
taskkill /f /im XenDashServiceSRV.exe /t

PING -n 3 127.0.0.1 >nul

rem sc start FXenAPIService
rem sc start XenWebCheckin
sc start DashService
pause