<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.User" %>
<%@ page import="java.util.List" %>
<html>
<head>
    <title>User List - Driving School</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="css/styles.css" rel="stylesheet">
</head>
<body>
<%@ include file="adminNavbar.jsp" %>
<div class="container">
    <div class="card">
        <h2 class="text-2xl font-bold mb-4">User List</h2>
        <table class="w-full border-collapse">
            <thead>
            <tr class="bg-gray-200">
                <th class="p-2 text-left">Name</th>
                <th class="p-2 text-left">Role</th>
                <th class="p-2 text-left">Email</th>
                <th class="p-2 text-left">Phone</th>
                <th class="p-2 text-left">Actions</th>
            </tr>
            </thead>
            <tbody>
            <% List<User> users = (List<User>) request.getAttribute("users");
               for (User user : users) { %>
            <tr class="border-b">
                <td class="p-2"><%= user.getName() %></td>
                <td class="p-2"><%= user.getRole() %></td>
                <td class="p-2"><%= user.getEmail() %></td>
                <td class="p-2"><%= user.getPhone() %></td>
                <td class="p-2">
                    <a href="user?action=edit&id=<%= user.getId() %>" class="text-blue-600 hover:underline">Edit</a>
                    <form action="user" method="post" class="inline-block ml-2" onsubmit="return confirm('Are you sure?');">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" value="<%= user.getId() %>">
                        <button type="submit" class="text-red-600 hover:underline">Delete</button>
                    </form>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <a href="user" class="btn btn-primary mt-4 inline-block">Add New User</a>
    </div>
</div>
</body>
</html>