<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.Instructor" %>
<%@ page import="java.util.List" %>
<html>
<head>
    <title>Instructor List</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100">
<%@ include file="studentNavbar.jsp" %>
<div class="container mx-auto p-4">
    <div class="bg-white shadow-md rounded-lg p-6">
        <h2 class="text-2xl font-bold mb-4">Instructor List</h2>
        <form action="instructor" method="get" class="mb-4">
            <input type="hidden" name="action" value="search">
            <input type="text" name="searchTerm" placeholder="Search by name" class="p-2 border rounded">
            <button type="submit" class="bg-blue-500 text-white p-2 rounded">Search</button>
        </form>
        <table class="w-full border-collapse">
            <thead>
            <tr class="bg-gray-200">
                <th class="p-2 text-left">Name</th>
                <th class="p-2 text-left">Experience</th>
                <th class="p-2 text-left">Availability</th>
                <th class="p-2 text-left">Certifications</th>
                <th class="p-2 text-left">Type</th>
                <th class="p-2 text-left">Actions</th>
            </tr>
            </thead>
            <tbody>
            <% List<Instructor> instructors = (List<Instructor>) request.getAttribute("instructors"); %>
            <% for (Instructor instructor : instructors) { %>
            <tr class="border-b">
                <td class="p-2"><%= instructor.getName() %></td>
                <td class="p-2"><%= instructor.getExperience() %></td>
                <td class="p-2"><%= instructor.getAvailability() %></td>
                <td class="p-2"><%= instructor.getCertification() %></td>
                <td class="p-2"><%= instructor instanceof com.Model.PartTimeInstructor ? "Part-Time" : "Full-Time" %></td>
                <td class="p-2">
                    <a href="instructor?action=profile&id=<%= instructor.getId() %>" class="text-blue-600 hover:underline">Profile</a>
                    <a href="instructor?action=updateAvailability&id=<%= instructor.getId() %>" class="text-green-600 hover:underline ml-2">Availability</a>
                    <form action="instructor" method="post" class="inline-block ml-2" onsubmit="return confirm('Are you sure?');">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" value="<%= instructor.getId() %>">
                        <button type="submit" class="text-red-600 hover:underline">Delete</button>
                    </form>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <a href="instructor" class="mt-4 inline-block bg-blue-500 text-white p-2 rounded">Add New Instructor</a>
    </div>
</div>
</body>
</html>