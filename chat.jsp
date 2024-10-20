<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.ParseException" %>

<%!
// 数据库连接信息
private static final String JDBC_DRIVER = "com.mysql.jdbc.Driver";
private static final String DB_URL = "jdbc:mysql://172.18.0.1:3306/demo2?useUnicode=true&characterEncoding=utf8&createDatabaseIfNotExist=true";
private static final String USER = "tomcatUser";
private static final String PASS = "O12b.aZc!nUF7fd";

// 获取用户真实 IP 的函数
String getUserIp(HttpServletRequest request) {
    String ip = request.getHeader("X-Forwarded-For");
    if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
        ip = request.getHeader("Proxy-Client-IP");
    }
    if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
        ip = request.getHeader("WL-Proxy-Client-IP");
    }
    if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
        ip = request.getHeader("HTTP_CLIENT_IP");
    }
    if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
        ip = request.getHeader("HTTP_X_FORWARDED_FOR");
    }
    if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
        ip = request.getRemoteAddr();
    }
    return ip;
}

// 格式化日期的函数
String formatDate(java.util.Date date) {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    return sdf.format(date);
}

// 格式化时间的函数
String formatTime(java.util.Date date) {
    SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
    return sdf.format(date);
}

// 创建数据库表的函数
void createTableIfNotExists(Connection conn) throws SQLException {
    String sql = "CREATE TABLE IF NOT EXISTS messages (" +
                 "id INT AUTO_INCREMENT PRIMARY KEY," +
                 "date VARCHAR(8)," +
                 "time VARCHAR(8)," +  // Changed from VARCHAR(6) to VARCHAR(8) to accommodate HH:mm:ss format
                 "ip VARCHAR(15)," +
                 "message TEXT" +
                 ")";
    try (Statement stmt = conn.createStatement()) {
        stmt.execute(sql);
    }
}

// 保存消息到数据库的函数
void saveMessage(Connection conn, String date, String time, String ip, String message) throws SQLException {
    String sql = "INSERT INTO messages (date, time, ip, message) VALUES (?, ?, ?, ?)";
    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
        pstmt.setString(1, date);
        pstmt.setString(2, eightToSixDigitTime(time)); // Convert to 6-digit before saving
        pstmt.setString(3, ip);
        pstmt.setString(4, message);
        pstmt.executeUpdate();
    }
}

// 从数据库读取所有消息的函数
List<String> getAllMessages(Connection conn) throws SQLException {
    List<String> messages = new ArrayList<>();
    String sql = "SELECT date, time, ip, message FROM messages ORDER BY id ASC";
    try (Statement stmt = conn.createStatement();
         ResultSet rs = stmt.executeQuery(sql)) {
        while (rs.next()) {
            String date = rs.getString("date");
            String time = sixToEightDigitTime(rs.getString("time")); // Convert to 8-digit after retrieval
            String ip = rs.getString("ip");
            String message = rs.getString("message");
            String formattedMessage = formatMessage(time, ip, message);
            messages.add(formattedMessage);
        }
    }
    return messages;
}

// Modified formatMessage function
public String formatMessage(String time, String ip, String message) {
    return String.format("[%s][%s]: %s", time, ip, message);
}

// Convert 6-digit time to 8-digit time
String sixToEightDigitTime(String sixDigitTime) {
    if (sixDigitTime == null || sixDigitTime.length() != 6) {
        return sixDigitTime; // Return as-is if not in expected format
    }
    return sixDigitTime.substring(0, 2) + ":" + sixDigitTime.substring(2, 4) + ":" + sixDigitTime.substring(4);
}

// Convert 8-digit time to 6-digit time
String eightToSixDigitTime(String eightDigitTime) {
    return eightDigitTime.replace(":", "");
}
%>

<%
request.setCharacterEncoding("UTF-8");
System.out.println("JSP is executing!");
Date now = new Date();

Connection conn = null;
List<String> messages = new ArrayList<>();

try {
    Class.forName(JDBC_DRIVER);
    conn = DriverManager.getConnection(DB_URL, USER, PASS);
    
    createTableIfNotExists(conn);
    
    // 处理新消息
    String newMessage = request.getParameter("message");
    String userIp = getUserIp(request);

    if (newMessage != null && !newMessage.trim().isEmpty()) {
        String currentDate = formatDate(now);
        String currentTime = formatTime(now); // This will now return HH:mm:ss format
        saveMessage(conn, currentDate, currentTime, userIp, newMessage);
    }
    
    messages = getAllMessages(conn);
} catch(SQLException se) {
    se.printStackTrace();
} catch(Exception e) {
    e.printStackTrace();
} finally {
    try {
        if(conn != null) conn.close();
    } catch(SQLException se) {
        se.printStackTrace();
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>简单聊天室</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            line-height: 1.6;
        }
        .chat-container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #f9f9f9;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .current-time {
            text-align: center;
            color: #666;
            margin-bottom: 20px;
        }
        .chat-messages {
            height: 300px;
            overflow-y: auto;
            border: 1px solid #ddd;
            padding: 10px;
            margin-bottom: 20px;
            background-color: #fff;
        }
        .chat-messages li {
            margin-bottom: 10px;
            list-style-type: none;
        }
        .chat-form {
            display: flex;
        }
        .chat-form input[type="text"] {
            flex-grow: 1;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px 0 0 4px;
        }
        .chat-form input[type="submit"] {
            padding: 10px 20px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 0 4px 4px 0;
            cursor: pointer;
        }
        @media (max-width: 480px) {
            body {
                padding: 10px;
            }
            .chat-container {
                padding: 10px;
            }
            .chat-messages {
                height: 250px;
            }
            .chat-form {
                flex-direction: column;
            }
            .chat-form input[type="text"],
            .chat-form input[type="submit"] {
                width: 100%;
                border-radius: 4px;
                margin-bottom: 10px;
            }
        }
    </style>
</head>
<body>
    <div class="chat-container">
        <h1>简单聊天室</h1>
        <p class="current-time">当前时间：<%= formatDate(now) %>-<%= formatTime(now) %></p>
        
        <div class="chat-messages">
            <ul>
            <% for (String msg : messages) { %>
                <li><%= msg %></li>
            <% } %>
            </ul>
        </div>
        
        <form class="chat-form" action="chat.jsp" method="post">
            <input type="text" name="message" placeholder="输入您的消息" required>
            <input type="submit" value="发送">
        </form>
    </div>
</body>
</html>
