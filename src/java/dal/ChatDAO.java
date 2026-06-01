package dal;

import model.ChatMessage;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ChatDAO extends DBContext {

    // Lưu tin nhắn vào DB
    public void save(ChatMessage msg) {
        String sql = "INSERT INTO ChatMessages (guestId, senderRole, senderName, content) VALUES (?, ?, ?, ?)";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, msg.getGuestId());
            stm.setString(2, msg.getSenderRole());
            stm.setString(3, msg.getSenderName());
            stm.setString(4, msg.getContent());
            stm.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Lấy lịch sử chat của 1 guest (50 tin gần nhất)
    public List<ChatMessage> getHistory(int guestId) {
        List<ChatMessage> list = new ArrayList<>();
        String sql = "SELECT TOP 50 * FROM ChatMessages WHERE guestId = ? ORDER BY sentAt ASC";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, guestId);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                ChatMessage m = new ChatMessage();
                m.setMessageId(rs.getInt("messageId"));
                m.setGuestId(rs.getInt("guestId"));
                m.setSenderRole(rs.getString("senderRole"));
                m.setSenderName(rs.getString("senderName"));
                m.setContent(rs.getString("content"));
                m.setSentAt(rs.getTimestamp("sentAt"));
                m.setIsRead(rs.getBoolean("isRead"));
                list.add(m);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Đếm tin chưa đọc của 1 guest (Staff dùng để hiện badge)
    public int countUnread(int guestId) {
        String sql = "SELECT COUNT(*) FROM ChatMessages WHERE guestId = ? AND senderRole = 'guest' AND isRead = 0";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, guestId);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Đánh dấu đã đọc khi Staff mở chat với guest này
    public void markRead(int guestId) {
        String sql = "UPDATE ChatMessages SET isRead = 1 WHERE guestId = ? AND senderRole = 'guest'";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, guestId);
            stm.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Lấy danh sách guest có tin nhắn (Staff dùng để hiện danh sách)
    public List<int[]> getGuestsWithMessages() {
        // Trả về [guestId, unreadCount]
        List<int[]> list = new ArrayList<>();
String sql = "SELECT guestId, SUM(CASE WHEN senderRole='guest' AND isRead=0 THEN 1 ELSE 0 END) as unread "
                   + "FROM ChatMessages GROUP BY guestId ORDER BY MAX(sentAt) DESC";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                list.add(new int[]{ rs.getInt("guestId"), rs.getInt("unread") });
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}