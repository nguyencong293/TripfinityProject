@echo off
chcp 65001 >nul
title 🚀 TripFinity - ALL IN ONE STARTER
color 0A

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║     🚀 TRIPFINITY - ALL IN ONE STARTER                       ║
echo ║     Backend + Chatbot + Ngrok Tunnels                        ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

REM ============================================================
REM BƯỚC 1: KILL TẤT CẢ PROCESSES CŨ
REM ============================================================
echo [1/4] 🔄 Đang dừng các processes cũ...
taskkill /F /IM ngrok.exe >nul 2>&1
REM Không kill java.exe vì có thể đang dùng cho IDE
timeout /t 2 /nobreak >nul
echo       ✅ Đã dừng ngrok processes
echo.

REM ============================================================
REM BƯỚC 2: CHẠY NGROK TUNNELS TRƯỚC
REM ============================================================
echo [2/4] 🌐 Đang khởi động Ngrok Tunnels...

REM Ngrok cho Backend (port 8080)
start "Ngrok Backend" cmd /k "title Ngrok Backend [8080] && ngrok start --all --config="%~dp0ngrok_backend.yml""
timeout /t 2 /nobreak >nul

REM Ngrok cho Chatbot (port 8000)  
start "Ngrok Chatbot" cmd /k "title Ngrok Chatbot [8000] && ngrok start --all --config="%~dp0ngrok_chatbot.yml""
timeout /t 3 /nobreak >nul
echo       ✅ Ngrok tunnels đang khởi động...
echo.

REM ============================================================
REM BƯỚC 3: CHẠY BACKEND (Spring Boot - Port 8080)
REM ============================================================
echo [3/4] 🖥️  Đang khởi động Backend (Spring Boot - Port 8080)...
start "TripFinity Backend" cmd /k "title TripFinity Backend [Port 8080] && cd /d "%~dp0backend" && mvn spring-boot:run"
timeout /t 3 /nobreak >nul
echo       ✅ Backend đang khởi động...
echo.

REM ============================================================
REM BƯỚC 4: CHẠY CHATBOT (Python FastAPI - Port 8000)
REM ============================================================
echo [4/4] 🤖 Đang khởi động Chatbot (Python - Port 8000)...
start "TripFinity Chatbot" cmd /k "title TripFinity Chatbot [Port 8000] && cd /d "%~dp0" && python chatbot_tripfinity.py"
timeout /t 3 /nobreak >nul
echo       ✅ Chatbot đang khởi động...
echo.

REM ============================================================
REM HOÀN TẤT
REM ============================================================
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║  ✅ TẤT CẢ SERVICES ĐÃ ĐƯỢC KHỞI ĐỘNG!                       ║
echo ╠══════════════════════════════════════════════════════════════╣
echo ║                                                              ║
echo ║  📋 LOCAL SERVICES:                                          ║
echo ║     • Backend:  http://localhost:8080                        ║
echo ║     • Chatbot:  http://localhost:8000                        ║
echo ║                                                              ║
echo ║  🌐 NGROK DASHBOARDS (xem Public URLs):                      ║
echo ║     • Backend:  http://127.0.0.1:4040                        ║
echo ║     • Chatbot:  http://127.0.0.1:4041                        ║
echo ║                                                              ║
echo ║  💡 Đợi 10-15 giây để services khởi động hoàn tất            ║
echo ║                                                              ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

REM Đợi services khởi động
echo ⏳ Đợi 10 giây để services khởi động...
timeout /t 10 /nobreak >nul

REM Mở ngrok dashboard trong browser
echo 🌐 Đang mở Ngrok dashboards...
start http://127.0.0.1:4040
timeout /t 1 /nobreak >nul
start http://127.0.0.1:4041

echo.
echo 📋 Copy URLs từ dashboard và cập nhật vào:
echo    app\lib\config\app_config.dart
echo.
echo Nhấn phím bất kỳ để đóng cửa sổ này (các services vẫn chạy)...
pause >nul
