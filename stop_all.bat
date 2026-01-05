@echo off
chcp 65001 >nul
title 🛑 TripFinity - STOP ALL
color 0C

echo.
echo ╔══════════════════════════════════════════════════════════════════════╗
echo ║           🛑 TRIPFINITY - STOP ALL SERVICES                          ║
echo ╚══════════════════════════════════════════════════════════════════════╝
echo.

echo 🔄 Đang dừng tất cả services...
echo.

echo    [1/4] Stopping Ngrok tunnels...
taskkill /F /IM ngrok.exe >nul 2>&1
echo         ✅ Ngrok stopped

echo    [2/4] Stopping Node.js (Supplier React)...
taskkill /F /IM node.exe >nul 2>&1
echo         ✅ Node.js stopped

echo    [3/4] Stopping Java (Backend)...
taskkill /F /IM java.exe >nul 2>&1
echo         ✅ Java stopped

echo    [4/4] Stopping Python (Model AI + Chatbot)...
taskkill /F /IM python.exe >nul 2>&1
echo         ✅ Python stopped

echo.
echo ╔══════════════════════════════════════════════════════════════════════╗
echo ║  ✅ TẤT CẢ SERVICES ĐÃ DỪNG!                                         ║
echo ║                                                                      ║
echo ║  📋 Đã dừng:                                                         ║
echo ║     • 3 Ngrok tunnels (Backend, Chatbot, Supplier)                   ║
echo ║     • Backend (Spring Boot - Port 8080)                              ║
echo ║     • Model AI (Python Flask - Port 5000)                            ║
echo ║     • Chatbot (Python FastAPI - Port 8000)                           ║
echo ║     • Supplier (React Vite - Port 5173)                              ║
echo ║                                                                      ║
echo ╚══════════════════════════════════════════════════════════════════════╝
echo.

timeout /t 3
