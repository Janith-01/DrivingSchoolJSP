<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.Model.Instructor" %>
<html>
<head>
    <title>Instructor List - Driving School</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="../css/styles.css" rel="stylesheet">
</head>
<body class="bg-gray-100">
<%@ include file="adminNavbar.jsp" %>
<div class="container mx-auto p-4">
    <div class="bg-white shadow-md rounded-lg p-6">
        <h2 class="text-3xl font-bold mb-4">Instructor List</h2>
        <!-- Search Form -->
        <form action="instructor" method="get" class="mb-6">
            <input type="hidden" name="action" value="search">
            <div class="flex space-x-2">
                <input type="text" name="searchTerm" placeholder="Search by name..." class="w-full p-2 border rounded-md" value="<%= request.getParameter("searchTerm") != null ? request.getParameter("searchTerm") : "" %>">
                <button type="submit" class="bg-blue-500 text-white p-2 rounded-md hover:bg-blue-600">Search</button>
            </div>
        </form>
        <!-- Error Message -->
        <% if (request.getAttribute("error") != null) { %>
            <p class="text-red-500 mb-4"><%= request.getAttribute("error") %></p>
        <% } %>
        <!-- Instructor Table -->
        <div class="overflow-x-auto">
            <table class="w-full border-collapse">
                <thead>
                    <tr class="bg-gray-200">
                        <th class="p-2 text-left">Name</th>
                        <th class="p-2 text-left">Email</th>
                        <th class="p-2 text-left">Phone</th>
                        <th class="p-2 text-left">Experience (Years)</th>
                        <th class="p-2 text-left">Availability</th>
                        <th class="p-2 text-left">Certifications</th>
                        <th class="p-2 text-left">Type</th>
                        <th class="p-2 text-left">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        List<Instructor> instructors = (List<Instructor>) request.getAttribute("instructors");
                        if (instructors != null && !instructors.isEmpty()) {
                            for (Instructor instructor : instructors) {
                    %>
                        <tr class="border-b">
                            <td class="p-2"><%= instructor.getName() != null ? instructor.getName() : "N/A" %></td>
                            <td class="p-2"><%= instructor.getEmail() != null ? instructor.getEmail() : "N/A" %></td>
                            <td class="p-2"><%= instructor.getPhone() != null ? instructor.getPhone() : "N/A" %></td>
                            <td class="p-2"><%= instructor.getExperience() %></td>
                            <td class="p-2"><%= instructor.getAvailability() != null ? instructor.getAvailability() : "N/A" %></td>
                            <td class="p-2"><%= instructor.getCertification() != null ? instructor.getCertification() : "N/A" %></td>
                            <td class="p-2"><%= instructor instanceof com.Model.PartTimeInstructor ? "Part-Time" : "Full-Time" %></td>
                            <td class="p-2 flex space-x-2">
                                <a href="<%= request.getContextPath() %>/instructor?action=profile&id=<%= instructor.getId() %>" class="text-blue-500 hover:underline">Profile</a>
                                <a href="<%= request.getContextPath() %>/instructor?action=updateAvailability&id=<%= instructor.getId() %>" class="text-green-500 hover:underline">Update Availability</a>
                                <a href="<%= request.getContextPath() %>/instructor?action=delete&id=<%= instructor.getId() %>" class="text-red-500 hover:underline" onclick="return confirm('Are you sure you want to delete this instructor?');">Delete</a>
                            </td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr>
                            <td colspan="8" class="p-2 text-center">No instructors found.</td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <!-- Navigation -->
        <div class="mt-6 flex space-x-4">
            <a href="<%= request.getContextPath() %>/instructor?action=register" class="bg-blue-500 text-white p-2 rounded-md hover:bg-blue-600">Add New Instructor</a>
            <a href="<%= request.getContextPath() %>/logout" class="text-red-500 hover:underline">Logout</a>
        </div>
    </div>
</div>
</body>
</html>