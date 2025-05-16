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
    <title>Update Booking</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .error-message {
            color: #ef4444;
            font-size: 0.875rem;
            margin-top: 0.25rem;
        }
        .success-message {
            color: #10b981;
            font-size: 0.875rem;
            margin-top: 0.25rem;
        }
    </style>
</head>
<body class="bg-gray-100 font-sans">
<%@ include file="studentNavbar.jsp" %>
    <div class="container mx-auto p-6 max-w-lg">
        <h1 class="text-2xl font-bold mb-6 text-center">Update Driving Lesson</h1>

        <!-- Display messages -->
        <% if (request.getAttribute("error") != null) { %>
            <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-4" role="alert">
                <p><%= request.getAttribute("error") %></p>
            </div>
        <% } %>

        <% if (request.getAttribute("successMessage") != null) { %>
            <div class="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 mb-4" role="alert">
                <p><%= request.getAttribute("successMessage") %></p>
            </div>
        <% } %>

        <%
            // Get the lesson to edit
            Lesson lesson = (Lesson) request.getAttribute("lesson");
            if (lesson == null) {
                response.sendRedirect(request.getContextPath() + "/lesson?action=list");
                return;
            }

            // Check if lesson can be edited (only PENDING status)
            if (!"PENDING".equalsIgnoreCase(lesson.getStatus())) {
                request.setAttribute("error", "Only pending lessons can be modified");
                request.getRequestDispatcher("/lesson?action=list").forward(request, response);
                return;
            }

            // Get available instructors
            String rootPath = request.getServletContext().getRealPath("/");
            List<Instructor> instructors = FileHandler.readInstructors(rootPath).stream()
                .filter(instructor -> "Available".equalsIgnoreCase(instructor.getAvailability()))
                .collect(Collectors.toList());
        %>

        <div class="bg-white p-6 rounded-lg shadow-md">
            <form id="updateForm" action="${pageContext.request.contextPath}/lesson" method="POST" onsubmit="return validateForm()">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="lessonId" value="<%= lesson.getLessonId() %>">

                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700">Student Name</label>
                    <input type="text" value="<%= lesson.getStudentName() %>" class="mt-1 block w-full p-2 border border-gray-300 rounded-md bg-gray-100" readonly>
                </div>

                <div class="mb-4">
                    <label for="instructorName" class="block text-sm font-medium text-gray-700">Instructor</label>
                    <select id="instructorName" name="instructorName" class="mt-1 block w-full p-2 border border-gray-300 rounded-md" required>
                        <option value="">Select instructor</option>
                        <% for (Instructor instructor : instructors) {
                            boolean selected = instructor.getName().equals(lesson.getInstructorName());
                        %>
                            <option value="<%= instructor.getName() %>" <%= selected ? "selected" : "" %>>
                                <%= instructor.getName() %>
                            </option>
                        <% } %>
                    </select>
                    <div id="instructorError" class="error-message"></div>
                </div>

                <div class="mb-4">
                    <label for="date" class="block text-sm font-medium text-gray-700">Date</label>
                    <input type="date" id="date" name="date" value="<%= formatDateForInput(lesson.getDate()) %>"
                           min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>"
                           class="mt-1 block w-full p-2 border border-gray-300 rounded-md" required>
                    <div id="dateError" class="error-message"></div>
                </div>

                <div class="mb-4">
                    <label for="time" class="block text-sm font-medium text-gray-700">Time</label>
                    <input type="time" id="time" name="time" value="<%= lesson.getTime() %>"
                           min="08:00" max="18:00"
                           class="mt-1 block w-full p-2 border border-gray-300 rounded-md" required>
                    <div id="timeError" class="error-message"></div>
                </div>

                <div class="mb-4">
                    <label for="type" class="block text-sm font-medium text-gray-700">Lesson Type</label>
                    <select id="type" name="type" class="mt-1 block w-full p-2 border border-gray-300 rounded-md" required>
                        <option value="Beginner" <%= "Beginner".equals(lesson.getType()) ? "selected" : "" %>>Beginner (1 hour)</option>
                        <option value="Advanced" <%= "Advanced".equals(lesson.getType()) ? "selected" : "" %>>Advanced (2 hours)</option>
                    </select>
                </div>

                <div class="flex justify-between mt-6">
                    <button type="submit" class="bg-blue-500 hover:bg-blue-600 text-white py-2 px-4 rounded transition">
                        Save Changes
                    </button>
                    <a href="${pageContext.request.contextPath}/lesson?action=list"
                       class="bg-gray-500 hover:bg-gray-600 text-white py-2 px-4 rounded transition">
                        Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>

    <script>
        function validateForm() {
            let isValid = true;

            // Validate instructor
            const instructor = document.getElementById('instructorName').value;
            if (!instructor) {
                document.getElementById('instructorError').textContent = "Please select an instructor";
                isValid = false;
            } else {
                document.getElementById('instructorError').textContent = "";
            }

            // Validate date
            const date = document.getElementById('date').value;
            const today = new Date().toISOString().split('T')[0];
            if (!date || date < today) {
                document.getElementById('dateError').textContent = "Please select today or a future date";
                isValid = false;
            } else {
                document.getElementById('dateError').textContent = "";
            }

            // Validate time
            const time = document.getElementById('time').value;
            if (!time) {
                document.getElementById('timeError').textContent = "Please select a valid time";
                isValid = false;
            } else {
                const hours = parseInt(time.split(':')[0]);
                if (hours < 8 || hours > 18) {
                    document.getElementById('timeError').textContent = "Lessons must be between 8:00 and 18:00";
                    isValid = false;
                } else {
                    document.getElementById('timeError').textContent = "";
                }
            }

            return isValid;
        }

        // Set min time based on selected date
        document.getElementById('date').addEventListener('change', function() {
            const today = new Date().toISOString().split('T')[0];
            const timeInput = document.getElementById('time');

            if (this.value === today) {
                const now = new Date();
                const currentHour = now.getHours();
                const currentMinute = now.getMinutes();

                // Set min time to current time + 30 minutes
                let minHour = currentHour;
                let minMinute = currentMinute + 30;

                if (minMinute >= 60) {
                    minHour++;
                    minMinute -= 60;
                }

                timeInput.min = `${minHour.toString().padStart(2, '0')}:${minMinute.toString().padStart(2, '0')}`;
            } else {
                timeInput.min = "08:00";
            }
        });
    </script>

    <%!
        // Helper method to format date for input field
        public String formatDateForInput(String dateStr) {
            if (dateStr == null) return "";

            try {
                // Handle MM/dd/yyyy format
                if (dateStr.matches("\\d{1,2}/\\d{1,2}/\\d{4}")) {
                    String[] parts = dateStr.split("/");
                    return String.format("%s-%s-%s",
                        parts[2],
                        parts[0].length() == 1 ? "0" + parts[0] : parts[0],
                        parts[1].length() == 1 ? "0" + parts[1] : parts[1]);
                }
                // Handle yyyy-MM-dd format
                else if (dateStr.matches("\\d{4}-\\d{1,2}-\\d{1,2}")) {
                    return dateStr;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            return "";
        }
    %>
</body>
</html>