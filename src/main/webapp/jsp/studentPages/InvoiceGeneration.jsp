<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.Invoice" %>
<%@ page import="com.Model.Payment" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Invoice</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100 font-sans">
<%@ include file="studentNavbar.jsp" %>
    <div class="container mx-auto px-4 py-8 max-w-3xl">
        <div class="bg-white rounded-xl shadow-lg p-6">
            <%
                User loggedInUser = (User) session.getAttribute("loggedInUser");
                if (loggedInUser == null || !(loggedInUser instanceof com.Model.Student)) {
                    response.sendRedirect(request.getContextPath() + "/login");
                    return;
                }

                Invoice invoice = (Invoice) request.getAttribute("invoice");
                Payment payment = (Payment) request.getAttribute("payment");
                if (invoice == null || payment == null) {
                    response.sendRedirect(request.getContextPath() + "/payment?action=history&studentId=" + loggedInUser.getId());
                    return;
                }

                boolean isCorporate = loggedInUser.getName().toLowerCase().contains("corporate");
            %>

            <!-- Header -->
            <div class="flex justify-between items-center mb-6">
                <div>
                    <h1 class="text-2xl font-bold text-gray-900">Invoice</h1>
                    <p class="text-gray-600">Invoice #: <%= invoice.getInvoiceId() %></p>
                </div>
                <div class="text-right">
                    <p class="text-gray-600">Date: <%= invoice.getInvoiceDate().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd")) %></p>
                    <p class="text-gray-600">Status: <span class="font-semibold <%= invoice.getStatus().equalsIgnoreCase("Completed") ? "text-green-600" : invoice.getStatus().equalsIgnoreCase("Pending") ? "text-yellow-600" : "text-red-600" %>"><%= invoice.getStatus() %></span></p>
                </div>
            </div>

            <!-- Billed To -->
            <div class="mb-6">
                <h2 class="text-lg font-semibold text-gray-900 mb-2">Billed To</h2>
                <% if (isCorporate) { %>
                    <p class="text-gray-700"><%= loggedInUser.getName() %> (Corporate Client)</p>
                    <p class="text-gray-600">Corporate ID: <%= loggedInUser.getId() %></p>
                <% } else { %>
                    <p class="text-gray-700"><%= loggedInUser.getName() %></p>
                    <p class="text-gray-600">Student ID: <%= loggedInUser.getId() %></p>
                <% } %>
            </div>

            <!-- Invoice Details -->
            <div class="mb-6">
                <h2 class="text-lg font-semibold text-gray-900 mb-2">Invoice Details</h2>
                <div class="border rounded-lg overflow-hidden">
                    <table class="min-w-full">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Description</th>
                                <th class="px-4 py-2 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr class="border-t">
                                <td class="px-4 py-2 text-sm text-gray-700">Driving Lesson (Lesson ID: <%= payment.getLessonId() %>)</td>
                                <td class="px-4 py-2 text-sm text-gray-700 text-right">$<%= String.format("%.2f", payment.getAmount()) %></td>
                            </tr>
                            <% if (isCorporate) { %>
                                <tr class="border-t">
                                    <td class="px-4 py-2 text-sm text-gray-700">Corporate Discount (10%)</td>
                                    <td class="px-4 py-2 text-sm text-gray-700 text-right">-$<%= String.format("%.2f", payment.getAmount() * 0.10) %></td>
                                </tr>
                            <% } %>
                        </tbody>
                        <tfoot>
                            <tr class="border-t bg-gray-50">
                                <td class="px-4 py-2 text-sm font-semibold text-gray-900">Total</td>
                                <td class="px-4 py-2 text-sm font-semibold text-gray-900 text-right">$<%= String.format("%.2f", isCorporate ? payment.getAmount() * 0.90 : payment.getAmount()) %></td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>

            <!-- Payment Method -->
            <div class="mb-6">
                <h2 class="text-lg font-semibold text-gray-900 mb-2">Payment Method</h2>
                <p class="text-gray-700">
                    <%= payment instanceof com.Model.CardPayment ? "Card (**** **** **** " + ((CardPayment) payment).getCardNumber().substring(12) + ")" : "Cash" %>
                </p>
            </div>

            <!-- Actions -->
            <div class="flex justify-end space-x-4">
                <a href="${pageContext.request.contextPath}/payment?action=history&studentId=<%= loggedInUser.getId() %>" class="flex items-center px-4 py-2 border border-gray-300 rounded-lg shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                    <i class="fas fa-arrow-left mr-2"></i> Back to History
                </a>
                <button onclick="window.print()" class="flex items-center px-4 py-2 border border-transparent rounded-lg shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                    <i class="fas fa-print mr-2"></i> Print Invoice
                </button>
            </div>
        </div>
    </div>
</body>
</html>