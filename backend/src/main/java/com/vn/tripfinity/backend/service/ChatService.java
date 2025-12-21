package com.vn.tripfinity.backend.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.ConversationDTO;
import com.vn.tripfinity.backend.dto.ConversationMessageDTO;
import com.vn.tripfinity.backend.dto.CreateConversationRequest;
import com.vn.tripfinity.backend.dto.SendMessageRequest;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Conversation;
import com.vn.tripfinity.backend.model.ConversationMessage;
import com.vn.tripfinity.backend.model.Provider;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.ConversationMessageRepository;
import com.vn.tripfinity.backend.repository.ConversationRepository;
import com.vn.tripfinity.backend.repository.ProviderRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class ChatService {

    private final ConversationRepository conversationRepository;
    private final ConversationMessageRepository messageRepository;
    private final UserRepository userRepository;
    private final ProviderRepository providerRepository;

    /**
     * Tạo conversation mới hoặc lấy conversation đã tồn tại giữa user và provider
     */
    public ConversationDTO getOrCreateConversation(CreateConversationRequest request) {
        log.debug("Get or create conversation: userId={}, providerId={}", request.getUserId(), request.getProviderId());

        // Kiểm tra user và provider tồn tại
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + request.getUserId()));
        Provider provider = providerRepository.findById(request.getProviderId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + request.getProviderId()));

        // Tìm conversation đã tồn tại
        Optional<Conversation> existingConversation = conversationRepository
                .findByUser_UserIdAndProvider_ProviderId(request.getUserId(), request.getProviderId());

        if (existingConversation.isPresent()) {
            log.info("Tìm thấy conversation đã tồn tại: {}", existingConversation.get().getConversationId());
            return convertToDTO(existingConversation.get());
        }

        // Tạo conversation mới
        Conversation newConversation = Conversation.builder()
                .user(user)
                .provider(provider)
                .subject(request.getSubject() != null ? request.getSubject() : "Cuộc trò chuyện với " + provider.getCompanyName())
                .conversationStatus(Conversation.ConversationStatus.active)
                .userUnreadCount(0)
                .providerUnreadCount(0)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        newConversation = conversationRepository.save(newConversation);
        log.info("Tạo conversation mới: {}", newConversation.getConversationId());

        return convertToDTO(newConversation);
    }

    /**
     * Lấy danh sách conversations của user
     */
    @Transactional(readOnly = true)
    public List<ConversationDTO> getConversationsByUser(Integer userId) {
        log.debug("Lấy danh sách conversations của User ID: {}", userId);
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + userId));

        List<Conversation> conversations = conversationRepository.findByUserIdOrderByLastMessageDesc(userId);
        log.info("Tìm thấy {} conversations của User ID: {}", conversations.size(), userId);

        return conversations.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Lấy danh sách conversations của provider
     */
    @Transactional(readOnly = true)
    public List<ConversationDTO> getConversationsByProvider(Integer providerId) {
        log.debug("Lấy danh sách conversations của Provider ID: {}", providerId);
        providerRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Provider id: " + providerId));

        List<Conversation> conversations = conversationRepository.findByProviderIdOrderByLastMessageDesc(providerId);
        log.info("Tìm thấy {} conversations của Provider ID: {}", conversations.size(), providerId);

        return conversations.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Lấy chi tiết conversation
     */
    @Transactional(readOnly = true)
    public ConversationDTO getConversationById(Integer conversationId) {
        log.debug("Lấy conversation theo ID: {}", conversationId);
        Conversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Conversation id: " + conversationId));
        return convertToDTO(conversation);
    }

    /**
     * Lấy danh sách tin nhắn của conversation
     */
    @Transactional(readOnly = true)
    public List<ConversationMessageDTO> getMessagesByConversation(Integer conversationId) {
        log.debug("Lấy tin nhắn của Conversation ID: {}", conversationId);
        conversationRepository.findById(conversationId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Conversation id: " + conversationId));

        List<ConversationMessage> messages = messageRepository
                .findByConversation_ConversationIdOrderByCreatedAtAsc(conversationId);
        log.info("Tìm thấy {} tin nhắn của Conversation ID: {}", messages.size(), conversationId);

        return messages.stream()
                .map(this::convertMessageToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Gửi tin nhắn mới
     */
    public ConversationMessageDTO sendMessage(Integer conversationId, SendMessageRequest request) {
        log.debug("Gửi tin nhắn mới tới Conversation ID: {}", conversationId);

        Conversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Conversation id: " + conversationId));

        // Tạo tin nhắn mới
        ConversationMessage message = ConversationMessage.builder()
                .conversation(conversation)
                .senderType(ConversationMessage.SenderType.valueOf(request.getSenderType()))
                .senderId(request.getSenderId())
                .content(request.getContent())
                .messageType(request.getMessageType() != null
                        ? ConversationMessage.MessageType.valueOf(request.getMessageType())
                        : ConversationMessage.MessageType.text)
                .imageUrl(request.getImageUrl())
                .isRead(false)
                .createdAt(LocalDateTime.now())
                .build();

        message = messageRepository.save(message);

        // Cập nhật conversation
        conversation.setLastMessageAt(LocalDateTime.now());
        conversation.setLastMessagePreview(request.getContent().length() > 255 
                ? request.getContent().substring(0, 252) + "..." 
                : request.getContent());
        conversation.setUpdatedAt(LocalDateTime.now());

        // Cập nhật unread count
        if (request.getSenderType().equals("user")) {
            conversation.setProviderUnreadCount(conversation.getProviderUnreadCount() + 1);
        } else {
            conversation.setUserUnreadCount(conversation.getUserUnreadCount() + 1);
        }

        conversationRepository.save(conversation);

        log.info("Đã gửi tin nhắn ID: {} tới Conversation ID: {}", message.getMessageId(), conversationId);
        return convertMessageToDTO(message);
    }

    /**
     * Đánh dấu đã đọc tin nhắn
     */
    public void markMessagesAsRead(Integer conversationId, String readerType) {
        log.debug("Đánh dấu đã đọc tin nhắn của Conversation ID: {} bởi {}", conversationId, readerType);

        Conversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Conversation id: " + conversationId));

        ConversationMessage.SenderType senderType = ConversationMessage.SenderType.valueOf(readerType);
        int updatedCount = messageRepository.markAllAsRead(conversationId, senderType, LocalDateTime.now());

        // Reset unread count
        if (readerType.equals("user")) {
            conversation.setUserUnreadCount(0);
        } else {
            conversation.setProviderUnreadCount(0);
        }
        conversationRepository.save(conversation);

        log.info("Đã đánh dấu {} tin nhắn là đã đọc trong Conversation ID: {}", updatedCount, conversationId);
    }

    /**
     * Lấy tin nhắn mới (polling)
     */
    @Transactional(readOnly = true)
    public List<ConversationMessageDTO> getNewMessages(Integer conversationId, LocalDateTime afterTime) {
        log.debug("Lấy tin nhắn mới sau {} của Conversation ID: {}", afterTime, conversationId);
        conversationRepository.findById(conversationId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Conversation id: " + conversationId));

        List<ConversationMessage> messages = messageRepository.findMessagesAfter(conversationId, afterTime);
        return messages.stream()
                .map(this::convertMessageToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Đếm số conversations chưa đọc
     */
    @Transactional(readOnly = true)
    public Long countUnreadConversations(Integer id, String type) {
        if (type.equals("user")) {
            return conversationRepository.countUnreadConversationsByUser(id);
        } else {
            return conversationRepository.countUnreadConversationsByProvider(id);
        }
    }

    /**
     * Tổng số tin nhắn chưa đọc
     */
    @Transactional(readOnly = true)
    public Long sumUnreadMessages(Integer id, String type) {
        if (type.equals("user")) {
            return conversationRepository.sumUnreadMessagesByUser(id);
        } else {
            return conversationRepository.sumUnreadMessagesByProvider(id);
        }
    }

    /**
     * Tìm kiếm conversations
     */
    @Transactional(readOnly = true)
    public List<ConversationDTO> searchConversations(Integer id, String type, String keyword) {
        List<Conversation> conversations;
        if (type.equals("user")) {
            conversations = conversationRepository.searchByUserAndKeyword(id, keyword);
        } else {
            conversations = conversationRepository.searchByProviderAndKeyword(id, keyword);
        }
        return conversations.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    // ==================== HELPER METHODS ====================

    private ConversationDTO convertToDTO(Conversation conversation) {
        return ConversationDTO.builder()
                .conversationId(conversation.getConversationId())
                .userId(conversation.getUser().getUserId())
                .providerId(conversation.getProvider().getProviderId())
                .subject(conversation.getSubject())
                .conversationStatus(conversation.getConversationStatus().name())
                .lastMessageAt(conversation.getLastMessageAt())
                .lastMessageContent(conversation.getLastMessagePreview())
                .userUnreadCount(conversation.getUserUnreadCount())
                .providerUnreadCount(conversation.getProviderUnreadCount())
                .createdAt(conversation.getCreatedAt())
                .updatedAt(conversation.getUpdatedAt())
                // User info
                .userName(conversation.getUser().getFullName())
                .userAvatar(conversation.getUser().getAvatarUrl())
                // Provider info
                .providerName(conversation.getProvider().getCompanyName())
                .providerLogo(conversation.getProvider().getLogoUrl())
                .providerType(null) // Provider không có providerType
                .build();
    }

    private ConversationMessageDTO convertMessageToDTO(ConversationMessage message) {
        String senderName = null;
        String senderAvatar = null;

        // Lấy thông tin sender
        if (message.getSenderType() == ConversationMessage.SenderType.user) {
            Optional<User> user = userRepository.findById(message.getSenderId());
            if (user.isPresent()) {
                senderName = user.get().getFullName();
                senderAvatar = user.get().getAvatarUrl();
            }
        } else {
            Optional<Provider> provider = providerRepository.findById(message.getSenderId());
            if (provider.isPresent()) {
                senderName = provider.get().getCompanyName();
                senderAvatar = provider.get().getLogoUrl();
            }
        }

        return ConversationMessageDTO.builder()
                .messageId(message.getMessageId())
                .conversationId(message.getConversation().getConversationId())
                .senderType(message.getSenderType().name())
                .senderId(message.getSenderId())
                .content(message.getContent())
                .messageType(message.getMessageType().name())
                .imageUrl(message.getImageUrl())
                .isRead(message.getIsRead())
                .readAt(message.getReadAt())
                .createdAt(message.getCreatedAt())
                .senderName(senderName)
                .senderAvatar(senderAvatar)
                .build();
    }
}
