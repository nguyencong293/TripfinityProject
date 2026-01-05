@echo off
chcp 65001 >nul
title 🚀 TripFinity - ALL IN ONE STARTER
color 0A

echo.
echo ╔══════════════════════════════════════════════════════════════════════╗
echo ║           🚀 TRIPFINITY - ALL IN ONE STARTER                         ║
echo ║       Backend + Model AI + Chatbot + Supplier + Ngrok                ║
echo ╚══════════════════════════════════════════════════════════════════════╝
echo.
echo    📋 CẤU TRÚC LIÊN KẾT:
echo    ┌─────────────────────────────────────────────────────────────┐
echo    │  Flutter App ──► Backend (ngrok) ──► Model AI (localhost)   │
echo    │       │                                                     │
echo    │       └──────► Chatbot (ngrok)                              │
echo    │                                                             │
echo    │  Supplier (ngrok) ← Web riêng, không liên quan Flutter      │
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
REM BƯỚC 2: CHẠY NGROK TUNNELS (CHỈ 2 CÁI CHO FLUTTER)
REM ============================================================
echo [2/6] 🌐 Đang khởi động Ngrok Tunnels...

REM Ngrok cho Backend (port 8080) - Flutter cần
start "Ngrok Backend" cmd /k "title 🌐 Ngrok Backend [8080] && ngrok start --all --config="%~dp0ngrok_backend.yml""
timeout /t 1 /nobreak >nul

REM Ngrok cho Chatbot (port 8000) - Flutter cần
start "Ngrok Chatbot" cmd /k "title 🌐 Ngrok Chatbot [8000] && ngrok start --all --config="%~dp0ngrok_chatbot.yml""
timeout /t 1 /nobreak >nul

REM Ngrok cho Supplier (port 5173) - Web riêng, không liên quan Flutter
start "Ngrok Supplier" cmd /k "title 🌐 Ngrok Supplier [5173] && ngrok start --all --config="%~dp0ngrok_supplier.yml""
timeout /t 2 /nobreak >nul

echo       ✅ 3 Ngrok tunnels đang khởi động...
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
echo ╔══════════════════════════════════════════════════════════════════════╗
echo ║  ✅ TẤT CẢ SERVICES ĐÃ ĐƯỢC KHỞI ĐỘNG!                               ║
echo ╠══════════════════════════════════════════════════════════════════════╣
echo ║                                                                      ║
echo ║  📱 FLUTTER APP CẦN 2 URLs (cập nhật vào app_config.dart):           ║
echo ║     • Backend:   http://127.0.0.1:4040 ← Copy URL từ đây             ║
echo ║     • Chatbot:   http://127.0.0.1:4041 ← Copy URL từ đây             ║
echo ║                                                                      ║
echo ║  🔗 LIÊN KẾT NỘI BỘ (tự động, không cần config):                     ║
echo ║     • Backend → Model AI: localhost:5000 (cùng máy)                  ║
echo ║                                                                      ║
echo ║  🏪 SUPPLIER (web riêng, không liên quan Flutter):                   ║
echo ║     • Supplier: http://127.0.0.1:4043 ← Dành cho nhà cung cấp        ║
echo ║                                                                      ║
echo ╚══════════════════════════════════════════════════════════════════════╝
echo.

REM Đợi services khởi động
echo ⏳ Đợi 15 giây để services khởi động...
timeout /t 15 /nobreak >nul

REM Mở ngrok dashboards cho Flutter (Backend + Chatbot)
echo 🌐 Đang mở Ngrok dashboards cho Flutter...
start http://127.0.0.1:4040
timeout /t 1 /nobreak >nul
start http://127.0.0.1:4041

echo.
echo ════════════════════════════════════════════════════════════════════════
echo 📋 CHỈ CẦN CẬP NHẬT 2 URLs VÀO: app\lib\config\app_config.dart
echo    • ngrokBackendUrl  (từ dashboard 4040)
echo    • ngrokChatbotUrl  (từ dashboard 4041)
echo ════════════════════════════════════════════════════════════════════════
echo.
echo 🎯 SAU ĐÓ CHẠY FLUTTER APP TRÊN NỀN TẢNG BẠN MUỐN!
echo.
echo Nhấn phím bất kỳ để đóng cửa sổ này (các services vẫn chạy)...
pause >nul
