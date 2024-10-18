<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%!
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
String formatDate(Date date) {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd-HH:mm:ss");
    return sdf.format(date);
}
%>

<%
// 调试信息
System.out.println("JSP is executing!");
Date now = new Date();

// 设置请求编码为UTF-8
request.setCharacterEncoding("UTF-8");   

// 获取application对象中的消息列表，如果不存在则创建一个新的
List<String> messages = (List<String>)application.getAttribute("chatMessages");
if (messages == null) {
    messages = new ArrayList<String>();
    application.setAttribute("chatMessages", messages);
}

// 处理新消息
String newMessage = request.getParameter("message");
if (newMessage != null && !newMessage.trim().isEmpty()) {
    try {
        String userIp = getUserIp(request);
        String formattedMessage = String.format("[%s] %s: %s", formatDate(new Date()), userIp, newMessage);
        messages.add(formattedMessage);
        application.setAttribute("chatMessages", messages);
    } catch (Exception e) {
        System.err.println("Error processing message: " + e.getMessage());
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
        <p class="current-time">当前时间：<%= formatDate(now) %></p>
        
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

