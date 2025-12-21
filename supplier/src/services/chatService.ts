import api from "./api";

// Types
export interface ConversationDTO {
  conversationId: number;
  userId: number;
  providerId: number;
  subject?: string;
  conversationStatus: string;
  lastMessageAt?: string;
  lastMessageContent?: string;
  userUnreadCount: number;
  providerUnreadCount: number;
  createdAt: string;
  updatedAt: string;
  // Info bổ sung
  userName?: string;
  userAvatar?: string;
  providerName?: string;
  providerLogo?: string;
  providerType?: string;
}

export interface ConversationMessageDTO {
  messageId: number;
  conversationId: number;
  senderType: "user" | "provider";
  senderId: number;
  content: string;
  messageType: "text" | "image" | "file" | "system";
  imageUrl?: string;
  isRead: boolean;
  readAt?: string;
  createdAt: string;
  // Info bổ sung
  senderName?: string;
  senderAvatar?: string;
}

export interface CreateConversationRequest {
  userId: number;
  providerId: number;
  subject?: string;
}

export interface SendMessageRequest {
  senderType: "user" | "provider";
  senderId: number;
  content: string;
  messageType?: "text" | "image" | "file";
  imageUrl?: string;
}

// ==================== CONVERSATION API ====================

/**
 * Lấy danh sách conversations của provider
 */
export const getConversationsByProvider = async (
  providerId: number
): Promise<ConversationDTO[]> => {
  const response = await api.get<ConversationDTO[]>(
    `/chat/conversations/provider/${providerId}`
  );
  return response.data;
};

/**
 * Lấy chi tiết conversation
 */
export const getConversationById = async (
  conversationId: number
): Promise<ConversationDTO> => {
  const response = await api.get<ConversationDTO>(
    `/chat/conversations/${conversationId}`
  );
  return response.data;
};

/**
 * Tạo hoặc lấy conversation
 */
export const getOrCreateConversation = async (
  request: CreateConversationRequest
): Promise<ConversationDTO> => {
  const response = await api.post<ConversationDTO>(
    "/chat/conversations",
    request
  );
  return response.data;
};

/**
 * Tìm kiếm conversations
 */
export const searchConversations = async (
  id: number,
  type: "user" | "provider",
  keyword: string
): Promise<ConversationDTO[]> => {
  const response = await api.get<ConversationDTO[]>(
    "/chat/conversations/search",
    {
      params: { id, type, keyword },
    }
  );
  return response.data;
};

// ==================== MESSAGE API ====================

/**
 * Lấy danh sách tin nhắn của conversation
 */
export const getMessages = async (
  conversationId: number
): Promise<ConversationMessageDTO[]> => {
  const response = await api.get<ConversationMessageDTO[]>(
    `/chat/conversations/${conversationId}/messages`
  );
  return response.data;
};

/**
 * Gửi tin nhắn mới
 */
export const sendMessage = async (
  conversationId: number,
  request: SendMessageRequest
): Promise<ConversationMessageDTO> => {
  const response = await api.post<ConversationMessageDTO>(
    `/chat/conversations/${conversationId}/messages`,
    request
  );
  return response.data;
};

/**
 * Lấy tin nhắn mới (polling)
 */
export const getNewMessages = async (
  conversationId: number,
  afterTime: string
): Promise<ConversationMessageDTO[]> => {
  const response = await api.get<ConversationMessageDTO[]>(
    `/chat/conversations/${conversationId}/messages/new`,
    {
      params: { after: afterTime },
    }
  );
  return response.data;
};

/**
 * Đánh dấu đã đọc tin nhắn
 */
export const markAsRead = async (
  conversationId: number,
  readerType: "user" | "provider"
): Promise<void> => {
  await api.put(`/chat/conversations/${conversationId}/read`, null, {
    params: { readerType },
  });
};

// ==================== UNREAD COUNT API ====================

/**
 * Đếm số conversations chưa đọc
 */
export const getUnreadConversationsCount = async (
  id: number,
  type: "user" | "provider"
): Promise<number> => {
  const response = await api.get<{ unreadConversations: number }>(
    "/chat/unread/count",
    {
      params: { id, type },
    }
  );
  return response.data.unreadConversations;
};

/**
 * Tổng số tin nhắn chưa đọc
 */
export const getUnreadMessagesCount = async (
  id: number,
  type: "user" | "provider"
): Promise<number> => {
  const response = await api.get<{ unreadMessages: number }>(
    "/chat/unread/messages",
    {
      params: { id, type },
    }
  );
  return response.data.unreadMessages;
};
