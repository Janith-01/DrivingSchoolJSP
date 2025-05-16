<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.Model.Review" %>
<%!
    private String escapeHtml(String input) {
        if (input == null) return "";
        StringBuilder escaped = new StringBuilder();
        for (char c : input.toCharArray()) {
            switch (c) {
                case '&': escaped.append("&"); break;
                case '<': escaped.append("<"); break;
                case '>': escaped.append(">"); break;
                case '"': escaped.append("\""); break;
                case '\'': escaped.append("'"); break;
                default: escaped.append(c); break;
            }
        }
        return escaped.toString();
    }
%>
<html>
<head>
    <title>Review Moderation | Admin Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .feedback-text {
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
            transition: all 0.3s ease;
        }
        .feedback-text.expanded {
            -webkit-line-clamp: unset;
        }
        .rating-star {
            color: #fbbf24;
        }
    </style>
</head>
<body class="bg-gray-50 font-sans">
<%@ include file="adminNavbar.jsp" %>
    <div class="container mx-auto px-4 py-8">
        <div class="flex justify-between items-center mb-8">
            <div>
                <h1 class="text-2xl font-bold text-gray-800">Review Moderation</h1>
                <p class="text-gray-600">Manage and moderate user reviews</p>
            </div>
        </div>

        <!-- Success Message -->
        <% String successMessage = (String) session.getAttribute("successMessage");
           if (successMessage != null && !successMessage.isEmpty()) { 
               session.removeAttribute("successMessage"); %>
            <div class="bg-green-50 border-l-4 border-green-500 p-4 mb-6 rounded">
                <div class="flex">
                    <div class="flex-shrink-0">
                        <i class="fas fa-check-circle text-green-500"></i>
                    </div>
                    <div class="ml-3">
                        <p class="text-sm text-green-700"><%= escapeHtml(successMessage) %></p>
                    </div>
                </div>
            </div>
        <% } %>

        <!-- Error Message -->
        <% String error = (String) request.getAttribute("error");
           if (error != null && !error.isEmpty()) { %>
            <div class="bg-red-50 border-l-4 border-red-500 p-4 mb-6 rounded">
                <div class="flex">
                    <div class="flex-shrink-0">
                        <i class="fas fa-exclamation-circle text-red-500"></i>
                    </div>
                    <div class="ml-3">
                        <p class="text-sm text-red-700"><%= escapeHtml(error) %></p>
                    </div>
                </div>
            </div>
        <% } %>

        <!-- Reviews Container -->
        <div class="bg-white shadow rounded-lg overflow-hidden">
            <!-- Reviews Header -->
            <div class="px-6 py-4 border-b border-gray-200 bg-gray-50">
                <div class="flex items-center justify-between">
                    <h2 class="text-lg font-semibold text-gray-800">User Reviews</h2>
                    <div class="relative w-64">
                        <input type="text" placeholder="Search reviews..." 
                               class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                        <i class="fas fa-search absolute left-3 top-3 text-gray-400"></i>
                    </div>
                </div>
            </div>

            <!-- Reviews List -->
            <% if (request.getAttribute("reviews") != null && !((List<Review>) request.getAttribute("reviews")).isEmpty()) { %>
                <div class="divide-y divide-gray-200">
                    <% for (Review review : (List<Review>) request.getAttribute("reviews")) { %>
                    <div class="p-6 hover:bg-gray-50 transition-colors duration-150">
                        <!-- Review Header -->
                        <div class="flex justify-between items-start mb-4">
                            <div class="flex items-center space-x-4">
                                <div class="avatar-placeholder bg-blue-100 text-blue-600 rounded-full h-10 w-10 flex items-center justify-center">
                                    <i class="fas fa-user"></i>
                                </div>
                                <div>
                                    <h3 class="font-medium text-gray-800">User ID: <%= escapeHtml(review.getStudentId()) %></h3>
                                    <div class="flex items-center mt-1">
                                        <% for (int i = 0; i < 5; i++) { %>
                                            <i class="fas fa-star <%= i < review.getRating() ? "rating-star" : "text-gray-300" %> mr-0.5 text-sm"></i>
                                        <% } %>
                                        <span class="text-xs text-gray-500 ml-2"><%= escapeHtml(review.getSubmissionDate().toString()) %></span>
                                    </div>
                                </div>
                            </div>
                            <span class="status-badge <%= 
                                "Approved".equals(review.getStatus()) ? "bg-green-100 text-green-800" : 
                                "Pending".equals(review.getStatus()) ? "bg-yellow-100 text-yellow-800" : 
                                "bg-red-100 text-red-800" %> px-2 py-1 rounded text-sm">
                                <%= escapeHtml(review.getStatus()) %>
                            </span>
                        </div>
                        
                        <!-- Review Content -->
                        <div class="mb-4">
                            <div class="feedback-text text-gray-700">
                                <%= escapeHtml(review.getFeedback()) %>
                            </div>
                            <button onclick="toggleFeedback(this)" 
                                    class="text-blue-600 text-sm font-medium mt-2 hover:underline focus:outline-none">
                                Show <span class="more-less">more</span>
                            </button>
                        </div>
                        
                        <!-- Review Actions -->
                        <div class="flex justify-end space-x-4">
                            <form action="<%= request.getContextPath() %>/review" method="post" class="flex items-center">
                                <input type="hidden" name="action" value="updateStatus">
                                <input type="hidden" name="reviewId" value="<%= escapeHtml(review.getReviewId()) %>">
                                <select name="status" data-original-status="<%= escapeHtml(review.getStatus()) %>"
                                        onchange="confirmStatusChange(this)" 
                                        class="border border-gray-300 rounded-lg px-3 py-1.5 text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                                    <option value="Pending" <%= "Pending".equals(review.getStatus()) ? "selected" : "" %>>Pending</option>
                                    <option value="Approved" <%= "Approved".equals(review.getStatus()) ? "selected" : "" %>>Approve</option>
                                    <option value="Removed" <%= "Removed".equals(review.getStatus()) ? "selected" : "" %>>Remove</option>
                                </select>
                            </form>
                            <form action="<%= request.getContextPath() %>/review" method="post">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="reviewId" value="<%= escapeHtml(review.getReviewId()) %>">
                                <button type="submit" onclick="return confirm('Are you sure you want to delete this review?');" 
                                        class="text-red-600 hover:text-red-800 focus:outline-none">
                                    <i class="fas fa-trash-alt mr-1"></i> Delete
                                </button>
                            </form>
                        </div>
                    </div>
                    <% } %>
                </div>
            <% } else { %>
                <div class="p-12 text-center">
                    <i class="fas fa-comment-slash text-4xl text-gray-300 mb-4"></i>
                    <h3 class="text-lg font-medium text-gray-700">No reviews to moderate</h3>
                    <p class="text-gray-500 mt-1">All reviews have been processed.</p>
                </div>
            <% } %>
        </div>
    </div>

    <script>
        function toggleFeedback(button) {
            const feedbackDiv = button.previousElementSibling;
            feedbackDiv.classList.toggle('expanded');
            const moreLessSpan = button.querySelector('.more-less');
            moreLessSpan.textContent = feedbackDiv.classList.contains('expanded') ? 'less' : 'more';
        }

        function confirmStatusChange(select) {
            const originalStatus = select.getAttribute('data-original-status');
            if (select.value === 'Removed') {
                if (!confirm('Are you sure you want to remove this review?')) {
                    select.value = originalStatus;
                    return false;
                }
            }
            select.form.submit();
        }
    </script>
</body>
</html>
