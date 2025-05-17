<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.Lesson" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Process Payment</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <style>
        .card-input {
            background-image: url("data:image/svg+xml,%3Csvg width='24' height='16' viewBox='0 0 24 16' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M21 0H3C1.34315 0 0 1.34315 0 3V13C0 14.6569 1.34315 16 3 16H21C22.6569 16 24 14.6569 24 13V3C24 1.34315 22.6569 0 21 0Z' fill='%23E5E7EB'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 0.75rem center;
            background-size: 24px 16px;
        }
        .card-input.visa {
            background-image: url("data:image/svg+xml,%3Csvg width='24' height='16' viewBox='0 0 24 16' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M21 0H3C1.34315 0 0 1.34315 0 3V13C0 14.6569 1.34315 16 3 16H21C22.6569 16 24 14.6569 24 13V3C24 1.34315 22.6569 0 21 0Z' fill='%231A73E8'/%3E%3C/svg%3E");
        }
    </style>
</head>
<body class="bg-gradient-to-br from-blue-50 to-indigo-100 min-h-screen">
<%@ include file="studentNavbar.jsp" %>
    <div class="container mx-auto px-4 py-8 max-w-2xl">
        <div class="bg-white rounded-xl shadow-lg overflow-hidden">
            <!-- Header -->
            <div class="bg-indigo-600 px-6 py-4">
                <div class="flex items-center justify-between">
                    <h1 class="text-2xl font-bold text-white">Payment Processing</h1>
                    <div class="text-white text-sm bg-indigo-700 px-3 py-1 rounded-full">
                        <i class="far fa-credit-card mr-1"></i> Secure Payment
                    </div>
                </div>
                <p class="text-indigo-100 mt-1">Current Date & Time: <%= new java.text.SimpleDateFormat("EEEE, MMMM dd, yyyy hh:mm a z").format(new java.util.Date()) %></p>
            </div>

            <% if (request.getAttribute("error") != null) { %>
                <div class="bg-red-50 border-l-4 border-red-500 text-red-700 p-4 mx-6 mt-4 rounded-r" role="alert">
                    <div class="flex items-center">
                        <i class="fas fa-exclamation-circle mr-2"></i>
                        <p class="font-medium"><%= request.getAttribute("error") %></p>
                    </div>
                </div>
            <% } %>

            <%
                User loggedInUser = (User) session.getAttribute("loggedInUser");
                String studentId = "";
                if (loggedInUser != null && loggedInUser instanceof com.Model.Student) {
                    studentId = loggedInUser.getId();
                } else {
                    response.sendRedirect(request.getContextPath() + "/login");
                    return;
                }
            %>

            <%
                List<Lesson> lessons = (List<Lesson>) request.getAttribute("lessons");
                if (lessons == null) {
                    lessons = new java.util.ArrayList<>();
                }
            %>

            <form action="${pageContext.request.contextPath}/payment" method="POST" onsubmit="return validateForm()" class="p-6">
                <input type="hidden" name="action" value="process">
                <input type="hidden" name="studentId" value="<%= studentId %>">

                <!-- Lesson Selection -->
                <div class="mb-6">
                    <label for="lessonId" class="block text-sm font-medium text-gray-700 mb-1">Select Lesson</label>
                    <div class="relative">
                        <select id="lessonId" name="lessonId" class="block w-full pl-3 pr-10 py-2 text-base border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 rounded-lg" required>
                            <option value="" disabled selected>Select a lesson</option>
                            <% for (Lesson lesson : lessons) { %>
                                <option value="<%= lesson.getLessonId() %>">
                                    <%= lesson.getType() %> Lesson - <%= lesson.getDate() %> <%= lesson.getTime() %>
                                </option>
                            <% } %>
                        </select>
                        <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
                            <i class="fas fa-chevron-down"></i>
                        </div>
                    </div>
                    <div id="lessonIdError" class="text-red-500 text-xs mt-1"></div>
                </div>

                <!-- Amount -->
                <div class="mb-6">
                    <label for="amount" class="block text-sm font-medium text-gray-700 mb-1">Amount</label>
                    <div class="relative rounded-md shadow-sm">
                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <span class="text-gray-500 sm:text-sm">$</span>
                        </div>
                        <input type="number" id="amount" name="amount" class="block w-full pl-7 pr-12 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500" required readonly>
                        <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                            <span class="text-gray-500 sm:text-sm">USD</span>
                        </div>
                    </div>
                    <div id="amountError" class="text-red-500 text-xs mt-1"></div>
                </div>

                <!-- Payment Type -->
                <div class="mb-6">
                    <label class="block text-sm font-medium text-gray-700 mb-2">Payment Method</label>
                    <div class="grid grid-cols-2 gap-3">
                        <div>
                            <input type="radio" id="cashOption" name="paymentType" value="Cash" class="hidden peer" onchange="toggleCardDetails()">
                            <label for="cashOption" class="flex items-center justify-center p-3 border border-gray-300 rounded-lg cursor-pointer peer-checked:border-indigo-500 peer-checked:bg-indigo-50 peer-checked:ring-1 peer-checked:ring-indigo-500">
                                <i class="fas fa-money-bill-wave text-gray-600 mr-2"></i>
                                <span>Cash</span>
                            </label>
                        </div>
                        <div>
                            <input type="radio" id="cardOption" name="paymentType" value="Card" class="hidden peer" onchange="toggleCardDetails()">
                            <label for="cardOption" class="flex items-center justify-center p-3 border border-gray-300 rounded-lg cursor-pointer peer-checked:border-indigo-500 peer-checked:bg-indigo-50 peer-checked:ring-1 peer-checked:ring-indigo-500">
                                <i class="far fa-credit-card text-gray-600 mr-2"></i>
                                <span>Card</span>
                            </label>
                        </div>
                    </div>
                    <div id="paymentTypeError" class="text-red-500 text-xs mt-1"></div>
                </div>

                <!-- Card Details (Hidden by default) -->
                <div id="cardDetails" class="hidden space-y-4 mb-6">
                    <div class="border-t border-gray-200 pt-4">
                        <h3 class="text-lg font-medium text-gray-900 mb-3 flex items-center">
                            <i class="fas fa-credit-card mr-2 text-indigo-600"></i>
                            Card Information
                        </h3>

                        <!-- Card Number -->
                        <div class="mb-4">
                            <label for="cardNumber" class="block text-sm font-medium text-gray-700 mb-1">Card Number</label>
                            <input type="text" id="cardNumber" name="cardNumber" placeholder="0000-0000-0000-0000" class="card-input block w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500" maxlength="19" oninput="formatCardNumber(this)">
                            <div id="cardNumberError" class="text-red-500 text-xs mt-1"></div>
                        </div>

                        <div class="grid grid-cols-2 gap-4">
                            <!-- Expiry Date -->
                            <div>
                                <label for="expiryDate" class="block text-sm font-medium text-gray-700 mb-1">Expiry Date</label>
                                <input type="text" id="expiryDate" name="expiryDate" placeholder="MM/YY" class="block w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500" maxlength="5" oninput="formatExpiryDate(this)">
                                <div id="expiryDateError" class="text-red-500 text-xs mt-1"></div>
                            </div>

                            <!-- CVV -->
                            <div>
                                <label for="cvv" class="block text-sm font-medium text-gray-700 mb-1">CVV</label>
                                <div class="relative">
                                    <input type="text" id="cvv" name="cvv" placeholder="123" class="block w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500" maxlength="3">
                                    <div class="absolute inset-y-0 right-0 pr-3 flex items-center cursor-pointer" onclick="showCVVTooltip()">
                                        <i class="fas fa-question-circle text-gray-400 hover:text-gray-600"></i>
                                    </div>
                                </div>
                                <div id="cvvError" class="text-red-500 text-xs mt-1"></div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div class="flex justify-center mt-8">
                    <button type="submit" class="flex items-center justify-center px-4 py-2 border border-transparent rounded-lg shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                        <i class="fas fa-lock mr-2"></i> Pay Now
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- CVV Tooltip (hidden by default) -->
    <div id="cvvTooltip" class="hidden fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div class="bg-white rounded-lg p-6 max-w-sm mx-4">
            <div class="flex justify-between items-center mb-4">
                <h3 class="text-lg font-medium text-gray-900">What is CVV?</h3>
                <button onclick="hideCVVTooltip()" class="text-gray-400 hover:text-gray-500">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <p class="text-gray-600 mb-4">The CVV is a 3-digit code on the back of your card (or 4 digits for American Express).</p>
            <div class="flex justify-center p-4 bg-gray-50 rounded-lg">
                <div class="text-center">
                    <div class="mb-2 flex justify-center">
                        <i class="fas fa-credit-card text-indigo-500 text-3xl"></i>
                    </div>
                    <p class="text-sm text-gray-600">For most cards: Look for the last 3 digits on the signature strip on the back of your card.</p>
                    <p class="text-sm text-gray-600 mt-2">For American Express: Look for the 4 digits on the front of your card.</p>
                </div>
            </div>
            <div class="mt-4 flex justify-end">
                <button onclick="hideCVVTooltip()" class="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700">Got it</button>
            </div>
        </div>
    </div>

    <script>
        function toggleCardDetails() {
            const paymentType = document.querySelector('input[name="paymentType"]:checked')?.value;
            const cardDetails = document.getElementById('cardDetails');
            cardDetails.classList.toggle('hidden', paymentType !== 'Card');

            const cardNumberInput = document.getElementById('cardNumber');
            if (paymentType === 'Card') {
                cardNumberInput.classList.add('card-input');
            } else {
                cardNumberInput.classList.remove('card-input', 'visa');
            }
        }

        function formatCardNumber(input) {
            let value = input.value.replace(/\D/g, '');
            value = value.replace(/(\d{4})(?=\d)/g, '$1 ');
            input.value = value;

            const firstDigit = value.charAt(0);
            const cardInput = document.getElementById('cardNumber');
            cardInput.classList.remove('visa');
            if (firstDigit === '4') {
                cardInput.classList.add('visa');
            }
        }

        function formatExpiryDate(input) {
            let value = input.value.replace(/\D/g, '');
            if (value.length > 2) {
                value = value.substring(0, 2) + '/' + value.substring(2, 4);
            }
            input.value = value;
        }

        function showCVVTooltip() {
            document.getElementById('cvvTooltip').classList.remove('hidden');
        }

        function hideCVVTooltip() {
            document.getElementById('cvvTooltip').classList.add('hidden');
        }

        function validateForm() {
            let isValid = true;
            const lessonId = document.getElementById('lessonId').value;
            const amount = document.getElementById('amount').value;
            const paymentType = document.querySelector('input[name="paymentType"]:checked')?.value;
            const cardNumber = document.getElementById('cardNumber')?.value;
            const expiryDate = document.getElementById('expiryDate')?.value;
            const cvv = document.getElementById('cvv')?.value;

            document.querySelectorAll('[id$="Error"]').forEach(el => el.textContent = "");

            if (!lessonId) {
                document.getElementById("lessonIdError").textContent = "Please select a lesson";
                isValid = false;
            }

            if (!amount || amount <= 0) {
                document.getElementById("amountError").textContent = "Please enter a valid amount";
                isValid = false;
            }

            if (!paymentType) {
                document.getElementById("paymentTypeError").textContent = "Please select a payment method";
                isValid = false;
            }

            if (paymentType === 'Card') {
                const cardDigits = cardNumber?.replace(/\s+/g, '');
                if (!cardDigits || cardDigits.length !== 16) {
                    document.getElementById("cardNumberError").textContent = "Please enter a valid 16-digit card number";
                    isValid = false;
                }

                const expiryRegex = /^(0[1-9]|1[0-2])\/\d{2}$/;
                if (!expiryDate || !expiryDate.match(expiryRegex)) {
                    document.getElementById("expiryDateError").textContent = "Please enter a valid expiry date (MM/YY)";
                    isValid = false;
                } else {
                    const [month, year] = expiryDate.split('/').map(Number);
                    const currentYear = new Date().getFullYear() % 100;
                    const currentMonth = new Date().getMonth() + 1;
                    if (year < currentYear || (year === currentYear && month < currentMonth)) {
                        document.getElementById("expiryDateError").textContent = "Card has expired";
                        isValid = false;
                    }
                }

                if (!cvv || cvv.length !== 3) {
                    document.getElementById("cvvError").textContent = "Please enter a valid 3-digit CVV";
                    isValid = false;
                }
            }

            return isValid;
        }

        document.getElementById('lessonId').addEventListener('change', function() {
            const lessonId = this.value;
            const amountField = document.getElementById('amount');
            <% for (Lesson lesson : lessons) { %>
                if (lessonId === '<%= lesson.getLessonId() %>') {
                    amountField.value = <%= "Beginner".equals(lesson.getType()) ? "70.00" : "130.00" %>;
                }
            <% } %>
        });
    </script>
</body>
</html>