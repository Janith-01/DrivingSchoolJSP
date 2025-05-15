<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.Instructor" %>
<%@ page import="com.Util.FileHandler" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.stream.Collectors" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book a Lesson</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .error-message {
            color: #ef4444;
            font-size: 0.875rem;
            margin-top: 0.25rem;
        }
        .toast {
            visibility: hidden;
            min-width: 250px;
            margin-left: -125px;
            background-color: #4CAF50;
            color: #fff;
            text-align: center;
            border-radius: 4px;
            padding: 16px;
            position: fixed;
            z-index: 1;
            left: 50%;
            bottom: 30px;
            font-size: 1rem;
        }
        .toast.show {
            visibility: visible;
            animation: fadein 0.5s, fadeout 0.5s 2.5s;
        }
        @keyframes fadein {
            from {bottom: 0; opacity: 0;}
            to {bottom: 30px; opacity: 1;}
        }
        @keyframes fadeout {
            from {bottom: 30px; opacity: 1;}
            to {bottom: 0; opacity: 0;}
        }
    </style>
</head>
<body class="bg-gray-100 font-sans">
<%@ include file="/jsp/studentPages/studentNavbar.jsp" %>
    <div class="container mx-auto p-6 max-w-lg">
        <h1 class="text-2xl font-bold mb-4 text-center">Book a Driving Lesson</h1>
        <p class="text-center text-gray-600 mb-6">Current Date & Time: <%= new java.text.SimpleDateFormat("EEEE, MMMM dd, yyyy hh:mm a z").format(new java.util.Date()) %></p>

        <% if (request.getAttribute("error") != null) { %>
            <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-4" role="alert">
                <p><%= request.getAttribute("error") %></p>
            </div>
        <% } %>

        <!-- Fetch logged-in student's Name -->
        <%
            User loggedInUser = (User) session.getAttribute("loggedInUser");
            String studentName = "";
            if (loggedInUser != null && loggedInUser instanceof com.Model.Student) {
                studentName = loggedInUser.getName();
            } else {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
        %>

        <!-- Fetch available instructors -->
        <%
            String rootPath = getServletContext().getRealPath("/");
            List<Instructor> instructors = FileHandler.readInstructors(rootPath).stream()
                .filter(instructor -> {
                    String availability = instructor.getAvailability();
                    return availability != null && availability.trim().equalsIgnoreCase("Available");
                })
                .collect(Collectors.toList());

            // Debug logging
            System.out.println("Total instructors loaded: " + FileHandler.readInstructors(rootPath).size());
            System.out.println("Available instructors: " + instructors.size());
            for (Instructor instructor : instructors) {
                System.out.println("Instructor: " + instructor.getName() + ", Availability: " + instructor.getAvailability());
            }
        %>

        <!-- Lesson Booking Form -->
        <form id="bookingForm" action="${pageContext.request.contextPath}/lesson" method="POST" onsubmit="return validateForm()" class="bg-white p-6 rounded-lg shadow-md">
            <input type="hidden" name="action" value="register">

            <div class="mb-4">
                <label for="studentName" class="block text-sm font-medium text-gray-700">Student Name</label>
                <input type="text" id="studentName" name="studentName" value="<%= studentName %>" class="mt-1 block w-full p-2 border border-gray-300 rounded-md bg-gray-100" readonly>
                <div id="studentNameError" class="error-message"></div>
            </div>

            <div class="mb-4">
                <label for="instructorName" class="block text-sm font-medium text-gray-700">Select Instructor</label>
                <select id="instructorName" name="instructorName" class="mt-1 block w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" required>
                    <option value="" disabled selected>Select an instructor</option>
                    <% if (instructors.isEmpty()) { %>
                        <option value="" disabled>No available instructors</option>
                    <% } else { %>
                        <% for (Instructor instructor : instructors) { %>
                            <option value="<%= instructor.getName() %>"><%= instructor.getName() %></option>
                        <% } %>
                    <% } %>
                </select>
                <div id="instructorNameError" class="error-message"></div>
            </div>

            <div class="mb-4">
                <label for="date" class="block text-sm font-medium text-gray-700">Date</label>
                <input type="date" id="date" name="date" class="mt-1 block w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" required>
                <div id="dateError" class="error-message"></div>
            </div>

            <div class="mb-4">
                <label for="time" class="block text-sm font-medium text-gray-700">Time (HH:MM, e.g., 14:00)</label>
                <input type="text" id="time" name="time" placeholder="e.g., 14:00" class="mt-1 block w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" required>
                <div id="timeError" class="error-message"></div>
            </div>

            <div class="mb-4">
                <label for="type" class="block text-sm font-medium text-gray-700">Lesson Type</label>
                <select id="type" name="type" class="mt-1 block w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" required>
                    <option value="" disabled selected>Select lesson type</option>
                    <option value="Beginner">Beginner (1 hour)</option>
                    <option value="Advanced">Advanced (2 hours)</option>
                </select>
                <div id="typeError" class="error-message"></div>
            </div>

            <div class="flex justify-between">
                <button type="submit" class="bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-600">Book Lesson</button>
                <a href="${pageContext.request.contextPath}/lesson?action=list" class="bg-gray-500 text-white py-2 px-4 rounded hover:bg-gray-600">View Lessons</a>
            </div>
        </form>

        <!-- Toast Notification -->
        <div id="toast" class="toast">Successfully booked the lesson!</div>
    </div>

    <script>
        function validateForm() {
            let isValid = true;
            const instructorName = document.getElementById("instructorName").value;
            const date = document.getElementById("date").value;
            const time = document.getElementById("time").value;
            const type = document.getElementById("type").value;

            // Reset error messages
            document.getElementById("instructorNameError").textContent = "";
            document.getElementById("dateError").textContent = "";
            document.getElementById("timeError").textContent = "";
            document.getElementById("typeError").textContent = "";

            // Validate Instructor Selection
            if (!instructorName) {
                document.getElementById("instructorNameError").textContent = "Please select an instructor";
                isValid = false;
            }

            // Validate Date (must be today or in the future)
            const today = new Date();
            today.setHours(0, 0, 0, 0); // Reset time for comparison
            const selectedDate = new Date(date);
            if (!date || selectedDate < today) {
                document.getElementById("dateError").textContent = "Please select a date today or in the future";
                isValid = false;
            }

            // Validate Time (format HH:MM, between 08:00 and 18:00)
            const timeRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
            if (!time || !time.match(timeRegex)) {
                document.getElementById("timeError").textContent = "Please enter a valid time in HH:MM format (e.g., 14:00)";
                isValid = false;
            } else {
                const [hours] = time.split(":").map(Number);
                if (hours < 8 || hours > 18) {
                    document.getElementById("timeError").textContent = "Lessons can only be scheduled between 08:00 and 18:00";
                    isValid = false;
                }
            }

            // Validate Lesson Type
            if (!type) {
                document.getElementById("typeError").textContent = "Please select a lesson type";
                isValid = false;
            }

            return isValid;
        }

        // Show toast on successful booking
        window.onload = function() {
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('success') === 'true') {
                const toast = document.getElementById("toast");
                toast.className = "toast show";
                setTimeout(() => { toast.className = "toast"; }, 3000); // Hide after 3 seconds
            }
        };
    </script>
</body>
</html>