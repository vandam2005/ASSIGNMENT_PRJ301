package controller.chat;

import dal.ChatDAO;
import dal.GuestDAO;
import model.ChatMessage;
import model.Guest;
import model.Employee;

import jakarta.websocket.*;
import jakarta.websocket.server.ServerEndpoint;
import jakarta.websocket.server.PathParam;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@ServerEndpoint(
        value = "/ChatWS/{role}/{guestId}",
        configurator = HttpSessionConfigurator.class
)
public class ChatWebSocket {

    private static final Map<Integer, Session> guestSessions = new ConcurrentHashMap<>();
    private static final Map<Integer, Set<Session>> staffSessions = new ConcurrentHashMap<>();
    private static final Set<Session> staffAllSessions = Collections.synchronizedSet(new HashSet<>());

    @OnOpen
    public void onOpen(Session session, @PathParam("role") String role, @PathParam("guestId") String guestIdStr) {
        HttpSession httpSession = (HttpSession) session.getUserProperties().get("httpSession");
        if (httpSession == null || httpSession.getAttribute("account") == null) {
            closeQuietly(session);
            return;
        }

        if ("guest".equals(role)) {
            Guest g = getGuest(httpSession);
            if (g == null) {
                closeQuietly(session);
                return;
            }
            int gid = g.getGuestId();
            guestSessions.put(gid, session);
            session.getUserProperties().put("guestId", gid);
            sendHistory(session, gid);

        } else if ("staff".equals(role)) {
            Employee emp = getEmployee(httpSession);
            if (emp == null || emp.getRoleId() != 2) {
                closeQuietly(session);
                return;
            }

            if ("all".equals(guestIdStr)) {
                staffAllSessions.add(session);
                session.getUserProperties().put("staffAll", true);
                // Gửi danh sách guest đã từng nhắn tin (từ DB)
                sendGuestList(session);

            } else {
                try {
                    int gid = Integer.parseInt(guestIdStr);
                    staffSessions.computeIfAbsent(gid, k -> Collections.synchronizedSet(new HashSet<>())).add(session);
                    session.getUserProperties().put("guestId", gid);
                    session.getUserProperties().put("staffName", emp.getUsername());
                    sendHistory(session, gid);
                    new ChatDAO().markRead(gid);
                    // Thông báo cho guest
                    // Thông báo cho guest
                    Session gs = guestSessions.get(gid);
                    if (gs != null && gs.isOpen()) {
                        sendJson(gs, "{\"type\":\"system\",\"content\":\"Nhan vien da ket noi. Chung toi san sang ho tro ban!\"}");
                    }
                } catch (NumberFormatException e) {
                    closeQuietly(session);
                }
            }
        }
    }

    @OnMessage
    public void onMessage(String text, Session session) {
        if (text == null || text.trim().isEmpty()) {
            return;
        }

        Object gidObj = session.getUserProperties().get("guestId");
        Boolean isAll = (Boolean) session.getUserProperties().get("staffAll");

        if (gidObj == null && isAll == null) {
            return;
        }

        // --- Tin từ Guest ---
        if (gidObj != null && !session.getUserProperties().containsKey("staffName")) {
            int gid = (int) gidObj;
            HttpSession hs = (HttpSession) session.getUserProperties().get("httpSession");
            Guest g = getGuest(hs);
            if (g == null) {
                return;
            }

            String content = sanitize(text);
            new ChatDAO().save(new ChatMessage(gid, "guest", g.getName(), content));
            String json = buildMsg("guest", g.getName(), content);

            sendJson(session, json);   // echo lại guest

            // Gửi tới staff đang mở tab chat với guest này
            Set<Session> ss = staffSessions.get(gid);
            if (ss != null) {
                ss.removeIf(s -> !s.isOpen());
                ss.forEach(s -> sendJson(s, json));
            }

            // Notify staff "all"
            staffAllSessions.removeIf(s -> !s.isOpen());
            String notif = buildNotif(gid, g.getName(), content);
            staffAllSessions.forEach(s -> sendJson(s, notif));
        } // --- Tin từ Staff ---
        else if (gidObj != null && session.getUserProperties().containsKey("staffName")) {
            int gid = (int) gidObj;
            String staffName = (String) session.getUserProperties().get("staffName");
            String content = sanitize(text);
            new ChatDAO().save(new ChatMessage(gid, "staff", staffName, content));
            String json = buildMsg("staff", staffName, content);

            // Gửi cho guest
            Session gs = guestSessions.get(gid);
            if (gs != null && gs.isOpen()) {
                sendJson(gs, json);
            }

            // Echo cho tất cả staff đang xem chat này
            Set<Session> ss = staffSessions.get(gid);
            if (ss != null) {
                ss.removeIf(s -> !s.isOpen());
                ss.forEach(s -> sendJson(s, json));
            }
        }
    }

    @OnClose
    public void onClose(Session session) {
        Object gidObj = session.getUserProperties().get("guestId");
        Boolean isAll = (Boolean) session.getUserProperties().get("staffAll");
        if (isAll != null) {
            staffAllSessions.remove(session);
        } else if (gidObj != null) {
            int gid = (int) gidObj;
            guestSessions.remove(gid, session);
            Set<Session> ss = staffSessions.get(gid);
            if (ss != null) {
                ss.remove(session);
                if (ss.isEmpty()) {
                    staffSessions.remove(gid);
                }
            }
        }
    }

    @OnError
    public void onError(Session session, Throwable t) {
        onClose(session);
    }

    // ---- Helpers ----
    /**
     * Gửi toàn bộ danh sách guest có tin nhắn trong DB cho staff "all" khi họ
     * mở trang
     */
    private void sendGuestList(Session staffSession) {
        GuestDAO guestDAO = new GuestDAO();
        ChatDAO chatDAO = new ChatDAO();
        List<int[]> rows = chatDAO.getGuestsWithMessages(); // [guestId, unread]

        for (int[] row : rows) {
            int gid = row[0];
            int unread = row[1];
            Guest g = guestDAO.getById(gid);
            if (g == null) {
                continue;
            }

            List<ChatMessage> hist = chatDAO.getHistory(gid);
            String preview = hist.isEmpty() ? "" : hist.get(hist.size() - 1).getContent();

            if (preview.length() > 40) {
                preview = preview.substring(0, 40) + "...";
            }

            String json = "{\"type\":\"init_guest\","
                    + "\"guestId\":" + gid + ","
                    + "\"guestName\":\"" + escJson(g.getName()) + "\","
                    + "\"preview\":\"" + escJson(preview) + "\","
                    + "\"unread\":" + unread + "}";

            sendJson(staffSession, json);
        }
    }

    private void sendHistory(Session session, int guestId) {
        List<ChatMessage> history = new ChatDAO().getHistory(guestId);

        StringBuilder sb = new StringBuilder("{\"type\":\"history\",\"messages\":[");

        for (int i = 0; i < history.size(); i++) {
            ChatMessage m = history.get(i);
            if (i > 0) {
                sb.append(",");
            }

            sb.append("{\"role\":\"").append(escJson(m.getSenderRole())).append("\",")
                    .append("\"name\":\"").append(escJson(m.getSenderName())).append("\",")
                    .append("\"content\":\"").append(escJson(m.getContent())).append("\",")
                    .append("\"time\":\"").append(formatTime(m.getSentAt())).append("\"}");
        }

        sb.append("]}");

        sendJson(session, sb.toString());
    }

    private String buildMsg(String role, String name, String content) {
        String time = new java.text.SimpleDateFormat("HH:mm").format(new java.util.Date());

        return "{\"type\":\"message\","
                + "\"role\":\"" + escJson(role) + "\","
                + "\"name\":\"" + escJson(name) + "\","
                + "\"content\":\"" + escJson(content) + "\","
                + "\"time\":\"" + time + "\"}";
    }

    private String buildNotif(int gid, String name, String preview) {
        String p = preview.length() > 40 ? preview.substring(0, 40) + "..." : preview;

        return "{\"type\":\"notif\","
                + "\"guestId\":" + gid + ","
                + "\"guestName\":\"" + escJson(name) + "\","
                + "\"preview\":\"" + escJson(p) + "\"}";
    }

    private void sendJson(Session s, String json) {
        try {
            if (s != null && s.isOpen()) {
                s.getBasicRemote().sendText(json);
            }
        } catch (IOException e) {
            /* ignore */ }
    }

    private void closeQuietly(Session s) {
        try {
            s.close();
        } catch (IOException e) {
            /* ignore */ }
    }

    private String sanitize(String s) {
        String t = s.trim();
        return t.substring(0, Math.min(t.length(), 1000));
    }

    private String escJson(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }

    private String formatTime(java.sql.Timestamp ts) {
        if (ts == null) {
            return "";
        }
        return new java.text.SimpleDateFormat("HH:mm").format(ts);
    }

    private Guest getGuest(HttpSession hs) {
        Object acc = hs.getAttribute("account");
        return acc instanceof Guest ? (Guest) acc : null;
    }

    private Employee getEmployee(HttpSession hs) {
        Object acc = hs.getAttribute("account");
        return acc instanceof Employee ? (Employee) acc : null;
    }
}
