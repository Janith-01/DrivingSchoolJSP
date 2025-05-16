<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Invoice</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-gradient-to-br from-blue-50 to-indigo-100 min-h-screen">
    <div class="container mx-auto px-4 py-8 max-w-3xl">
        <div class="bg-white rounded-xl shadow-lg overflow-hidden">
            <!-- Invoice Header -->
            <div class="bg-indigo-600 px-6 py-4">
                <div class="flex flex-col sm:flex-row justify-between items-center">
                    <div class="mb-4 sm:mb-0">
                        <h1 class="text-2xl font-bold text-white">Payment Invoice</h1>
                        <p class="text-indigo-100">Generated on: <%= new java.text.SimpleDateFormat("EEEE, MMMM dd, yyyy hh:mm a z").format(new java.util.Date()) %></p>
                    </div>
                    <div class="bg-white px-4 py-2 rounded-lg shadow-sm">
                        <span class="text-indigo-600 font-bold">INVOICE</span>
                    </div>
                </div>
            </div>

            <!-- Invoice Content -->
            <div class="p-6">
                <div class="bg-gray-50 rounded-lg p-6 mb-6">
                    <pre class="text-sm text-gray-700 whitespace-pre-wrap font-mono"><%= request.getAttribute("invoice") %></pre>
                </div>

                <!-- Payment Confirmation -->
                <div class="bg-green-50 border-l-4 border-green-500 p-4 rounded-r mb-6">
                    <div class="flex items-center">
                        <div class="flex-shrink-0">
                            <i class="fas fa-check-circle text-green-500 text-2xl"></i>
                        </div>
                        <div class="ml-3">
                            <h3 class="text-sm font-medium text-green-800">Payment Successful</h3>
                            <p class="text-sm text-green-700 mt-1">Your payment has been processed successfully. A receipt has been sent to your email.</p>
                        </div>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div class="flex flex-col sm:flex-row justify-center space-y-3 sm:space-y-0 sm:space-x-4">
                    <button onclick="window.print()" class="flex items-center justify-center px-4 py-2 border border-gray-300 rounded-lg shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                        <i class="fas fa-print mr-2"></i> Print Invoice
                    </button>
                    <a href="${pageContext.request.contextPath}/payment?action=history&studentId=<%= session.getAttribute("loggedInUser") != null ? ((com.Model.User)session.getAttribute("loggedInUser")).getId() : "" %>" class="flex items-center justify-center px-4 py-2 border border-transparent rounded-lg shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                        <i class="fas fa-history mr-2"></i> View Payment History
                    </a>
                </div>
            </div>

            <!-- Footer -->
            <div class="bg-gray-50 px-6 py-4 border-t border-gray-200">
                <div class="flex flex-col md:flex-row justify-between items-center">
                    <div class="text-sm text-gray-500 mb-4 md:mb-0">
                        <p>Thank you for your business!</p>
                    </div>
                    <div class="flex space-x-4">
                        <a href="#" class="text-gray-400 hover:text-gray-500">
                            <i class="fas fa-question-circle"></i>
                        </a>
                        <a href="#" class="text-gray-400 hover:text-gray-500">
                            <i class="fas fa-envelope"></i>
                        </a>
                        <a href="#" class="text-gray-400 hover:text-gray-500">
                            <i class="fas fa-phone"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>