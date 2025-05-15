<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.Instructor" %>
<%@ page import="com.Model.Student" %>
<%@ page import="com.Model.User" %>
<%@ page import="java.util.List" %>
<html>
<head>
    <title>Instructor List - Driving School</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="<%= request.getContextPath() %>/css/styles.css" rel="stylesheet">
</head>
<body class="bg-gradient-to-r from-blue-100 to-gray-100 min-h-screen">
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null || !(loggedInUser instanceof Student)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<%@ include file="/jsp/studentPages/studentNavbar.jsp" %>
<div class="container mx-auto px-4 py-6">
    <div class="bg-white shadow-xl rounded-lg p-8">
        <h2 class="text-3xl font-bold text-gray-800 mb-6 text-center">Our Instructors</h2>
        <!-- Search Bar -->
        <form action="instructor" method="get" class="mb-8 flex justify-center">
            <input type="hidden" name="action" value="search">
            <input type="text" name="searchTerm" placeholder="Search by name" class="p-3 w-full max-w-md border border-gray-300 rounded-l-md focus:ring-2 focus:ring-blue-500 focus:outline-none">
            <button type="submit" class="bg-blue-500 text-white p-3 rounded-r-md hover:bg-blue-600 transition duration-200">Search</button>
        </form>
        <!-- Instructor Cards -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            <%
                List<Instructor> instructors = (List<Instructor>) request.getAttribute("instructors");
                if (instructors != null && !instructors.isEmpty()) {
                    for (Instructor instructor : instructors) {
            %>
            <div class="bg-gray-50 shadow-md rounded-lg p-6 hover:shadow-lg transition duration-200">
                <h3 class="text-xl font-semibold text-gray-800 mb-2"><%= instructor.getName() %></h3>
                <p class="text-gray-600 mb-1"><strong>Experience:</strong> <%= instructor.getExperience() %> years</p>
                <p class="text-gray-600 mb-1"><strong>Availability:</strong> <%= instructor.getAvailability() != null ? instructor.getAvailability() : "Not specified" %></p>
                <p class="text-gray-600 mb-1"><strong>Certifications:</strong> <%= instructor.getCertification() != null ? instructor.getCertification() : "Not specified" %></p>
                <p class="text-gray-600"><strong>Type:</strong> <%= instructor instanceof com.Model.PartTimeInstructor ? "Part-Time" : "Full-Time" %></p>
            </div>
            <%
                    }
                } else {
            %>
            <p class="text-center text-gray-600 col-span-full">No instructors found.</p>
            <%
                }
            %>
        </div>
    </div>
</div>
</body>
</html>