<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.User" %>
<%@ page import="java.util.List" %>
<html>
<head>
    <title>User List - Driving School</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        /* Custom styles for enhanced UI */
        .card {
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 15px rgba(0, 0, 0, 0.1);
        }
        tr {
            transition: background-color 0.2s ease;
        }
        tr:hover {
            background-color: #f1f5f9;
        }
        .btn-primary {
            transition: background-color 0.3s ease, transform 0.2s ease;
        }
        .btn-primary:hover {
            background-color: #2563eb;
            transform: scale(1.05);
        }
        .btn-delete {
            transition: color 0.3s ease, transform 0.2s ease;
        }
        .btn-delete:hover {
            color: #dc2626;
            transform: scale(1.1);
        }
    </style>
</head>
<body class="bg-gray-100 font-sans">
<%@ include file="adminNavbar.jsp" %>
<div class="container mx-auto p-6 max-w-7xl">
    <div class="card bg-white rounded-xl shadow-lg p-8">
        <div class="flex justify-between items-center mb-6">
            <h2 class="text-3xl font-bold text-gray-800">User List</h2>
            <a href="user" class="btn-primary bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700">
                Add New User
            </a>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full border-collapse">
                <thead>
                <tr class="bg-blue-50 text-gray-700">
                    <th class="p-4 text-left font-semibold">Name</th>
                    <th class="p-4 text-left font-semibold">Role</th>
                    <th class="p-4 text-left font-semibold">Email</th>
                    <th class="p-4 text-left font-semibold">Phone</th>
                    <th class="p-4 text-left font-semibold">Actions</th>
                </tr>
                </thead>
                <tbody class="text-gray-600">
                <% List<User> users = (List<User>) request.getAttribute("users");
                   for (User user : users) { %>
                <tr class="border-b border-gray-200">
                    <td class="p-4"><%= user.getName() %></td>
                    <td class="p-4">
                        <span class="inline-block px-3 py-1 text-sm font-medium rounded-full <%= user.getRole().equals("ADMIN") ? "bg-green-100 text-green-800" : "bg-blue-100 text-blue-800" %>">
                            <%= user.getRole() %>
                        </span>
                    </td>
                    <td class="p-4"><%= user.getEmail() %></td>
                    <td class="p-4"><%= user.getPhone() %></td>
                    <td class="p-4">
                        <form action="user" method="post" class="inline-block" onsubmit="return confirm('Are you sure you want to delete this user?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<%= user.getId() %>">
                            <button type="submit" class="btn-delete text-red-500 font-medium hover:text-red-600">Delete</button>
                        </form>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>