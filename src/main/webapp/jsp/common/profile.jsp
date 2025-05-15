<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.Student" %>
<html>
<head>
    <title>Edit Profile - Driving School</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="<%= request.getContextPath() %>/css/styles.css" rel="stylesheet">
</head>
<body class="bg-gradient-to-r from-blue-100 to-gray-100 min-h-screen">
<%
    User user = (User) request.getAttribute("user");
    if (user == null || !(user instanceof Student)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<%@ include file="/jsp/studentPages/studentNavbar.jsp" %>
<div class="container mx-auto px-4 py-6">
    <div class="max-w-md mx-auto bg-white shadow-xl rounded-lg p-8">
        <h2 class="text-3xl font-bold text-gray-800 text-center mb-6">Edit Your Profile</h2>
        <form action="user" method="post" class="space-y-6">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" value="<%= user.getId() %>">
            <div>
                <label class="block text-sm font-medium text-gray-700">Name</label>
                <input type="text" name="name" value="<%= user.getName() %>" required class="mt-1 w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700">Email</label>
                <input type="email" name="email" value="<%= user.getEmail() %>" required class="mt-1 w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700">Password</label>
                <input type="password" name="password" value="<%= user.getPassword() %>" required class="mt-1 w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700">Phone</label>
                <input type="text" name="phone" value="<%= user.getPhone() != null ? user.getPhone() : "" %>" required class="mt-1 w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none">
            </div>
            <div class="flex justify-center">
                <button type="submit" class="bg-blue-500 text-white py-2 px-6 rounded-md hover:bg-blue-600 transition duration-200">Update Profile</button>
            </div>
        </form>
    </div>
</div>
</body>
</html>