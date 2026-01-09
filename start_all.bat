@echo off
chcp 65001 >nul
title 🚀 TripFinity - ALL IN ONE STARTER
color 0A

echo.
echo ╔══════════════════════════════════════════════════════════════════════╗
echo ║           🚀 TRIPFINITY - ALL IN ONE STARTER                         ║
echo ║     Backend + Model AI + Chatbot + Supplier (LOCAL - Tiết kiệm)      ║
echo ╚══════════════════════════════════════════════════════════════════════╝
echo.
echo    📋 CẤU TRÚC KẾT NỐI (TẤT CẢ LOCAL, CHỈ iOS DÙNG NGROK):
echo    ┌─────────────────────────────────────────────────────────────┐
echo    │  Android/Web ──► Backend (localhost:8080)                   │
echo    │       │                                                     │
echo    │       └──────► Chatbot (localhost:8000)                     │
echo    │                                                             │
echo    │  iOS ──────────► Backend (ngrok) ← Chỉ iOS cần ngrok        │
echo    │                                                             │
echo    │  Supplier ────► Backend (localhost:8080)                    │
echo    └─────────────────────────────────────────────────────────────┘
echo.

REM ============================================================
REM BƯỚC 1: KILL TẤT CẢ PROCESSES CŨ
REM ============================================================
echo [1/6] 🔄 Đang dừng các processes cũ...
taskkill /F /IM ngrok.exe >nul 2>&1
taskkill /F /IM node.exe >nul 2>&1
timeout /t 2 /nobreak >nul
echo       ✅ Đã dừng ngrok và node processes
echo.

REM ============================================================
REM BƯỚC 2: CHẠY NGROK (CHỈ BACKEND CHO iOS)
REM ============================================================
echo [2/6] 🌐 Đang khởi động Ngrok Backend (chỉ dành cho iOS)...

REM Ngrok cho Backend (port 8080) - Chỉ iOS cần
start "Ngrok Backend" cmd /k "title 🌐 Ngrok Backend [8080 - iOS only] && ngrok start --all --config="%~dp0ngrok_backend.yml""
timeout /t 2 /nobreak >nul

echo       ✅ Ngrok Backend đang khởi động (dành cho iOS)...
echo.

REM ============================================================
REM BƯỚC 3: CHẠY BACKEND (Spring Boot - Port 8080)
REM ============================================================
echo [3/6] 🖥️  Đang khởi động Backend (Spring Boot - Port 8080)...
start "TripFinity Backend" cmd /k "title 🖥️ Backend [Port 8080] && cd /d "%~dp0backend" && mvn spring-boot:run"
timeout /t 2 /nobreak >nul
echo       ✅ Backend đang khởi động...
echo.

REM ============================================================
REM BƯỚC 4: CHẠY SERVER MODEL AI (Python Flask - Port 5000)
REM Model AI chạy localhost, Backend gọi trực tiếp - KHÔNG cần ngrok
REM ============================================================
echo [4/6] 🧠 Đang khởi động Model AI (Python - Port 5000)...
echo       ⚠️  Model AI chạy localhost:5000, Backend gọi trực tiếp
start "TripFinity Model AI" cmd /k "title 🧠 Model AI [Port 5000] && cd /d "%~dp0" && python server_model_ai.py"
timeout /t 2 /nobreak >nul
echo       ✅ Model AI đang khởi động...
echo.

REM ============================================================
REM BƯỚC 5: CHẠY CHATBOT (Python FastAPI - Port 8000)
REM ============================================================
echo [5/6] 🤖 Đang khởi động Chatbot (Python - Port 8000)...
start "TripFinity Chatbot" cmd /k "title 🤖 Chatbot [Port 8000] && cd /d "%~dp0" && python chatbot_tripfinity.py"
timeout /t 2 /nobreak >nul
echo       ✅ Chatbot đang khởi động...
echo.

REM ============================================================
REM BƯỚC 6: CHẠY SUPPLIER (React Vite - Port 5173)
REM Supplier là web riêng cho nhà cung cấp, KHÔNG liên quan Flutter
REM ============================================================
echo [6/6] 🏪 Đang khởi động Supplier Portal (React - Port 5173)...
echo       ⚠️  Supplier là web riêng, không liên quan Flutter app
start "TripFinity Supplier" cmd /k "title 🏪 Supplier [Port 5173] && cd /d "%~dp0supplier" && npm run dev"
timeout /t 2 /nobreak >nul
echo       ✅ Supplier Portal đang khởi động...
echo.

REM ============================================================
REM HOÀN TẤT
REM ============================================================
echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║  ✅ TẤT CẢ SERVICES ĐÃ ĐƯỢC KHỞI ĐỘNG!                                       ║
echo ╠══════════════════════════════════════════════════════════════════════════════╣
echo ║                                                                              ║
echo ║  🎯 TẤT CẢ KẾT NỐI LOCAL - KHÔNG CẦN CẬP NHẬT GÌ!                            ║
echo ║                                                                              ║
echo ║  🤖 Android Emulator:                                                        ║
echo ║     • Backend:  http://10.0.2.2:8080 (tự động)                               ║
echo ║     • Chatbot:  http://10.0.2.2:8000 (tự động)                               ║
echo ║                                                                              ║
echo ║  🌐 Web (Chrome):                                                            ║
echo ║     • Backend:  http://localhost:8080 (tự động)                              ║
echo ║     • Chatbot:  http://localhost:8000 (tự động)                              ║
echo ║                                                                              ║
echo ║  🍎 iOS (Appetize.io/thiết bị thật):                                         ║
echo ║     • Backend:  https://unprotrusively-nonreportable-kingston.ngrok-free.dev ║
echo ║                                                                              ║
echo ║  🏪 Supplier Portal:                                                         ║
echo ║     • URL: http://localhost:5173                                             ║
echo ║                                                                              ║
echo ║  🔗 Liên kết nội bộ:                                                         ║
echo ║     • Backend → Model AI: localhost:5000                                     ║
echo ║                                                                              ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.

REM Đợi services khởi động
echo ⏳ Đợi 10 giây để services khởi động...
timeout /t 10 /nobreak >nul

REM Mở Supplier trong trình duyệt
echo 🌐 Đang mở Supplier Portal...
start http://localhost:5173/supplier

echo.
echo ════════════════════════════════════════════════════════════════════════════════
echo 🎉 KHÔNG CẦN CẬP NHẬT GÌ! Đổi mạng WiFi cũng không ảnh hưởng!
echo ════════════════════════════════════════════════════════════════════════════════
echo.
echo 🎯 CHẠY FLUTTER APP:
echo    • Android: flutter run -d android
echo    • Web:     flutter run -d chrome --web-port=50077
echo.
echo Nhấn phím bất kỳ để đóng cửa sổ này (các services vẫn chạy)...
pause >nul
