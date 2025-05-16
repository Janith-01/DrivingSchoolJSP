<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.Student" %>
<html>
<head>
    <title>Edit Profile - Driving School</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            lucide.createIcons();
        });
    </script>
    <style>
        .toast {
            visibility: hidden;
            min-width: 250px;
            margin-left: -125px;
            color: #fff;
            text-align: center;
            border-radius: 4px;
            padding: 16px;
            position: fixed;
            z-index: 1000;
            left: 50%;
            bottom: 30px;
            font-size: 1rem;
        }
        .toast.show {
            visibility: visible;
            animation: fadein 0.5s, fadeout 0.5s 3s;
        }
        .toast.success { background-color: #10B981; }
        .toast.error { background-color: #EF4444; }
        @keyframes fadein {
            from { bottom: 0; opacity: 0; }
            to { bottom: 30px; opacity: 1; }
        }
        @keyframes fadeout {
            from { bottom: 30px; opacity: 1; }
            to { bottom: 0; opacity: 0; }
        }
    </style>
</head>
<body class="bg-gray-50 min-h-screen">
<%
    User user = (User) request.getAttribute("user");
    if (user == null || !(user instanceof Student)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<%@ include file="/jsp/studentPages/studentNavbar.jsp" %>
<!-- Main Content -->
<div class="pt-20 container mx-auto px-4 py-6">
    <div class="max-w-md mx-auto bg-white shadow-xl rounded-lg p-8">
        <h2 class="text-3xl font-bold text-gray-900 text-center mb-6">Edit Your Profile</h2>
        <form action="<%= request.getContextPath() %>/user" method="post" class="space-y-6">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" value="<%= user.getId() %>">
            <div>
                <label class="block text-sm font-medium text-gray-700">Name</label>
                <input type="text" name="name" value="<%= user.getName() != null ? user.getName() : "" %>" required class="mt-1 w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700">Email</label>
                <input type="email" name="email" value="<%= user.getEmail() != null ? user.getEmail() : "" %>" required class="mt-1 w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700">Password</label>
                <input type="password" name="password" value="<%= user.getPassword() != null ? user.getPassword() : "" %>" required class="mt-1 w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700">Phone</label>
                <input type="text" name="phone" value="<%= user.getPhone() != null ? user.getPhone() : "" %>" required class="mt-1 w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none">
            </div>
            <div class="flex justify-center">
                <button type="submit" class="bg-blue-500 text-white py-2 px-6 rounded-md hover:bg-blue-600 transition duration-200 flex items-center">
                    <i data-lucide="save" class="w-5 h-5 mr-2"></i>
                    Update Profile
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Toast Notification -->
<div id="toast" class="toast"></div>
<script>
    window.onload = function() {
        const toast = document.getElementById('toast');
        <% if (request.getAttribute("error") != null) { %>
            toast.textContent = '<%= request.getAttribute("error") %>';
            toast.className = 'toast error show';
            setTimeout(() => { toast.className = 'toast'; }, 3000);
        <% } else if (request.getAttribute("success") != null) { %>
            toast.textContent = '<%= request.getAttribute("success") %>';
            toast.className = 'toast success show';
            setTimeout(() => { toast.className = 'toast'; }, 3000);
        <% } %>
    };
</script>
</body>
</html>
