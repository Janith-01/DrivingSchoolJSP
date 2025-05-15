<nav class="bg-blue-500 text-white shadow-md">
    <div class="container mx-auto px-4 py-3 flex justify-between items-center">
        <a href="<%= request.getContextPath() %>/jsp/studentPages/studentHome.jsp" class="text-xl font-bold">Driving School Student</a>
        <div class="space-x-4">
            <a href="<%= request.getContextPath() %>/jsp/studentPages/studentHome.jsp" class="hover:bg-blue-600 px-3 py-2 rounded-md transition duration-200">Home</a>
            <a href="<%= request.getContextPath() %>/jsp/studentPages/bookingForm.jsp" class="hover:bg-blue-600 px-3 py-2 rounded-md transition duration-200">Book a Lesson</a>
            <a href="<%= request.getContextPath() %>/lesson?action=list" class="hover:bg-blue-600 px-3 py-2 rounded-md transition duration-200">View Lessons</a>
            <a href="<%= request.getContextPath() %>/instructor?action=studentList" class="hover:bg-blue-600 px-3 py-2 rounded-md transition duration-200">View Instructors</a>
            <a href="<%= request.getContextPath() %>/user?action=edit&id=<%= ((com.Model.User) session.getAttribute("loggedInUser")).getId() %>" class="hover:bg-blue-600 px-3 py-2 rounded-md transition duration-200">View/Edit Profile</a>

            <!-- JavaScript-based logout button -->
            <a href="#" id="logoutLink" class="hover:bg-red-600 px-3 py-2 rounded-md transition duration-200">Logout</a>
        </div>
    </div>
</nav>

<script>
    document.getElementById('logoutLink').addEventListener('click', function(e) {
        e.preventDefault();

        // Create a form element
        var form = document.createElement('form');
        form.method = 'POST';
        form.action = '<%= request.getContextPath() %>/logout';
        document.body.appendChild(form);

        // Submit the form
        form.submit();
    });
</script>