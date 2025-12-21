import React, { useEffect, useState, useRef, useCallback } from "react";
import {
  Search,
  Send,
  Paperclip,
  MoreVertical,
  Phone,
  Video,
  ArrowLeft,
  Check,
  CheckCheck,
  Image as ImageIcon,
  Smile,
  User,
  Circle,
  RefreshCw,
} from "lucide-react";
import { useTheme } from "../../hooks/useTheme";
import { useLanguage } from "../../hooks/useLanguage";
import { getProviderByUserId } from "../../services/providerService";
import api from "../../services/api";
import type { ProviderDTO, UserDTO } from "../../types";

// Types
interface Message {
  messageId: number;
  conversationId: number;
  senderId: number;
  senderType: "user" | "provider";
  content: string;
  messageType: "text" | "image" | "file";
  imageUrl?: string;
  fileUrl?: string;
  isRead: boolean;
  createdAt: string;
}

interface Conversation {
  conversationId: number;
  userId: number;
  providerId: number;
  lastMessage?: string;
  lastMessageAt?: string;
  unreadCount: number;
  createdAt: string;
  updatedAt: string;
  // Joined data
  user?: UserDTO;
}

const MessagesPage: React.FC = () => {
  useTheme();
  const { t } = useLanguage();
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  // State
  const [loading, setLoading] = useState(true);
  const [provider, setProvider] = useState<ProviderDTO | null>(null);
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [selectedConversation, setSelectedConversation] = useState<Conversation | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [newMessage, setNewMessage] = useState("");
  const [searchQuery, setSearchQuery] = useState("");
  const [sendingMessage, setSendingMessage] = useState(false);
  const [loadingMessages, setLoadingMessages] = useState(false);
  const [isMobileView, setIsMobileView] = useState(false);
  const [showConversationList, setShowConversationList] = useState(true);

  // Handle responsive
  useEffect(() => {
    const handleResize = () => {
      setIsMobileView(window.innerWidth < 768);
    };
    handleResize();
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, []);

  // Fetch provider and conversations
  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const userStr = localStorage.getItem("user");
        if (!userStr) return;

        const user = JSON.parse(userStr);
        const providerData = await getProviderByUserId(user.userId);
        if (!providerData?.providerId) return;

        setProvider(providerData);

        // Fetch conversations
        const conversationsRes = await api.get<Conversation[]>(
          `/messages/provider/${providerData.providerId}/conversations`
        );
        
        // Fetch user info for each conversation
        const conversationsWithUsers = await Promise.all(
          conversationsRes.data.map(async (conv) => {
            try {
              const userRes = await api.get<UserDTO>(`/users/${conv.userId}`);
              return { ...conv, user: userRes.data };
            } catch {
              return { ...conv, user: undefined };
            }
          })
        );

        setConversations(conversationsWithUsers);
      } catch (error) {
        console.error("Error fetching messages data:", error);
        // Mock data for demo
        setConversations([
          {
            conversationId: 1,
            userId: 1,
            providerId: 1,
            lastMessage: "Xin chào, tôi muốn hỏi về tour Hạ Long Bay",
            lastMessageAt: new Date().toISOString(),
            unreadCount: 2,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
            user: {
              userId: 1,
              email: "customer1@example.com",
              fullName: "Nguyễn Văn A",
              avatarUrl: "",
            },
          },
          {
            conversationId: 2,
            userId: 2,
            providerId: 1,
            lastMessage: "Đã nhận được xác nhận đặt phòng, cảm ơn!",
            lastMessageAt: new Date(Date.now() - 3600000).toISOString(),
            unreadCount: 0,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
            user: {
              userId: 2,
              email: "customer2@example.com",
              fullName: "Trần Thị B",
              avatarUrl: "",
            },
          },
          {
            conversationId: 3,
            userId: 3,
            providerId: 1,
            lastMessage: "Nhà hàng có phục vụ đồ chay không ạ?",
            lastMessageAt: new Date(Date.now() - 86400000).toISOString(),
            unreadCount: 1,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
            user: {
              userId: 3,
              email: "customer3@example.com",
              fullName: "Lê Văn C",
              avatarUrl: "",
            },
          },
        ]);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  // Fetch messages for selected conversation
  const fetchMessages = useCallback(async (conversationId: number) => {
    setLoadingMessages(true);
    try {
      const messagesRes = await api.get<Message[]>(
        `/messages/conversation/${conversationId}`
      );
      setMessages(messagesRes.data);
      
      // Mark as read
      await api.patch(`/messages/conversation/${conversationId}/read`);
      
      // Update unread count
      setConversations((prev) =>
        prev.map((conv) =>
          conv.conversationId === conversationId ? { ...conv, unreadCount: 0 } : conv
        )
      );
    } catch (error) {
      console.error("Error fetching messages:", error);
      // Mock messages for demo
      setMessages([
        {
          messageId: 1,
          conversationId,
          senderId: conversationId,
          senderType: "user",
          content: "Xin chào, tôi có thắc mắc về dịch vụ của bạn",
          messageType: "text",
          isRead: true,
          createdAt: new Date(Date.now() - 3600000 * 2).toISOString(),
        },
        {
          messageId: 2,
          conversationId,
          senderId: provider?.providerId || 1,
          senderType: "provider",
          content: "Xin chào! Cảm ơn bạn đã liên hệ. Tôi có thể giúp gì cho bạn?",
          messageType: "text",
          isRead: true,
          createdAt: new Date(Date.now() - 3600000).toISOString(),
        },
        {
          messageId: 3,
          conversationId,
          senderId: conversationId,
          senderType: "user",
          content: "Tôi muốn đặt tour cho 4 người vào cuối tuần này. Còn chỗ không ạ?",
          messageType: "text",
          isRead: true,
          createdAt: new Date(Date.now() - 1800000).toISOString(),
        },
      ]);
    } finally {
      setLoadingMessages(false);
    }
  }, [provider?.providerId]);

  // Load messages when conversation is selected
  useEffect(() => {
    if (selectedConversation) {
      fetchMessages(selectedConversation.conversationId);
      if (isMobileView) {
        setShowConversationList(false);
      }
    }
  }, [selectedConversation, fetchMessages, isMobileView]);

  // Scroll to bottom when new messages
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  // Send message
  const handleSendMessage = async () => {
    if (!newMessage.trim() || !selectedConversation || !provider) return;

    setSendingMessage(true);
    const messageContent = newMessage.trim();
    setNewMessage("");

    try {
      const newMsg: Message = {
        messageId: Date.now(),
        conversationId: selectedConversation.conversationId,
        senderId: provider.providerId!,
        senderType: "provider",
        content: messageContent,
        messageType: "text",
        isRead: false,
        createdAt: new Date().toISOString(),
      };

      // Optimistic update
      setMessages((prev) => [...prev, newMsg]);

      // Send to API
      await api.post(`/messages/conversation/${selectedConversation.conversationId}`, {
        senderId: provider.providerId,
        senderType: "provider",
        content: messageContent,
        messageType: "text",
      });

      // Update conversation last message
      setConversations((prev) =>
        prev.map((conv) =>
          conv.conversationId === selectedConversation.conversationId
            ? { ...conv, lastMessage: messageContent, lastMessageAt: new Date().toISOString() }
            : conv
        )
      );
    } catch (error) {
      console.error("Error sending message:", error);
      // Message already added optimistically, so it will show
    } finally {
      setSendingMessage(false);
      inputRef.current?.focus();
    }
  };

  // Handle enter key
  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };

  // Format time
  const formatTime = (dateStr: string): string => {
    const date = new Date(dateStr);
    const now = new Date();
    const diff = now.getTime() - date.getTime();

    if (diff < 60000) return "Vừa xong";
    if (diff < 3600000) return `${Math.floor(diff / 60000)} phút trước`;
    if (diff < 86400000) return date.toLocaleTimeString("vi-VN", { hour: "2-digit", minute: "2-digit" });
    if (diff < 604800000) return date.toLocaleDateString("vi-VN", { weekday: "short", hour: "2-digit", minute: "2-digit" });
    return date.toLocaleDateString("vi-VN", { day: "2-digit", month: "2-digit", year: "numeric" });
  };

  // Filter conversations
  const filteredConversations = conversations.filter((conv) =>
    conv.user?.fullName?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    conv.lastMessage?.toLowerCase().includes(searchQuery.toLowerCase())
  );

  // Get initials
  const getInitials = (name?: string): string => {
    if (!name) return "?";
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .substring(0, 2)
      .toUpperCase();
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <div className="text-center">
          <div className="w-12 h-12 border-4 border-t-transparent theme-border rounded-full animate-spin mx-auto mb-4 border-t-emerald-500"></div>
          <p className="theme-text-secondary">{t("loading") || "Đang tải..."}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="h-[calc(100vh-180px)] flex flex-col">
      <div className="flex-1 flex overflow-hidden rounded-xl border theme-border theme-bg-card">
        {/* Conversation List */}
        <div
          className={`${
            isMobileView ? (showConversationList ? "w-full" : "hidden") : "w-80 lg:w-96"
          } flex flex-col border-r theme-border`}
        >
          {/* Header */}
          <div className="p-4 border-b theme-border">
            <h2 className="text-xl font-semibold theme-text-primary mb-4">
              {t("messages") || "Tin nhắn"}
            </h2>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 theme-text-secondary" />
              <input
                type="text"
                placeholder={t("search_conversations") || "Tìm kiếm hội thoại..."}
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-10 pr-4 py-2 rounded-lg theme-bg-secondary theme-text-primary border theme-border text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500"
              />
            </div>
          </div>

          {/* Conversation List */}
          <div className="flex-1 overflow-y-auto">
            {filteredConversations.length === 0 ? (
              <div className="text-center py-12 theme-text-secondary">
                <User className="w-12 h-12 mx-auto mb-4 opacity-50" />
                <p>{t("no_conversations") || "Chưa có cuộc hội thoại nào"}</p>
              </div>
            ) : (
              filteredConversations.map((conv) => (
                <button
                  key={conv.conversationId}
                  onClick={() => setSelectedConversation(conv)}
                  className={`w-full p-4 flex items-start gap-3 hover:theme-bg-secondary transition-colors text-left border-b theme-border ${
                    selectedConversation?.conversationId === conv.conversationId
                      ? "theme-bg-secondary"
                      : ""
                  }`}
                >
                  {/* Avatar */}
                  <div className="relative flex-shrink-0">
                    {conv.user?.avatarUrl ? (
                      <img
                        src={conv.user.avatarUrl}
                        alt={conv.user.fullName}
                        className="w-12 h-12 rounded-full object-cover"
                      />
                    ) : (
                      <div className="w-12 h-12 rounded-full bg-emerald-100 dark:bg-emerald-900/30 flex items-center justify-center text-emerald-600 font-semibold">
                        {getInitials(conv.user?.fullName)}
                      </div>
                    )}
                    {/* Online indicator */}
                    <Circle className="absolute bottom-0 right-0 w-3 h-3 text-green-500 fill-green-500" />
                  </div>

                  {/* Content */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between mb-1">
                      <h4 className="font-semibold theme-text-primary truncate">
                        {conv.user?.fullName || `Khách #${conv.userId}`}
                      </h4>
                      <span className="text-xs theme-text-secondary flex-shrink-0">
                        {formatTime(conv.lastMessageAt || conv.updatedAt)}
                      </span>
                    </div>
                    <div className="flex items-center justify-between">
                      <p className="text-sm theme-text-secondary truncate">
                        {conv.lastMessage || "Bắt đầu cuộc trò chuyện"}
                      </p>
                      {conv.unreadCount > 0 && (
                        <span className="ml-2 px-2 py-0.5 text-xs font-medium bg-emerald-500 text-white rounded-full">
                          {conv.unreadCount}
                        </span>
                      )}
                    </div>
                  </div>
                </button>
              ))
            )}
          </div>
        </div>

        {/* Chat Area */}
        <div
          className={`flex-1 flex flex-col ${
            isMobileView && showConversationList ? "hidden" : ""
          }`}
        >
          {selectedConversation ? (
            <>
              {/* Chat Header */}
              <div className="p-4 border-b theme-border flex items-center justify-between">
                <div className="flex items-center gap-3">
                  {isMobileView && (
                    <button
                      onClick={() => setShowConversationList(true)}
                      className="p-2 rounded-lg hover:theme-bg-secondary transition-colors"
                    >
                      <ArrowLeft className="w-5 h-5" />
                    </button>
                  )}
                  {selectedConversation.user?.avatarUrl ? (
                    <img
                      src={selectedConversation.user.avatarUrl}
                      alt={selectedConversation.user.fullName}
                      className="w-10 h-10 rounded-full object-cover"
                    />
                  ) : (
                    <div className="w-10 h-10 rounded-full bg-emerald-100 dark:bg-emerald-900/30 flex items-center justify-center text-emerald-600 font-semibold">
                      {getInitials(selectedConversation.user?.fullName)}
                    </div>
                  )}
                  <div>
                    <h3 className="font-semibold theme-text-primary">
                      {selectedConversation.user?.fullName || `Khách #${selectedConversation.userId}`}
                    </h3>
                    <p className="text-xs text-green-500 flex items-center gap-1">
                      <Circle className="w-2 h-2 fill-green-500" />
                      {t("online") || "Đang hoạt động"}
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <button className="p-2 rounded-lg hover:theme-bg-secondary transition-colors theme-text-secondary">
                    <Phone className="w-5 h-5" />
                  </button>
                  <button className="p-2 rounded-lg hover:theme-bg-secondary transition-colors theme-text-secondary">
                    <Video className="w-5 h-5" />
                  </button>
                  <button className="p-2 rounded-lg hover:theme-bg-secondary transition-colors theme-text-secondary">
                    <MoreVertical className="w-5 h-5" />
                  </button>
                </div>
              </div>

              {/* Messages */}
              <div className="flex-1 overflow-y-auto p-4 space-y-4">
                {loadingMessages ? (
                  <div className="flex items-center justify-center h-full">
                    <RefreshCw className="w-6 h-6 animate-spin theme-text-secondary" />
                  </div>
                ) : messages.length === 0 ? (
                  <div className="text-center py-12 theme-text-secondary">
                    <p>{t("no_messages") || "Chưa có tin nhắn nào"}</p>
                    <p className="text-sm mt-2">{t("start_conversation") || "Hãy bắt đầu cuộc trò chuyện!"}</p>
                  </div>
                ) : (
                  <>
                    {messages.map((message, index) => {
                      const isProvider = message.senderType === "provider";
                      const showAvatar =
                        index === 0 ||
                        messages[index - 1].senderType !== message.senderType;

                      return (
                        <div
                          key={message.messageId}
                          className={`flex items-end gap-2 ${isProvider ? "flex-row-reverse" : ""}`}
                        >
                          {/* Avatar */}
                          {!isProvider && showAvatar ? (
                            selectedConversation.user?.avatarUrl ? (
                              <img
                                src={selectedConversation.user.avatarUrl}
                                alt=""
                                className="w-8 h-8 rounded-full object-cover"
                              />
                            ) : (
                              <div className="w-8 h-8 rounded-full bg-gray-200 dark:bg-gray-700 flex items-center justify-center text-xs font-semibold theme-text-secondary">
                                {getInitials(selectedConversation.user?.fullName)}
                              </div>
                            )
                          ) : (
                            <div className="w-8" />
                          )}

                          {/* Message */}
                          <div
                            className={`max-w-[70%] ${
                              isProvider
                                ? "bg-emerald-500 text-white rounded-2xl rounded-br-md"
                                : "theme-bg-secondary theme-text-primary rounded-2xl rounded-bl-md"
                            } px-4 py-2`}
                          >
                            {message.messageType === "image" && message.imageUrl && (
                              <img
                                src={message.imageUrl}
                                alt=""
                                className="max-w-full rounded-lg mb-2"
                              />
                            )}
                            <p className="text-sm whitespace-pre-wrap">{message.content}</p>
                            <div
                              className={`flex items-center gap-1 mt-1 text-xs ${
                                isProvider ? "text-emerald-100 justify-end" : "theme-text-secondary"
                              }`}
                            >
                              <span>{formatTime(message.createdAt)}</span>
                              {isProvider && (
                                message.isRead ? (
                                  <CheckCheck className="w-3 h-3" />
                                ) : (
                                  <Check className="w-3 h-3" />
                                )
                              )}
                            </div>
                          </div>
                        </div>
                      );
                    })}
                    <div ref={messagesEndRef} />
                  </>
                )}
              </div>

              {/* Input Area */}
              <div className="p-4 border-t theme-border">
                <div className="flex items-center gap-2">
                  <button className="p-2 rounded-lg hover:theme-bg-secondary transition-colors theme-text-secondary">
                    <Paperclip className="w-5 h-5" />
                  </button>
                  <button className="p-2 rounded-lg hover:theme-bg-secondary transition-colors theme-text-secondary">
                    <ImageIcon className="w-5 h-5" />
                  </button>
                  <div className="flex-1 relative">
                    <input
                      ref={inputRef}
                      type="text"
                      value={newMessage}
                      onChange={(e) => setNewMessage(e.target.value)}
                      onKeyPress={handleKeyPress}
                      placeholder={t("type_message") || "Nhập tin nhắn..."}
                      className="w-full px-4 py-2 pr-10 rounded-full theme-bg-secondary theme-text-primary border theme-border text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500"
                      disabled={sendingMessage}
                    />
                    <button className="absolute right-3 top-1/2 -translate-y-1/2 theme-text-secondary hover:theme-text-primary">
                      <Smile className="w-5 h-5" />
                    </button>
                  </div>
                  <button
                    onClick={handleSendMessage}
                    disabled={!newMessage.trim() || sendingMessage}
                    className="p-3 rounded-full bg-emerald-500 text-white hover:bg-emerald-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <Send className="w-5 h-5" />
                  </button>
                </div>
              </div>
            </>
          ) : (
            <div className="flex-1 flex items-center justify-center theme-text-secondary">
              <div className="text-center">
                <div className="w-24 h-24 mx-auto mb-6 rounded-full bg-emerald-100 dark:bg-emerald-900/30 flex items-center justify-center">
                  <User className="w-12 h-12 text-emerald-600" />
                </div>
                <h3 className="text-xl font-semibold theme-text-primary mb-2">
                  {t("select_conversation") || "Chọn một cuộc hội thoại"}
                </h3>
                <p className="text-sm">
                  {t("select_conversation_desc") || "Chọn một khách hàng để bắt đầu trò chuyện"}
                </p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default MessagesPage;
