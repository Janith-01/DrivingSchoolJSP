<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.Lesson" %>
<%@ page import="com.Model.User" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lesson List</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .error-message { color: #ef4444; font-size: 0.875rem; margin-top: 0.25rem; }
        .success-message { color: #10b981; font-size: 0.875rem; margin-top: 0.25rem; }
    </style>
</head>
<body class="bg-gray-100 font-sans">
<%@ include file="/jsp/studentPages/studentNavbar.jsp" %>
    <div class="container mx-auto p-6">
        <h1 class="text-2xl font-bold mb-4 text-center">Scheduled Lessons</h1>

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

        <div class="overflow-x-auto">
            <table class="min-w-full bg-white border border-gray-200">
                <thead>
                    <tr class="bg-gray-200 text-left">
                        <th class="py-2 px-4 border-b">Instructor</th>
                        <th class="py-2 px-4 border-b">Date</th>
                        <th class="py-2 px-4 border-b">Time</th>
                        <th class="py-2 px-4 border-b">Type</th>
                        <th class="py-2 px-4 border-b">Status</th>
                        <th class="py-2 px-4 border-b">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        List<Lesson> lessons = (List<Lesson>) request.getAttribute("lessons");
                        if (lessons != null && !lessons.isEmpty()) {
                            for (Lesson lesson : lessons) {
                    %>
                        <tr class="hover:bg-gray-100">
                            <td class="py-2 px-4 border-b"><%= lesson.getInstructorName() %></td>
                            <td class="py-2 px-4 border-b"><%= lesson.getDate() %></td>
                            <td class="py-2 px-4 border-b"><%= lesson.getTime() %></td>
                            <td class="py-2 px-4 border-b"><%= lesson.getType() %></td>
                            <td class="py-2 px-4 border-b">
                                <span class="px-2 py-1 rounded-full
                                    <%= "ACCEPTED".equalsIgnoreCase(lesson.getStatus()) ? "bg-green-100 text-green-800" :
                                       "DENIED".equalsIgnoreCase(lesson.getStatus()) ? "bg-red-100 text-red-800" :
                                       "bg-yellow-100 text-yellow-800" %>">
                                    <%= lesson.getStatus() %>
                                </span>
                            </td>
                            <td class="py-2 px-4 border-b">
                                <% if ("PENDING".equalsIgnoreCase(lesson.getStatus())) { %>
                                    <a href="${pageContext.request.contextPath}/lesson?action=edit&lessonId=<%= lesson.getLessonId() %>"
                                       class="bg-blue-500 text-white py-1 px-2 rounded hover:bg-blue-600 mr-2">Update</a>
                                    <button onclick="deleteLesson('<%= lesson.getLessonId() %>')"
                                            class="bg-red-500 text-white py-1 px-2 rounded hover:bg-red-600">Delete</button>
                                <% } %>
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

    <script>
        function deleteLesson(lessonId) {
            if (confirm('Are you sure you want to delete this lesson?')) {
                const form = document.createElement('form');
                form.method = 'get';
                form.action = '${pageContext.request.contextPath}/lesson';

                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'delete';
                form.appendChild(actionInput);

                const lessonIdInput = document.createElement('input');
                lessonIdInput.type = 'hidden';
                lessonIdInput.name = 'lessonId';
                lessonIdInput.value = lessonId;
                form.appendChild(lessonIdInput);

                document.body.appendChild(form);
                form.submit();
                document.body.removeChild(form);
            }
        }
    </script>
</body>
</html>