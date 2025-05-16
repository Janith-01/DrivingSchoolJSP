<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.Payment" %>
<%@ page import="java.util.List" %>
<html>
<head>
    <title>Payment Requests</title>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        .error {
            color: red;
        }
        .warning {
            color: orange;
        }
    </style>
</head>
<body>
    <h2>Pending Cash Payment Requests</h2>

    <% if (request.getAttribute("error") != null) { %>
        <p class="error"><%= request.getAttribute("error") %></p>
    <% } %>
    <% if (request.getAttribute("warning") != null) { %>
        <p class="warning"><%= request.getAttribute("warning") %></p>
    <% } %>

    <%
        List<Payment> pendingPayments = (List<Payment>) request.getAttribute("pendingPayments");
        if (pendingPayments == null || pendingPayments.isEmpty()) {
    %>
        <p>No pending cash payment requests found.</p>
    <%
        } else {
    %>
        <table>
            <thead>
                <tr>
                    <th>Payment ID</th>
                    <th>Student ID</th>
                    <th>Amount</th>
                    <th>Date</th>
                    <th>Lesson ID</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
            <% for (Payment payment : pendingPayments) { %>
                <tr>
                    <td><%= payment.getPaymentId() %></td>
                    <td><%= payment.getStudentId() %></td>
                    <td>$<%= String.format("%.2f", payment.getAmount()) %></td>
                    <td><%= payment.getPaymentDate() %></td>
                    <td><%= payment.getLessonId() %></td>
                    <td><%= payment.getStatus() %></td>
                    <td>
                        <form action="${pageContext.request.contextPath}/payment" method="post" style="display:inline;">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="paymentId" value="<%= payment.getPaymentId() %>">
                            <select name="status">
                                <option value="Completed">Approve</option>
                                <option value="Denied">Deny</option>
                            </select>
                            <input type="submit" value="Update">
                        </form>
                        <form action="${pageContext.request.contextPath}/payment" method="post" style="display:inline;">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="paymentId" value="<%= payment.getPaymentId() %>">
                            <input type="submit" value="Delete" onclick="return confirm('Are you sure you want to delete this payment?');">
                        </form>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>
    <% } %>

    <a href="${pageContext.request.contextPath}/dashboard">Back to Dashboard</a>
</body>
</html>