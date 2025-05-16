<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.User" %>
<html>
<head>
    <title>Login - Driving School</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="<%= request.getContextPath() %>/css/styles.css" rel="stylesheet">
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
        .toast.success { background-color: #4CAF50; }
        .toast.error { background-color: #EF4444; }
        .toast.show {
            visibility: visible;
            animation: fadein 0.5s, fadeout 0.5s 3s;
        }
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
<body class="bg-gradient-to-r from-blue-100 to-gray-100 min-h-screen flex items-center justify-center">
<div class="container mx-auto px-4">
    <div class="max-w-md mx-auto bg-white shadow-xl rounded-lg p-8">
        <h2 class="text-3xl font-bold text-gray-800 text-center mb-6">Login to Driving School</h2>
        <form action="<%= request.getContextPath() %>/login" method="post" class="space-y-6">
            <div>
                <label class="block text-sm font-medium text-gray-700">Email</label>
                <input type="email" name="email" required class="mt-1 w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700">Password</label>
                <input type="password" name="password" required class="mt-1 w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none">
            </div>
            <div class="flex justify-between items-center">
                <button type="submit" class="bg-blue-500 text-white py-2 px-6 rounded-md hover:bg-blue-600 transition duration-200">Login</button>
            </div>
        </form>
        <div class="mt-6 text-center">
            <p class="text-sm text-gray-600">Don't have an account?</p>
            <a href="register.jsp" class="text-blue-500 hover:underline">Create a student account</a><br>
        </div>
    </div>
</div>
<!-- Toast Notifications -->
<div id="toast" class="toast"></div>
<script>
    // Check if user is logged in (set by LoginServlet after redirect back to login.jsp with success)
    <% User loggedInUser = (User) session.getAttribute("loggedInUser"); %>
    <% if (loggedInUser != null) { %>
        localStorage.setItem('userId', '<%= loggedInUser.getId() %>');
    <% } %>

    // Show toast for success or error messages
    window.onload = function() {
        const toast = document.getElementById('toast');
        <% if (request.getAttribute("error") != null) { %>
            toast.textContent = '<%= request.getAttribute("error") %>';
            toast.className = 'toast error show';
            setTimeout(() => { toast.className = 'toast error'; }, 3000);
        <% } else if ("registered".equals(request.getParameter("success"))) { %>
            toast.textContent = 'Registration successful! Please log in.';
            toast.className = 'toast success show';
            setTimeout(() => { toast.className = 'toast success'; }, 3000);
        <% } %>
    };
</script>
</body>
</html>