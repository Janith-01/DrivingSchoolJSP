<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.Lesson" %>
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
    <title>Update Lesson</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .error-message {
            color: #ef4444;
            font-size: 0.875rem;
            margin-top: 0.25rem;
        }
    </style>
</head>
<body class="bg-gray-100 font-sans">
    <div class="container mx-auto p-6 max-w-lg">
        <h1 class="text-2xl font-bold mb-6 text-center">Update Lesson</h1>

        <!-- Display error message if present -->
        <% if (request.getAttribute("error") != null) { %>
            <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-4" role="alert">
                <p><%= request.getAttribute("error") %></p>
            </div>
        <% } %>

        <%
            // Get the lesson to edit
            Lesson lesson = (Lesson) request.getAttribute("lesson");
            if (lesson == null) {
                // If lesson is null, redirect to lesson list
                response.sendRedirect(request.getContextPath() + "/lesson?action=list");
                return;
            }

            // Fetch instructors for the dropdown
            String rootPath = request.getServletContext().getRealPath("/");
            List<User> users = FileHandler.readUsers(rootPath);
            List<Instructor> instructors = users.stream()
                .filter(user -> user instanceof Instructor)
                .map(user -> (Instructor) user)
                .collect(Collectors.toList());
        %>

        <div class="bg-white p-6 rounded-lg shadow-md">
            <form id="updateForm" action="${pageContext.request.contextPath}/lesson" method="POST" onsubmit="return validateForm()">
                <input type="hidden" name="action" value="update">
                <input type="hidden" id="lessonId" name="lessonId" value="<%= lesson.getLessonId() %>">

                <div class="mb-4">
                    <label for="studentName" class="block text-sm font-medium text-gray-700">Student Name</label>
                    <input type="text" id="studentName" name="studentName" value="<%= lesson.getStudentName() %>" class="mt-1 block w-full p-2 border border-gray-300 rounded-md bg-gray-100" readonly>
                </div>

                <div class="mb-4">
                    <label for="instructorName" class="block text-sm font-medium text-gray-700">Select Instructor</label>
                    <select id="instructorName" name="instructorName" class="mt-1 block w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" required>
                        <option value="">Select an instructor</option>
                        <%
                        for (Instructor instructor : instructors) {
                            boolean isSelected = instructor.getName().equals(lesson.getInstructorName());
                        %>
                            <option value="<%= instructor.getName() %>" <%= isSelected ? "selected" : "" %>><%= instructor.getName() %></option>
                        <% } %>
                    </select>
                    <div id="instructorNameError" class="error-message"></div>
                </div>

                <div class="mb-4">
                    <label for="date" class="block text-sm font-medium text-gray-700">Date</label>
                    <input type="date" id="date" name="date" value="<%= formatDateForInput(lesson.getDate()) %>" class="mt-1 block w-full p-2 border border-gray-300 rounded-md" required>
                    <div id="dateError" class="error-message"></div>
                </div>

                <div class="mb-4">
                    <label for="time" class="block text-sm font-medium text-gray-700">Time (HH:MM)</label>
                    <input type="text" id="time" name="time" value="<%= lesson.getTime() %>" class="mt-1 block w-full p-2 border border-gray-300 rounded-md" required>
                    <div id="timeError" class="error-message"></div>
                </div>

                <div class="mb-4">
                    <label for="type" class="block text-sm font-medium text-gray-700">Type</label>
                    <select id="type" name="type" class="mt-1 block w-full p-2 border border-gray-300 rounded-md" required>
                        <option value="Beginner" <%= "Beginner".equals(lesson.getType()) ? "selected" : "" %>>Beginner (1 hour)</option>
                        <option value="Advanced" <%= "Advanced".equals(lesson.getType()) ? "selected" : "" %>>Advanced (2 hours)</option>
                    </select>
                    <div id="typeError" class="error-message"></div>
                </div>

                <div class="flex justify-between mt-6">
                    <button type="submit" class="bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-600">Save Changes</button>
                    <a href="${pageContext.request.contextPath}/lesson?action=list" class="bg-gray-500 text-white py-2 px-4 rounded hover:bg-gray-600">Cancel</a>
                </div>
            </form>
        </div>
    </div>

    <script>
        function validateForm() {
            let isValid = true;
            const instructorName = document.getElementById('instructorName').value;
            const date = document.getElementById('date').value;
            const time = document.getElementById('time').value;
            const type = document.getElementById('type').value;

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
    </script>

    <%!
        // JSP Declaration for date formatting function
        public String formatDateForInput(String dateStr) {
            // Check if the date is in MM/DD/YYYY format
            String[] dateParts = dateStr.split("/");
            if (dateParts.length == 3) {
                // Convert MM/DD/YYYY to YYYY-MM-DD for input[type="date"]
                String month = dateParts[0].length() == 1 ? "0" + dateParts[0] : dateParts[0];
                String day = dateParts[1].length() == 1 ? "0" + dateParts[1] : dateParts[1];
                String year = dateParts[2];
                return year + "-" + month + "-" + day;
            }
            // Check if the date is already in YYYY-MM-DD format
            else if (dateStr.matches("^\\d{4}-\\d{2}-\\d{2}$")) {
                return dateStr;
            }
            return dateStr; // Return as-is if format is unknown
        }
    %>
</body>
</html>