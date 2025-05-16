<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.Review" %>
<%@ page import="com.Model.User" %>
<%@ page import="java.util.List" %>
<%!
    // Utility method to escape HTML special characters
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
<%
    // Get current user from session
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    // Get attributes from request
    String type = (String) request.getAttribute("type");
    String targetId = (String) request.getAttribute("targetId");
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    String errorMessage = (String) request.getAttribute("error");

    // Get success message from session if present
    String successMessage = (String) session.getAttribute("successMessage");
    if (successMessage != null) {
        session.removeAttribute("successMessage");
    }

    String typeDisplay = "lesson".equals(type) ? "Lesson" : "Instructor";
%>
<html>
<head>
    <title>View Reviews</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body class="bg-gray-50 min-h-screen">
  <%@ include file="studentNavbar.jsp" %>
    <div class="max-w-2xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <div class="bg-white shadow rounded-lg p-8">
            <div class="flex items-center justify-between mb-6">
                <div>
                    <h2 class="text-2xl font-bold text-gray-800">View Reviews</h2>
                    <% if (type != null && targetId != null) { %>
                        <p class="text-gray-600">Reviews for <%= escapeHtml(typeDisplay) %> <%= escapeHtml(targetId) %></p>
                    <% } else { %>
                        <p class="text-gray-600">All Approved Reviews</p>
                    <% } %>
                </div>
                <a href="${pageContext.request.contextPath}/submitFeedback" class="text-blue-600 hover:text-blue-800 flex items-center">
                    <i class="fas fa-arrow-left mr-2"></i> Back to Feedback
                </a>
            </div>

            <% if (successMessage != null) { %>
                <div class="mb-4 p-4 bg-green-100 text-green-700 rounded-lg">
                    <%= escapeHtml(successMessage) %>
                </div>
            <% } %>

            <% if (errorMessage != null) { %>
                <div class="mb-4 p-4 bg-red-100 text-red-700 rounded-lg">
                    <%= escapeHtml(errorMessage) %>
                </div>
            <% } %>

            <% if (reviews == null || reviews.isEmpty()) { %>
                <div class="p-6 bg-gray-50 border border-gray-200 rounded-lg text-center">
                    <p class="text-gray-600">No reviews available for this selection.</p>
                    <a href="${pageContext.request.contextPath}/review?action=submit<%= targetId != null ? "&targetId=" + escapeHtml(targetId) : "" %><%= type != null ? "&type=" + escapeHtml(type) : "" %>" class="mt-4 inline-block px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
                        Submit a Review
                    </a>
                </div>
            <% } else { %>
                <div class="space-y-6">
                    <% for (Review review : reviews) { %>
                        <div class="p-6 bg-gray-50 border border-gray-200 rounded-lg">
                            <div class="flex items-center justify-between mb-2">
                                <div class="flex items-center">
                                    <% for (int i = 1; i <= review.getRating(); i++) { %>
                                        <span class="text-yellow-400 text-xl">★</span>
                                    <% } %>
                                    <% for (int i = review.getRating() + 1; i <= 5; i++) { %>
                                        <span class="text-gray-300 text-xl">★</span>
                                    <% } %>
                                </div>
                                <div class="flex items-center">
                                    <span class="text-sm text-gray-500 mr-2">
                                        <%= escapeHtml(review.getSubmissionDate().toString()) %>
                                    </span>
                                    <span class="px-2 py-1 text-xs font-medium rounded-full
                                        <%= review instanceof com.Model.LessonReview ? "bg-blue-100 text-blue-800" : "bg-purple-100 text-purple-800" %>">
                                        <%= review instanceof com.Model.LessonReview ? "Lesson" : "Instructor" %>
                                    </span>
                                </div>
                            </div>
                            <p class="text-gray-700 mb-2"><%= escapeHtml(review.getFeedback()) %></p>
                            <p class="text-sm text-gray-500">
                                <%= review instanceof com.Model.LessonReview ? "Lesson" : "Instructor" %> ID:
                                <%= escapeHtml(review.getTargetId()) %>
                            </p>
                        </div>
                    <% } %>
                    <div class="mt-6 text-center">
                        <a href="${pageContext.request.contextPath}/review?action=submit" class="inline-block px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
                            Submit New Review
                        </a>
                    </div>
                </div>
            <% } %>
        </div>
    </div>

    <script>
        // Debug: Log review data
        console.log('Debug: Reviews data received on ViewReviews.jsp');
        console.log('Type:', '<%= type != null ? escapeHtml(type) : "null" %>');
        console.log('TargetId:', '<%= targetId != null ? escapeHtml(targetId) : "null" %>');
        console.log('Reviews:', <% if (reviews == null) { %> null <% } else { %> [
            <% for (int i = 0; i < reviews.size(); i++) { %>
                {
                    reviewId: '<%= escapeHtml(reviews.get(i).getReviewId()) %>',
                    studentId: '<%= escapeHtml(reviews.get(i).getStudentId()) %>',
                    targetId: '<%= escapeHtml(reviews.get(i).getTargetId()) %>',
                    feedback: '<%= escapeHtml(reviews.get(i).getFeedback()) %>',
                    rating: <%= reviews.get(i).getRating() %>,
                    submissionDate: '<%= escapeHtml(reviews.get(i).getSubmissionDate().toString()) %>',
                    status: '<%= escapeHtml(reviews.get(i).getStatus()) %>',
                    type: '<%= reviews.get(i) instanceof com.Model.LessonReview ? "Lesson" : "Instructor" %>'
                }<%= i < reviews.size() - 1 ? "," : "" %>
            <% } %>
        ] <% } %>);
        console.log('Reviews count:', <%= reviews != null ? reviews.size() : 0 %>);
        console.log('Error message:', '<%= errorMessage != null ? escapeHtml(errorMessage) : "none" %>');
    </script>
</body>
</html>