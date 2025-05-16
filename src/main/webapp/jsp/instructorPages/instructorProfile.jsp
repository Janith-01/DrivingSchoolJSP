<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.Instructor" %>
<html>
<head>
    <title>Instructor Profile</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100">
<%@ include file="instructorNavbar.jsp" %>
<div class="container mx-auto p-4">
    <div class="bg-white shadow-md rounded-lg p-6 max-w-md mx-auto">
        <h2 class="text-2xl font-bold mb-4">Instructor Profile</h2>
        <% Instructor instructor = (Instructor) request.getAttribute("instructor"); %>
        <% if (instructor != null) { %>
        <form action="instructor" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" value="<%= instructor.getId() %>">
            <div class="mb-4">
                <label class="block text-gray-700">Name</label>
                <input type="text" name="name" value="<%= instructor.getName() %>" class="w-full p-2 border rounded" required>
            </div>
            <div class="mb-4">
                <label class="block text-gray-700">Email</label>
                <input type="email" name="email" value="<%= instructor.getEmail() %>" class="w-full p-2 border rounded" required>
            </div>
            <div class="mb-4">
                <label class="block text-gray-700">Password</label>
                <input type="password" name="password" value="<%= instructor.getPassword() %>" class="w-full p-2 border rounded" required>
            </div>
            <div class="mb-4">
                <label class="block text-gray-700">Experience (Years)</label>
                <input type="number" name="experience" value="<%= instructor.getExperience() %>" class="w-full p-2 border rounded" required>
            </div>
            <div class="mb-4">
                <label class="block text-gray-700">Certifications</label>
                <input type="text" name="certifications" value="<%= instructor.getCertification() %>" class="w-full p-2 border rounded" required>
            </div>
            <div class="mb-4">
                <label class="block text-gray-700">Type</label>
                <select name="type" class="w-full p-2 border rounded" required>
                    <option value="PartTime" <%= instructor instanceof com.Model.PartTimeInstructor ? "selected" : "" %>>Part-Time</option>
                    <option value="FullTime" <%= instructor instanceof com.Model.FullTimeInstructor ? "selected" : "" %>>Full-Time</option>
                </select>
            </div>
            <button type="submit" class="bg-blue-500 text-white p-2 rounded w-full">Update</button>
        </form>
        <% } else { %>
        <p class="text-red-500">Instructor not found.</p>
        <% } %>
        <a href="instructor?action=list" class="mt-4 inline-block text-blue-500 hover:underline">Back to List</a>
    </div>
</div>
</body>
</html>