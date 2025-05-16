<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.Instructor" %>
<html>
<head>
    <title>Update Instructor Availability</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100">
<%@ include file="instructorNavbar.jsp" %>
<div class="container mx-auto p-4">
    <div class="bg-white shadow-md rounded-lg p-6 max-w-md mx-auto">
        <h2 class="text-2xl font-bold mb-4">Update Availability</h2>
        <% Instructor instructor = (Instructor) request.getAttribute("instructor"); %>
        <% if (instructor != null) { %>
        <form action="instructor" method="post">
            <input type="hidden" name="action" value="updateAvailability">
            <input type="hidden" name="id" value="<%= instructor.getId() %>">
            <div class="mb-4">
                <label class="block text-gray-700">Name</label>
                <input type="text" value="<%= instructor.getName() %>" class="w-full p-2 border rounded" disabled>
            </div>
            <div class="mb-4">
                <label class="block text-gray-700">Availability</label>
                <select name="availability" class="w-full p-2 border rounded" required>
                    <option value="Available" <%= "Available".equals(instructor.getAvailability()) ? "selected" : "" %>>Available</option>
                    <option value="Not Available" <%= "Not Available".equals(instructor.getAvailability()) ? "selected" : "" %>>Not Available</option>
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