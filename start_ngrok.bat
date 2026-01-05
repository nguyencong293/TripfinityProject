@echo off
chcp 65001 >nul
title TripFinity Ngrok Manager
color 0A

echo ============================================================
echo 🌐 TRIPFINITY NGROK MANAGER
echo ============================================================
echo.

REM Kill tất cả ngrok đang chạy
echo 🔄 Đang dừng tất cả ngrok processes...
taskkill /F /IM ngrok.exe >nul 2>&1
timeout /t 2 /nobreak >nul
echo ✅ Đã dừng ngrok processes
echo.

REM Chạy ngrok backend (port 8080) - chạy nền
echo 🚀 Đang khởi động ngrok tunnel cho Backend (port 8080)...
start "Ngrok Backend" cmd /c "ngrok start --all --config="%~dp0ngrok_backend.yml""
timeout /t 3 /nobreak >nul

REM Chạy ngrok chatbot (port 8000) - chạy nền
echo 🚀 Đang khởi động ngrok tunnel cho Chatbot (port 8000)...
start "Ngrok Chatbot" cmd /c "ngrok start --all --config="%~dp0ngrok_chatbot.yml""
timeout /t 3 /nobreak >nul

echo.
echo ============================================================
echo ✅ ĐÃ KHỞI ĐỘNG 2 NGROK TUNNELS
echo ============================================================
echo.
echo 📋 Xem URLs tại:
echo    - Backend: http://127.0.0.1:4040 (ngrok dashboard 1)
echo    - Chatbot: http://127.0.0.1:4041 (ngrok dashboard 2)
echo.
echo 💡 Copy URLs từ dashboard và cập nhật vào app_config.dart
echo.
echo Nhấn phím bất kỳ để đóng cửa sổ này...
pause >nul

