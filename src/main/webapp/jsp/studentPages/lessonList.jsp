<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.Lesson" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lesson List</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 font-sans">
    <div class="container mx-auto p-6">
        <h1 class="text-2xl font-bold mb-4 text-center">Scheduled Lessons - <%= new java.text.SimpleDateFormat("EEEE, MMMM dd, yyyy hh:mm a z").format(new java.util.Date()) %></h1>

        <!-- Display error message if present -->
        <% if (request.getAttribute("error") != null) { %>
            <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-4" role="alert">
                <p><%= request.getAttribute("error") %></p>
            </div>
        <% } %>

        <div class="overflow-x-auto">
            <table class="min-w-full bg-white border border-gray-200">
                <thead>
                    <tr class="bg-gray-200 text-left">
                        <th class="py-2 px-4 border-b">Student Name</th>
                        <th class="py-2 px-4 border-b">Instructor Name</th>
                        <th class="py-2 px-4 border-b">Date</th>
                        <th class="py-2 px-4 border-b">Time</th>
                        <th class="py-2 px-4 border-b">Type</th>
                        <th class="py-2 px-4 border-b">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        List<Lesson> lessons = (List<Lesson>) request.getAttribute("lessons");
                        System.out.println("Lessons received in JSP: " + (lessons != null ? lessons : "null"));
                        if (lessons != null && !lessons.isEmpty()) {
                            for (Lesson lesson : lessons) {
                                System.out.println("Rendering lesson: " + lesson.getLessonId() + ", " + lesson.getStudentName());
                    %>
                        <tr class="hover:bg-gray-100">
                            <td class="py-2 px-4 border-b"><%= lesson.getStudentName() %></td>
                            <td class="py-2 px-4 border-b"><%= lesson.getInstructorName() %></td>
                            <td class="py-2 px-4 border-b"><%= lesson.getDate() %></td>
                            <td class="py-2 px-4 border-b"><%= lesson.getTime() %></td>
                            <td class="py-2 px-4 border-b"><%= lesson.getType() %></td>
                            <td class="py-2 px-4 border-b">
                                <a href="${pageContext.request.contextPath}/lesson?action=edit&lessonId=<%= lesson.getLessonId() %>" class="bg-blue-500 text-white py-1 px-2 rounded hover:bg-blue-600 mr-2">Update</a>
                                <a href="${pageContext.request.contextPath}/lesson?action=delete&lessonId=<%= lesson.getLessonId() %>" class="bg-red-500 text-white py-1 px-2 rounded hover:bg-red-600" onclick="return confirm('Are you sure you want to delete this lesson?');">Delete</a>
                            </td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr>
                            <td colspan="6" class="py-2 px-4 border-b text-center">No lessons scheduled.</td>
                        </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>

        <div class="mt-4 text-center">
            <a href="${pageContext.request.contextPath}/jsp/studentPages/bookingForm.jsp" class="bg-green-500 text-white py-2 px-4 rounded hover:bg-green-600">Book New Lesson</a>
        </div>
    </div>
</body>
</html>