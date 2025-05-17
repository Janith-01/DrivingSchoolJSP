<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.Payment" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment History</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-gradient-to-br from-blue-50 to-indigo-100 min-h-screen">
<%@ include file="studentNavbar.jsp" %>
    <div class="container mx-auto px-4 py-8 max-w-6xl">
        <div class="bg-white rounded-xl shadow-lg overflow-hidden">
            <!-- Header -->
            <div class="bg-indigo-600 px-6 py-4">
                <div class="flex flex-col sm:flex-row justify-between items-center">
                    <div>
                        <h1 class="text-2xl font-bold text-white">Payment History</h1>
                        <p class="text-indigo-100">Current Date & Time: <%= new java.text.SimpleDateFormat("EEEE, MMMM dd, yyyy hh:mm a z").format(new java.util.Date()) %></p>
                    </div>
                    <div class="mt-4 sm:mt-0">
                        <a href="${pageContext.request.contextPath}/payment" class="flex items-center justify-center px-4 py-2 border border-transparent rounded-lg shadow-sm text-sm font-medium text-indigo-600 bg-white hover:bg-indigo-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-white">
                            <i class="fas fa-arrow-left mr-2"></i> Back to Payment
                        </a>
                    </div>
                </div>
            </div>

            <%
                User loggedInUser = (User) session.getAttribute("loggedInUser");
                if (loggedInUser == null || !(loggedInUser instanceof com.Model.Student)) {
                    response.sendRedirect(request.getContextPath() + "/login");
                    return;
                }

                List<Payment> payments = (List<Payment>) request.getAttribute("payments");
                if (payments == null) {
                    payments = new java.util.ArrayList<>();
                }
                Double pendingDues = (Double) request.getAttribute("pendingDues");
                if (pendingDues == null) {
                    pendingDues = 0.0;
                }
            %>

            <!-- Content -->
            <div class="p-6">
                <!-- Pending Dues -->
                <div class="mb-6 bg-gray-50 p-4 rounded-lg">
                    <h2 class="text-lg font-semibold text-gray-900 mb-2">Pending Dues</h2>
                    <p class="text-gray-700">Total Pending: <span class="font-semibold text-red-600">$<%= String.format("%.2f", pendingDues) %></span></p>
                </div>

                <% if (payments.isEmpty()) { %>
                    <div class="text-center py-12">
                        <i class="fas fa-receipt text-4xl text-gray-300 mb-4"></i>
                        <h3 class="text-lg font-medium text-gray-900">No payment history available</h3>
                        <p class="mt-1 text-sm text-gray-500">You haven't made any payments yet.</p>
                        <div class="mt-6">
                            <a href="${pageContext.request.contextPath}/payment" class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                                <i class="fas fa-plus mr-2"></i> Make a Payment
                            </a>
                        </div>
                    </div>
                <% } else { %>
                    <!-- Filter/Search -->
                    <div class="mb-6 bg-gray-50 p-4 rounded-lg">
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div>
                                <label for="dateFrom" class="block text-sm font-medium text-gray-700 mb-1">From</label>
                                <input type="date" id="dateFrom" class="block w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
                            </div>
                            <div>
                                <label for="dateTo" class="block text-sm font-medium text-gray-700 mb-1">To</label>
                                <input type="date" id="dateTo" class="block w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
                            </div>
                            <div>
                                <label for="statusFilter" class="block text-sm font-medium text-gray-700 mb-1">Status</label>
                                <select id="statusFilter" class="block w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
                                    <option value="all">All Statuses</option>
                                    <option value="completed">Completed</option>
                                    <option value="pending">Pending</option>
                                    <option value="denied">Denied</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Transactions Table -->
                    <div class="overflow-x-auto">
                        <table class="min-w-full divide-y divide-gray-200">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Payment ID</th>
                                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Amount</th>
                                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
                                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Lesson ID</th>
                                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Method</th>
                                    <th scope="col" class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                                </tr>
                            </thead>
                            <tbody class="bg-white divide-y divide-gray-200">
                                <% for (Payment payment : payments) { %>
                                    <tr class="hover:bg-gray-50">
                                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900"><%= payment.getPaymentId() %></td>
                                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">$<%= String.format("%.2f", payment.getAmount()) %></td>
                                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= payment.getPaymentDate().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) %></td>
                                        <td class="px-6 py-4 whitespace-nowrap">
                                            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full
                                                <%= payment.getStatus().equalsIgnoreCase("Completed") ? "bg-green-100 text-green-800" :
                                                   payment.getStatus().equalsIgnoreCase("Pending") ? "bg-yellow-100 text-yellow-800" :
                                                   "bg-red-100 text-red-800" %>">
                                                <%= payment.getStatus() %>
                                            </span>
                                        </td>
                                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= payment.getLessonId() %></td>
                                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                            <div class="flex items-center">
                                                <% if (payment instanceof com.Model.CardPayment) { %>
                                                    <i class="far fa-credit-card text-gray-400 mr-2"></i>
                                                    <span>Card</span>
                                                <% } else { %>
                                                    <i class="fas fa-money-bill-wave text-gray-400 mr-2"></i>
                                                    <span>Cash</span>
                                                <% } %>
                                            </div>
                                        </td>
                                        <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                            <a href="${pageContext.request.contextPath}/payment?action=generateInvoice&paymentId=<%= payment.getPaymentId() %>" class="text-indigo-600 hover:text-indigo-900 mr-3">
                                                <i class="fas fa-receipt"></i> View Invoice
                                            </a>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <div class="mt-6 flex flex-col sm:flex-row items-center justify-between">
                        <div class="text-sm text-gray-500 mb-4 sm:mb-0">
                            Showing <span class="font-medium">1</span> to <span class="font-medium"><%= payments.size() %></span> of <span class="font-medium"><%= payments.size() %></span> results
                        </div>
                        <div class="flex space-x-2">
                            <button class="px-3 py-1 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed" disabled>
                                Previous
                            </button>
                            <button class="px-3 py-1 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 bg-white hover:bg-gray-50">
                                Next
                            </button>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <script>
        document.getElementById('statusFilter')?.addEventListener('change', function() {
            const status = this.value;
            const rows = document.querySelectorAll('tbody tr');

            rows.forEach(row => {
                const rowStatus = row.querySelector('td:nth-child(4) span').textContent.toLowerCase();
                if (status === 'all' || rowStatus.includes(status)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        });

        document.getElementById('dateFrom')?.addEventListener('change', filterByDate);
        document.getElementById('dateTo')?.addEventListener('change', filterByDate);

        function filterByDate() {
            const fromDate = document.getElementById('dateFrom').value;
            const toDate = document.getElementById('dateTo').value;
            const rows = document.querySelectorAll('tbody tr');
            
            rows.forEach(row => {
                const dateCell = row.querySelector('td:nth-child(3)').textContent;
                const rowDate = new Date(dateCell);
            
                let showRow = true;
                if (fromDate && new Date(fromDate) > rowDate) {
                    showRow = false;
                }
                if (toDate && new Date(toDate) < rowDate) {
                    showRow = false; 
                }
            
                row.style.display = showRow ? '' : 'none';
            });
        }
    </script>
</body>
</html>