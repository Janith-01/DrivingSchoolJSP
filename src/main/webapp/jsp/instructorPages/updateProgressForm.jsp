<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.Progress" %>
<!DOCTYPE html>
<html>
<head>
    <title>Update Progress</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">
<%@ include file="instructorNavbar.jsp" %>

<div class="container mx-auto p-6">
    <div class="bg-white shadow-lg rounded-lg p-8">
        <h2 class="text-2xl font-bold mb-4">Update Progress</h2>

        <% Progress progress = (Progress) request.getAttribute("progress"); %>
        <% String error = (String) request.getAttribute("error"); %>
        <% if (error != null) { %>
        <p class="text-red-500 mb-4"><%= error %></p>
        <% } %>
        <% if (progress != null) { %>
        <form method="post" action="${pageContext.request.contextPath}/progress">
            <input type="hidden" name="action" value="updateProgress">
            <input type="hidden" name="progressId" value="<%= progress.getProgressId() %>">
            <input type="hidden" name="lessonId" value="<%= progress.getLessonId() %>">
            <input type="hidden" name="studentName" value="<%= progress.getStudentName() %>">
            <input type="hidden" name="instructorName" value="<%= progress.getInstructorName() %>">
            <input type="hidden" name="date" value="<%= progress.getDate() %>">

            <div class="mb-4">
                <label class="block text-gray-700 font-bold mb-2" for="score">Score (0-100)</label>
                <input type="number" id="score" name="score" min="0" max="100" value="<%= progress.getScore() %>" required
                       class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
            </div>

            <div class="mb-4">
                <label class="block text-gray-700 font-bold mb-2" for="remarks">Remarks</label>
                <textarea id="remarks" name="remarks" required
                          class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                          rows="5"><%= progress.getRemarks() %></textarea>
            </div>

            <div class="flex space-x-4">
                <button type="submit"
                        class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
                    Update Progress
                </button>
                <a href="${pageContext.request.contextPath}/progress?action=viewProgress"
                   class="bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600">
                    Cancel
                </a>
            </div>
        </form>
        <% } else { %>
        <p class="text-red-500">Progress record not found.</p>
        <% } %>
    </div>
</div>
</body>
</html>