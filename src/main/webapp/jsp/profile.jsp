<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.drivingschool.model.User" %>
<%@ page import="com.drivingschool.model.Instructor" %>
<html>
<head>
    <title>Edit Profile - Driving School</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="css/styles.css" rel="stylesheet">
</head>
<body>
<div class="container">
    <div class="card">
        <h2 class="text-2xl font-bold mb-4">Edit Profile</h2>
        <% User user = (User) request.getAttribute("user"); %>
        <form action="user" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" value="<%= user.getId() %>">
            <div class="mb-4">
                <label class="block text-sm font-medium">Name</label>
                <input type="text" name="name" value="<%= user.getName() %>" required class="w-full p-2 border rounded-md">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium">Email</label>
                <input type="email" name="email" value="<%= user.getEmail() %>" required class="w-full p-2 border rounded-md">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium">Password</label>
                <input type="password" name="password" value="<%= user.getPassword() %>" required class="w-full p-2 border rounded-md">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium">Phone</label>
                <input type="text" name="phone" value="<%= user.getPhone() %>" required class="w-full p-2 border rounded-md">
            </div>
            <% if (user instanceof Instructor) { %>
            <div class="mb-4">
                <label class="block text-sm font-medium">Certification</label>
                <input type="text" name="certification" value="<%= ((Instructor) user).getCertification() %>" class="w-full p-2 border rounded-md">
            </div>
            <% } %>
            <button type="submit" class="btn btn-primary">Update</button>
        </form>
    </div>
</div>
</body>
</html>