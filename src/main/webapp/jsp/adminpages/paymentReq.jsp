<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.Payment" %>
<%@ page import="java.util.List" %>
<html>
<head>
    <script src="https://cdn.tailwindcss.com"></script>
    <title>Payment Requests</title>
</head>
<body class="bg-gray-100 min-h-screen font-sans">
    <%@ include file="adminNavbar.jsp" %>

    <div class="container mx-auto p-6">
        <h2 class="text-2xl font-bold text-gray-800 mb-6">Pending Cash Payment Requests</h2>

        <% if (request.getAttribute("error") != null) { %>
            <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-4 rounded">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>
        <% if (request.getAttribute("warning") != null) { %>
            <div class="bg-yellow-100 border-l-4 border-yellow-500 text-yellow-700 p-4 mb-4 rounded">
                <%= request.getAttribute("warning") %>
            </div>
        <% } %>

        <form method="get" action="${pageContext.request.contextPath}/payment" class="mb-6 flex flex-col sm:flex-row gap-4">
            <input type="hidden" name="action" value="requests">
            <input type="text" name="studentId" placeholder="Filter by Student ID"
                   class="w-full sm:w-64 px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
            <button type="submit"
                    class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition duration-200">
                Search
            </button>
        </form>

        <%
            List<Payment> pendingPayments = (List<Payment>) request.getAttribute("pendingPayments");
        %>
        <p class="text-gray-600 mb-4">Pending Payments Count: <%= pendingPayments != null ? pendingPayments.size() : 0 %></p>

        <%
            if (pendingPayments == null || pendingPayments.isEmpty()) {
        %>
            <div class="bg-white p-6 rounded-lg shadow text-center text-gray-500">
                No pending cash payment requests found.
            </div>
        <%
            } else {
        %>
            <div class="overflow-x-auto bg-white rounded-lg shadow">
                <table class="w-full">
                    <thead>
                        <tr class="bg-gray-200 text-gray-700">
                            <th class="py-3 px-4 text-left">Payment ID</th>
                            <th class="py-3 px-4 text-left">Student ID</th>
                            <th class="py-3 px-4 text-left">Amount</th>
                            <th class="py-3 px-4 text-left">Date</th>
                            <th class="py-3 px-4 text-left">Lesson ID</th>
                            <th class="py-3 px-4 text-left">Status</th>
                            <th class="py-3 px-4 text-left">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Payment payment : pendingPayments) { %>
                            <tr class="border-b hover:bg-gray-50 transition duration-100">
                                <td class="py-3 px-4"><%= payment.getPaymentId() %></td>
                                <td class="py-3 px-4"><%= payment.getStudentId() %></td>
                                <td class="py-3 px-4">$<%= String.format("%.2f", payment.getAmount()) %></td>
                                <td class="py-3 px-4"><%= payment.getPaymentDate() %></td>
                                <td class="py-3 px-4"><%= payment.getLessonId() %></td>
                                <td class="py-3 px-4"><%= payment.getStatus() %></td>
                                <td class="py-3 px-4 flex gap-2">
                                    <form action="${pageContext.request.contextPath}/payment" method="post" class="inline-flex">
                                        <input type="hidden" name="action" value="updateStatus">
                                        <input type="hidden" name="paymentId" value="<%= payment.getPaymentId() %>">
                                        <select name="status"
                                                class="border rounded px-2 py-1 focus:outline-none focus:ring-2 focus:ring-blue-500">
                                            <option value="Completed">Approve</option>
                                            <option value="Denied">Deny</option>
                                        </select>
                                        <button type="submit"
                                                class="ml-2 bg-green-500 text-white px-3 py-1 rounded hover:bg-green-600 transition duration-200">
                                            Update
                                        </button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/payment" method="post" class="inline-flex">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="paymentId" value="<%= payment.getPaymentId() %>">
                                        <button type="submit"
                                                class="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600 transition duration-200"
                                                onclick="return confirm('Are you sure you want to delete this payment?');">
                                            Delete
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } %>

        <a href="${pageContext.request.contextPath}/jsp/adminpages/adminHome.jsp"
           class="mt-6 inline-block text-blue-600 hover:text-blue-800 transition duration-200">
            Back to Dashboard
        </a>
    </div>
</body>
</html>