<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Perform logout
    session.invalidate();

    // Redirect to login page
    response.sendRedirect(request.getContextPath() + "/jsp/common/login.jsp");
%>