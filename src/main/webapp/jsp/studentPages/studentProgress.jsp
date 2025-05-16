<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.Progress" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <title>My Progress</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">
<%@ include file="studentNavbar.jsp" %>

<div class="container mx-auto p-6">
    <div class="bg-white shadow-lg rounded-lg p-8">
        <h2 class="text-2xl font-bold mb-4">My Progress Updates</h2>

        <% String error = (String) request.getAttribute("error"); %>
        <% if (error != null) { %>
        <p class="text-red-500 mb-4"><%= error %></p>
        <% } %>

        <div class="overflow-x-auto">
            <table class="min-w-full">
                <thead class="bg-gray-200">
                    <tr>
                        <th class="px-6 py-3">Lesson Date</th>
                        <th class="px-6 py-3">Instructor</th>
                        <th class="px-6 py-3">Score</th>
                        <th class="px-6 py-3">Remarks</th>
                        <th class="px-6 py-3">Ready for Test</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    List<Progress> progressList = (List<Progress>) request.getAttribute("progressList");
                    if (progressList != null && !progressList.isEmpty()) {
                        for (Progress progress : progressList) {
                    %>
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4"><%= progress.getDate() %></td>
                        <td class="px-6 py-4"><%= progress.getInstructorName() %></td>
                        <td class="px-6 py-4"><%= progress.getScore() %></td>
                        <td class="px-6 py-4"><%= progress.getRemarks() %></td>
                        <td class="px-6 py-4"><%= progress.isReadyForTest() ? "Yes" : "No" %></td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="5" class="px-6 py-4 text-center text-gray-500">
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