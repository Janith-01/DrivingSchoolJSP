<nav class="bg-blue-600 text-white shadow-md">
    <div class="container mx-auto px-4 py-3 flex justify-between items-center">
        <a href="<%= request.getContextPath() %>/adminHome.jsp" class="text-xl font-bold">Driving School Admin</a>
        <div class="space-x-4">
            <a href="<%= request.getContextPath() %>/jsp/adminpages/adminHome.jsp" class="hover:bg-blue-700 px-3 py-2 rounded-md transition duration-200">Home</a>
            <a href="<%= request.getContextPath() %>/user?action=list" class="hover:bg-blue-700 px-3 py-2 rounded-md transition duration-200">Manage Users</a>
            <a href="<%= request.getContextPath() %>/instructor?action=list" class="hover:bg-blue-700 px-3 py-2 rounded-md transition duration-200">Manage Instructors</a>
            <a href="<%= request.getContextPath() %>/payment?action=requests" class="hover:bg-blue-700 px-3 py-2 rounded-md transition duration-200">Payment Requests</a>
            <a href="<%= request.getContextPath() %>/review?action=moderate" class="hover:bg-blue-700 px-3 py-2 rounded-md transition duration-200">Manage Feedback</a>
            <a href="<%= request.getContextPath() %>/logout" class="hover:bg-red-600 px-3 py-2 rounded-md transition duration-200">Logout</a>
        </div>
    </div>
</nav>