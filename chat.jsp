<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
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
%>

<%
// 调试信息
System.out.println("JSP is executing!");
Date now = new Date();
%>

<%
// 设置请求编码为UTF-8
request.setCharacterEncoding("UTF-8");   
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>简单聊天室</title>
</head>
<body>
    <h1>简单聊天室</h1>
    <p>当前时间：<%= now %></p>
    <%
    // 获取application对象中的消息列表，如果不存在则创建一个新的
    List<String> messages = (List<String>)application.getAttribute("chatMessages");
    if (messages == null) {
        messages = new ArrayList<String>();
        application.setAttribute("chatMessages", messages);
    }
    
    // 处理新消息
    String newMessage = request.getParameter("message");
    if (newMessage != null && !newMessage.trim().isEmpty()) {
        String userIp = getUserIp(request);
        String formattedMessage = String.format("[%s] %s: %s", new Date(), userIp, newMessage);
        messages.add(formattedMessage);
        application.setAttribute("chatMessages", messages);
    }
    %>
    
    <!-- 显示消息列表 -->
    <h2>聊天记录：</h2>
    <ul>
    <% for (String msg : messages) { %>
        <li><%= msg %></li>
    <% } %>
    </ul>
    
    <!-- 发送消息表单 -->
    <form action="chat.jsp" method="post">
        <input type="text" name="message" placeholder="输入您的消息">
        <input type="submit" value="发送">
    </form>
</body>
</html>

