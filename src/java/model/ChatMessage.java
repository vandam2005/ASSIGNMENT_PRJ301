package model;

import java.sql.Timestamp;

public class ChatMessage {

    private int messageId;
    private int guestId;
    private String senderRole;   // "guest" or "staff"
    private String senderName;
    private String content;
    private Timestamp sentAt;
    private boolean isRead;

    public ChatMessage() {}

    public ChatMessage(int guestId, String senderRole, String senderName, String content) {
        this.guestId = guestId;
        this.senderRole = senderRole;
        this.senderName = senderName;
        this.content = content;
    }

    public int getMessageId() { return messageId; }
    public void setMessageId(int messageId) { this.messageId = messageId; }

    public int getGuestId() { return guestId; }
    public void setGuestId(int guestId) { this.guestId = guestId; }

    public String getSenderRole() { return senderRole; }
    public void setSenderRole(String senderRole) { this.senderRole = senderRole; }

    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Timestamp getSentAt() { return sentAt; }
    public void setSentAt(Timestamp sentAt) { this.sentAt = sentAt; }

    public boolean isIsRead() { return isRead; }
    public void setIsRead(boolean isRead) { this.isRead = isRead; }
}