<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Submit Feedback</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body class="bg-gray-50 min-h-screen">
<%@ include file="studentNavbar.jsp" %>
    <div class="max-w-2xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <div class="bg-white shadow rounded-lg p-8">
            <div class="flex items-center justify-between mb-6">
                <div>
                    <h2 class="text-2xl font-bold text-gray-800">Submit Feedback</h2>
                    <p class="text-gray-600">Share your experience with us</p>
                </div>
                <a href="${pageContext.request.contextPath}/studentHome.jsp" class="text-blue-600 hover:text-blue-800 flex items-center">
                    <i class="fas fa-arrow-left mr-2"></i> Back to Dashboard
                </a>
            </div>

            <%-- Display Success Message --%>
            <% if (request.getAttribute("successMessage") != null) { %>
                <div class="mb-6 p-4 bg-green-50 border-l-4 border-green-500 text-green-700">
                    <p><i class="fas fa-check-circle mr-2"></i><%= request.getAttribute("successMessage") %></p>
                </div>
            <% } else if (request.getAttribute("error") != null) { %>
                <div class="mb-6 p-4 bg-red-50 border-l-4 border-red-500 text-red-700">
                    <p><i class="fas fa-exclamation-circle mr-2"></i><%= request.getAttribute("error") %></p>
                </div>
            <% } %>

            <form id="feedbackForm" action="${pageContext.request.contextPath}/review" method="post" class="space-y-6">
                <input type="hidden" name="action" value="create">
                <input type="hidden" name="redirectUrl" value="<%= request.getContextPath() %>/review?action=view">

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Feedback Type</label>
                    <div class="flex space-x-4">
                        <label class="inline-flex items-center">
                            <input type="radio" name="type" value="lesson" class="h-4 w-4 text-blue-600" checked onchange="fetchTargets()">
                            <span class="ml-2 text-gray-700">Lesson</span>
                        </label>
                        <label class="inline-flex items-center">
                            <input type="radio" name="type" value="instructor" class="h-4 w-4 text-blue-600" onchange="fetchTargets()">
                            <span class="ml-2 text-gray-700">Instructor</span>
                        </label>
                    </div>
                </div>

                <div>
                    <label for="targetId" class="block text-sm font-medium text-gray-700">Instructor/Lesson</label>
                    <select id="targetId" name="targetId" required
                            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 p-2 border">
                        <option value="">Select...</option>
                    </select>
                </div>

                <div>
                    <label for="feedback" class="block text-sm font-medium text-gray-700">Your Feedback</label>
                    <textarea id="feedback" name="feedback" rows="4" required
                              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 p-2 border"
                              placeholder="Share your detailed feedback here..."></textarea>
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Rating</label>
                    <div class="flex items-center space-x-2">
                        <div class="rating-input flex space-x-1">
                            <% for (int i = 1; i <= 5; i++) { %>
                                <button type="button" data-value="<%= i %>"
                                        class="star text-2xl text-gray-300 hover:text-yellow-400 focus:outline-none"
                                        aria-label="Rate <%= i %> star">
                                    ★
                                </button>
                            <% } %>
                        </div>
                        <input type="hidden" name="rating" id="ratingValue" value="1" required>
                        <span class="text-gray-500 text-sm" id="ratingText">1 star</span>
                    </div>
                </div>

                <div class="pt-4">
                    <button type="submit"
                            class="w-full flex justify-center py-3 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors">
                        <i class="fas fa-paper-plane mr-2"></i> Submit Feedback
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Star rating interaction
        document.querySelectorAll('.star').forEach(star => {
            star.addEventListener('click', function() {
                const value = this.getAttribute('data-value');
                document.getElementById('ratingValue').value = value;
                document.getElementById('ratingText').textContent = value + (value === '1' ? ' star' : ' stars');

                document.querySelectorAll('.star').forEach((s, index) => {
                    if (index < value) {
                        s.classList.add('text-yellow-400');
                        s.classList.remove('text-gray-300');
                    } else {
                        s.classList.add('text-gray-300');
                        s.classList.remove('text-yellow-400');
                    }
                });
            });
        });

        // Initialize with 1 star selected
        document.querySelector('.star[data-value="1"]').click();

        // Fetch instructors or lessons based on feedback type
        function fetchTargets() {
            const type = document.querySelector('input[name="type"]:checked').value;
            const select = document.getElementById('targetId');

            select.innerHTML = '<option value="">Loading...</option>';
            select.disabled = true;

            const action = type === 'lesson' ? 'fetchLessons' : 'fetchInstructors';
            const contextPath = "${pageContext.request.contextPath}";
            const url = contextPath + "/review?action=" + action;

            fetch(url)
                .then(response => {
                    if (!response.ok) {
                        throw new Error("HTTP error! Status: " + response.status);
                    }
                    return response.json();
                })
                .then(data => {
                    select.innerHTML = '<option value="">Select...</option>';

                    if (Array.isArray(data) && data.length > 0) {
                        data.forEach(item => {
                            const option = document.createElement('option');
                            if (type === 'lesson') {
                                option.value = item.lessonId;
                                option.textContent = "Lesson " + item.lessonId + " with " + item.instructorName + " (" + item.status + ")";
                            } else {
                                option.value = item.id;
                                option.textContent = item.name;
                            }
                            select.appendChild(option);
                        });
                    } else {
                        const option = document.createElement('option');
                        option.value = "";
                        option.textContent = type === 'lesson' ? "No lessons available" : "No instructors available";
                        select.appendChild(option);
                    }
                })
                .catch(error => {
                    console.error('Error fetching data:', error);
                    select.innerHTML = '<option value="">Error loading data</option>';
                })
                .finally(() => {
                    select.disabled = false;
                });
        }

        // No JavaScript form submission handler needed - using traditional form submission

        // Load targets on page load
        window.onload = function() {
            fetchTargets();
        };
    </script>
</body>
</html>