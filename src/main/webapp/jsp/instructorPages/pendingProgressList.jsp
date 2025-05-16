<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.Lesson" %>
<%@ page import="com.Model.User" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <title>Instructor Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">
<%@ include file="instructorNavbar.jsp" %>

<div class="container mx-auto p-6">
    <div class="bg-white shadow-lg rounded-lg p-8">
        <h2 class="text-2xl font-bold mb-4">Lesson Management</h2>

        <% String error = (String) request.getAttribute("error"); %>
        <% String successMessage = (String) request.getAttribute("successMessage"); %>
        <% if (error != null) { %>
        <p class="text-red-500 mb-4"><%= error %></p>
        <% } %>
        <% if (successMessage != null) { %>
        <p class="text-green-500 mb-4"><%= successMessage %></p>
        <% } %>

        <div class="overflow-x-auto">
            <table class="min-w-full">
                <thead class="bg-gray-200">
                    <tr>
                        <th class="px-6 py-3">Student</th>
                        <th class="px-6 py-3">Date</th>
                        <th class="px-6 py-3">Time</th>
                        <th class="px-6 py-3">Type</th>
                        <th class="px-6 py-3">Status</th>
                        <th class="px-6 py-3">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    List<Lesson> lessons = (List<Lesson>) request.getAttribute("instructorLessons");
                    List<String> lessonsWithProgress = (List<String>) request.getAttribute("lessonsWithProgress");
                    if (lessons != null && !lessons.isEmpty()) {
                        for (Lesson lesson : lessons) {
                    %>
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4"><%= lesson.getStudentName() %></td>
                        <td class="px-6 py-4"><%= lesson.getDate() %></td>
                        <td class="px-6 py-4"><%= lesson.getTime() %></td>
                        <td class="px-6 py-4"><%= lesson.getType() %></td>
                        <td class="px-6 py-4"><%= lesson.getStatus() %></td>
                        <td class="px-6 py-4 space-x-2">
                            <% if ("PENDING".equalsIgnoreCase(lesson.getStatus())) { %>
                            <form method="post" action="${pageContext.request.contextPath}/lesson" class="inline">
                                <input type="hidden" name="lessonId" value="<%= lesson.getLessonId() %>">
                                <button type="submit" name="action" value="ACCEPTED"
                                        class="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600">
                                    Accept
                                </button>
                            </form>
                            <form method="post" action="${pageContext.request.contextPath}/lesson" class="inline">
                                <input type="hidden" name="lessonId" value="<%= lesson.getLessonId() %>">
                                <button type="submit" name="action" value="DENIED"
                                        class="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600">
                                    Deny
                                </button>
                            </form>
                            <% } else if ("ACCEPTED".equalsIgnoreCase(lesson.getStatus()) &&
                                        (lessonsWithProgress == null || !lessonsWithProgress.contains(lesson.getLessonId()))) { %>
                            <form method="get" action="${pageContext.request.contextPath}/progress" class="inline">
                                <input type="hidden" name="action" value="feedback">
                                <input type="hidden" name="lessonId" value="<%= lesson.getLessonId() %>">
                                <button type="submit"
                                        class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
                                    Provide Feedback
                                </button>
                            </form>
                            <% } %>
                        </td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="6" class="px-6 py-4 text-center text-gray-500">
                            No lessons available
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>