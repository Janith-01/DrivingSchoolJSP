<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.Progress" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <title>Instructor Progress List</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">
<%@ include file="instructorNavbar.jsp" %>

<div class="container mx-auto p-6">
    <div class="bg-white shadow-lg rounded-lg p-8">
        <h2 class="text-2xl font-bold mb-4">Student Progress Records</h2>

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
                        <th class="px-6 py-3">Lesson Date</th>
                        <th class="px-6 py-3">Score</th>
                        <th class="px-6 py-3">Remarks</th>
                        <th class="px-6 py-3">Ready for Test</th>
                        <th class="px-6 py-3">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    List<Progress> progressList = (List<Progress>) request.getAttribute("progressList");
                    if (progressList != null && !progressList.isEmpty()) {
                        for (Progress progress : progressList) {
                    %>
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4"><%= progress.getStudentName() %></td>
                        <td class="px-6 py-4"><%= progress.getDate() %></td>
                        <td class="px-6 py-4"><%= progress.getScore() %></td>
                        <td class="px-6 py-4"><%= progress.getRemarks() %></td>
                        <td class="px-6 py-4"><%= progress.isReadyForTest() ? "Yes" : "No" %></td>
                        <td class="px-6 py-4">
                            <form method="get" action="${pageContext.request.contextPath}/progress" class="inline">
                                <input type="hidden" name="action" value="editProgress">
                                <input type="hidden" name="progressId" value="<%= progress.getProgressId() %>">
                                <button type="submit"
                                        class="bg-yellow-500 text-white px-4 py-2 rounded hover:bg-yellow-600">
                                    Update
                                </button>
                            </form>
                        </td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="6" class="px-6 py-4 text-center text-gray-500">
                            No progress records available
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