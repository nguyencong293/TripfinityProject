package com.vn.tripfinity.backend.controller;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.vn.tripfinity.backend.dto.ConversationDTO;
import com.vn.tripfinity.backend.dto.ConversationMessageDTO;
import com.vn.tripfinity.backend.dto.CreateConversationRequest;
import com.vn.tripfinity.backend.dto.SendMessageRequest;
import com.vn.tripfinity.backend.service.ChatService;
import com.vn.tripfinity.backend.service.cloudinary.CloudinaryService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class ChatController {

    private final ChatService chatService;
    private final CloudinaryService cloudinaryService;

    // ==================== CONVERSATION ENDPOINTS ====================

    /**
     * Tạo hoặc lấy conversation giữa user và provider
     * POST /api/chat/conversations
     */
    @PostMapping("/conversations")
    public ResponseEntity<ConversationDTO> getOrCreateConversation(
            @Valid @RequestBody CreateConversationRequest request) {
        log.info("POST /api/chat/conversations - Tạo/lấy conversation: userId={}, providerId={}",
                request.getUserId(), request.getProviderId());
        ConversationDTO conversation = chatService.getOrCreateConversation(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(conversation);
    }

    /**
     * Lấy danh sách conversations của user
     * GET /api/chat/conversations/user/{userId}
     */
    @GetMapping("/conversations/user/{userId}")
    public ResponseEntity<List<ConversationDTO>> getConversationsByUser(@PathVariable Integer userId) {
        log.info("GET /api/chat/conversations/user/{} - Lấy conversations của user", userId);
        List<ConversationDTO> conversations = chatService.getConversationsByUser(userId);
        return ResponseEntity.ok(conversations);
    }

    /**
     * Lấy danh sách conversations của provider
     * GET /api/chat/conversations/provider/{providerId}
     */
    @GetMapping("/conversations/provider/{providerId}")
    public ResponseEntity<List<ConversationDTO>> getConversationsByProvider(@PathVariable Integer providerId) {
        log.info("GET /api/chat/conversations/provider/{} - Lấy conversations của provider", providerId);
        List<ConversationDTO> conversations = chatService.getConversationsByProvider(providerId);
        return ResponseEntity.ok(conversations);
    }

    /**
     * Lấy chi tiết conversation
     * GET /api/chat/conversations/{conversationId}
     */
    @GetMapping("/conversations/{conversationId}")
    public ResponseEntity<ConversationDTO> getConversationById(@PathVariable Integer conversationId) {
        log.info("GET /api/chat/conversations/{} - Lấy chi tiết conversation", conversationId);
        ConversationDTO conversation = chatService.getConversationById(conversationId);
        return ResponseEntity.ok(conversation);
    }

    /**
     * Tìm kiếm conversations
     * GET /api/chat/conversations/search?id=1&type=user&keyword=abc
     */
    @GetMapping("/conversations/search")
    public ResponseEntity<List<ConversationDTO>> searchConversations(
            @RequestParam Integer id,
            @RequestParam String type,
            @RequestParam String keyword) {
        log.info("GET /api/chat/conversations/search - id={}, type={}, keyword={}", id, type, keyword);
        List<ConversationDTO> conversations = chatService.searchConversations(id, type, keyword);
        return ResponseEntity.ok(conversations);
    }

    // ==================== MESSAGE ENDPOINTS ====================

    /**
     * Lấy danh sách tin nhắn của conversation
     * GET /api/chat/conversations/{conversationId}/messages
     */
    @GetMapping("/conversations/{conversationId}/messages")
    public ResponseEntity<List<ConversationMessageDTO>> getMessages(@PathVariable Integer conversationId) {
        log.info("GET /api/chat/conversations/{}/messages - Lấy tin nhắn", conversationId);
        List<ConversationMessageDTO> messages = chatService.getMessagesByConversation(conversationId);
        return ResponseEntity.ok(messages);
    }

    /**
     * Gửi tin nhắn mới
     * POST /api/chat/conversations/{conversationId}/messages
     */
    @PostMapping("/conversations/{conversationId}/messages")
    public ResponseEntity<ConversationMessageDTO> sendMessage(
            @PathVariable Integer conversationId,
            @Valid @RequestBody SendMessageRequest request) {
        log.info("POST /api/chat/conversations/{}/messages - Gửi tin nhắn từ {}",
                conversationId, request.getSenderType());
        ConversationMessageDTO message = chatService.sendMessage(conversationId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(message);
    }

    /**
     * Lấy tin nhắn mới (polling)
     * GET /api/chat/conversations/{conversationId}/messages/new?after=2024-01-01T00:00:00
     */
    @GetMapping("/conversations/{conversationId}/messages/new")
    public ResponseEntity<List<ConversationMessageDTO>> getNewMessages(
            @PathVariable Integer conversationId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime after) {
        log.info("GET /api/chat/conversations/{}/messages/new?after={} - Lấy tin nhắn mới", conversationId, after);
        List<ConversationMessageDTO> messages = chatService.getNewMessages(conversationId, after);
        return ResponseEntity.ok(messages);
    }

    /**
     * Đánh dấu đã đọc tin nhắn
     * PUT /api/chat/conversations/{conversationId}/read?readerType=user
     */
    @PutMapping("/conversations/{conversationId}/read")
    public ResponseEntity<Map<String, String>> markAsRead(
            @PathVariable Integer conversationId,
            @RequestParam String readerType) {
        log.info("PUT /api/chat/conversations/{}/read?readerType={} - Đánh dấu đã đọc", conversationId, readerType);
        chatService.markMessagesAsRead(conversationId, readerType);

        Map<String, String> response = new HashMap<>();
        response.put("message", "Đã đánh dấu tin nhắn là đã đọc");
        return ResponseEntity.ok(response);
    }

    // ==================== UNREAD COUNT ENDPOINTS ====================

    /**
     * Đếm số conversations chưa đọc
     * GET /api/chat/unread/count?id=1&type=user
     */
    @GetMapping("/unread/count")
    public ResponseEntity<Map<String, Long>> getUnreadCount(
            @RequestParam Integer id,
            @RequestParam String type) {
        log.info("GET /api/chat/unread/count?id={}&type={} - Đếm conversations chưa đọc", id, type);
        Long count = chatService.countUnreadConversations(id, type);

        Map<String, Long> response = new HashMap<>();
        response.put("unreadConversations", count);
        return ResponseEntity.ok(response);
    }

    /**
     * Tổng số tin nhắn chưa đọc
     * GET /api/chat/unread/messages?id=1&type=user
     */
    @GetMapping("/unread/messages")
    public ResponseEntity<Map<String, Long>> getUnreadMessages(
            @RequestParam Integer id,
            @RequestParam String type) {
        log.info("GET /api/chat/unread/messages?id={}&type={} - Tổng tin nhắn chưa đọc", id, type);
        Long count = chatService.sumUnreadMessages(id, type);

        Map<String, Long> response = new HashMap<>();
        response.put("unreadMessages", count);
        return ResponseEntity.ok(response);
    }

    // ==================== IMAGE UPLOAD ENDPOINT ====================

    /**
     * Upload hình ảnh cho chat
     * POST /api/chat/upload-image
     */
    @PostMapping("/upload-image")
    public ResponseEntity<Map<String, String>> uploadChatImage(
            @RequestParam("file") MultipartFile file) {
        log.info("POST /api/chat/upload-image - Upload hình ảnh chat");

        try {
            if (file == null || file.isEmpty()) {
                Map<String, String> error = new HashMap<>();
                error.put("message", "File không được để trống");
                return ResponseEntity.badRequest().body(error);
            }

            Map<String, Object> uploadResult = cloudinaryService.uploadImage(file);
            String imageUrl = (String) uploadResult.get("secure_url");

            Map<String, String> response = new HashMap<>();
            response.put("imageUrl", imageUrl);
            response.put("message", "Upload thành công");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error uploading chat image: ", e);
            Map<String, String> error = new HashMap<>();
            error.put("message", "Lỗi khi upload hình ảnh: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
}
