<nav class="bg-green-600 text-white shadow-md">
    <div class="container mx-auto px-4 py-3 flex justify-between items-center">
        <a href="<%= request.getContextPath() %>/jsp/instructorPages/instructorHome.jsp" class="text-xl font-bold">Driving School Instructor</a>
        <div class="space-x-4">
            <a href="<%= request.getContextPath() %>/jsp/instructorPages/instructorHome.jsp" class="hover:bg-green-700 px-3 py-2 rounded-md transition duration-200">Home</a>
            <a href="<%= request.getContextPath() %>/lesson?action=list" class="hover:bg-green-700 px-3 py-2 rounded-md transition duration-200">View Schedule</a>
            <a href="<%= request.getContextPath() %>/instructor?action=updateAvailability&id=<%= ((com.Model.User) session.getAttribute("loggedInUser")).getId() %>" class="hover:bg-green-700 px-3 py-2 rounded-md transition duration-200">Update Availability</a>
            <a href="<%= request.getContextPath() %>/instructor?action=profile&id=<%= ((com.Model.User) session.getAttribute("loggedInUser")).getId() %>" class="hover:bg-green-700 px-3 py-2 rounded-md transition duration-200">View/Edit Profile</a>
            <a href="<%= request.getContextPath() %>/progress?action=viewProgress" class="hover:bg-green-700 px-3 py-2 rounded-md transition duration-200">Progress List</a>
            <form action="<%= request.getContextPath() %>/logout" method="post" class="inline">
                <button type="submit" class="hover:bg-red-600 px-3 py-2 rounded-md transition duration-200 bg-transparent border-none text-white cursor-pointer">
                    Logout
                </button>
            </form>
        </div>
    </div>
</nav>