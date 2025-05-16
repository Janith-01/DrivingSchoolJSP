<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Register Student - Driving School</title>
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
            background-color: #EF4444;
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
<body class="bg-gray-50 min-h-screen flex items-center">
<div class="container mx-auto px-4 py-6">
    <div class="max-w-md mx-auto bg-white shadow-xl rounded-lg p-8">
        <h2 class="text-3xl font-bold text-gray-900 text-center mb-6">Register as a Student</h2>
        <form action="<%= request.getContextPath() %>/user" method="post" class="space-y-6">
            <input type="hidden" name="action" value="register">
            <div>
                <label class="block text-sm font-medium text-gray-700">Name</label>
                <input type="text" name="name" required class="mt-1 w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700">Email</label>
                <input type="email" name="email" required class="mt-1 w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700">Password</label>
                <input type="password" name="password" required class="mt-1 w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700">Phone</label>
                <input type="text" name="phone" required class="mt-1 w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none">
            </div>
            <div class="flex justify-between items-center">
                <button type="submit" class="bg-blue-500 text-white py-2 px-6 rounded-md hover:bg-blue-600 transition duration-200 flex items-center">
                    <i data-lucide="user-plus" class="w-5 h-5 mr-2"></i>
                    Register
                </button>
                <a href="<%= request.getContextPath() %>/login" class="bg-gray-500 text-white py-2 px-6 rounded-md hover:bg-gray-600 transition duration-200 flex items-center">
                    <i data-lucide="log-in" class="w-5 h-5 mr-2"></i>
                    Back to Login
                </a>
            </div>
        </form>
        <div class="mt-6 text-center">
            <p class="text-sm text-gray-600">Already have an account? <a href="<%= request.getContextPath() %>/login" class="text-blue-500 hover:underline">Log in</a></p>
        </div>
    </div>
</div>
<!-- Toast Notification -->
<div id="toast" class="toast"></div>
<script>
    window.onload = function() {
        const toast = document.getElementById('toast');
        <% if (request.getAttribute("error") != null) { %>
            toast.textContent = '<%= request.getAttribute("error") %>';
            toast.className = 'toast show';
            setTimeout(() => { toast.className = 'toast'; }, 3000);
        <% } %>
    };
</script>
</body>
</html>
