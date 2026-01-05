@echo off
chcp 65001 >nul
title 🛑 TripFinity - STOP ALL
color 0C

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║     🛑 TRIPFINITY - STOP ALL SERVICES                        ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

echo 🔄 Đang dừng tất cả services...
echo.

echo    Stopping ngrok...
taskkill /F /IM ngrok.exe >nul 2>&1
echo    ✅ Ngrok stopped

echo    Stopping Java (Backend)...
taskkill /F /IM java.exe >nul 2>&1
echo    ✅ Java stopped

echo    Stopping Python (Chatbot)...
taskkill /F /IM python.exe >nul 2>&1
echo    ✅ Python stopped

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║  ✅ TẤT CẢ SERVICES ĐÃ DỪNG!                                 ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

timeout /t 3
