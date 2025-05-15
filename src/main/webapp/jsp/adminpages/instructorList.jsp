<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.Model.Instructor" %>
<html>
<head>
    <title>Instructor List - Driving School</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="<%= request.getContextPath() %>/css/styles.css" rel="stylesheet">
    <style>
        .btn-delete {
            background-color: #ef4444;
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 0.375rem;
            transition: background-color 0.2s ease;
        }
        .btn-delete:hover {
            background-color: #dc2626;
        }
    </style>
</head>
<body class="bg-gray-100 font-sans">
<%@ include file="adminNavbar.jsp" %>
<div class="container mx-auto p-4">
    <div class="bg-white shadow-md rounded-lg p-6">
        <h2 class="text-3xl font-bold mb-4">Instructor List</h2>
        <!-- Search Form -->
        <form action="<%= request.getContextPath() %>/instructor" method="get" class="mb-6">
            <input type="hidden" name="action" value="search">
            <div class="flex space-x-2">
                <input type="text" name="searchTerm" placeholder="Search by name..." class="w-full p-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" value="<%= request.getParameter("searchTerm") != null ? request.getParameter("searchTerm") : "" %>">
                <button type="submit" class="bg-blue-500 text-white p-2 rounded-md hover:bg-blue-600 transition duration-200">Search</button>
            </div>
        </form>
        <!-- Error Message -->
        <% if (request.getAttribute("error") != null) { %>
            <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-4" role="alert">
                <p><%= request.getAttribute("error") %></p>
            </div>
        <% } %>
        <!-- Success Message -->
        <% if (request.getAttribute("success") != null) { %>
            <div class="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 mb-4" role="alert">
                <p><%= request.getAttribute("success") %></p>
            </div>
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
                        <tr class="border-b hover:bg-gray-50">
                            <td class="p-2"><%= instructor.getName() != null ? instructor.getName() : "N/A" %></td>
                            <td class="p-2"><%= instructor.getEmail() != null ? instructor.getEmail() : "N/A" %></td>
                            <td class="p-2"><%= instructor.getPhone() != null ? instructor.getPhone() : "N/A" %></td>
                            <td class="p-2"><%= instructor.getExperience() %></td>
                            <td class="p-2"><%= instructor.getAvailability() != null ? instructor.getAvailability() : "N/A" %></td>
                            <td class="p-2"><%= instructor.getCertification() != null ? instructor.getCertification() : "N/A" %></td>
                            <td class="p-2"><%= instructor instanceof com.Model.PartTimeInstructor ? "Part-Time" : "Full-Time" %></td>
                            <td class="p-2">
                                <form action="<%= request.getContextPath() %>/instructor" method="post" onsubmit="return confirm('Are you sure you want to delete this instructor?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<%= instructor.getId() %>">
                                    <button type="submit" class="btn-delete">Delete</button>
                                </form>
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
            <a href="<%= request.getContextPath() %>/instructor" class="bg-blue-500 text-white p-2 rounded-md hover:bg-blue-600 transition duration-200">Add New Instructor</a>
        </div>
    </div>
</div>
</body>
</html>