<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.User" %>
<html>
<head>
    <title>Student Dashboard - Driving School</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="<%= request.getContextPath() %>/css/styles.css" rel="stylesheet">
</head>
<body class="bg-gray-100">
<!-- Include Navigation Bar -->
<%@ include file="studentNavbar.jsp" %>

<div class="container mx-auto p-6">
    <div class="bg-white shadow-lg rounded-lg p-8 max-w-4xl mx-auto">
        <h2 class="text-4xl font-bold text-gray-800 mb-6">Welcome, <%= ((User) session.getAttribute("loggedInUser")).getName() %>!</h2>
        <p class="text-lg text-gray-600 mb-8">You are logged in as a <span class="font-semibold text-blue-500">Student</span>. Book and manage your driving lessons from this dashboard.</p>

        <!-- User Details Section -->
        <div class="mb-8 bg-blue-50 p-6 rounded-lg border border-blue-200">
            <h3 class="text-xl font-semibold text-gray-800 mb-4">Your Profile</h3>
            <div id="userDetails" class="text-gray-700"></div>
        </div>

        <!-- Quick Actions Section -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <a href="<%= request.getContextPath() %>/jsp/studentPages/bookingForm.jsp" class="bg-green-500 text-white p-6 rounded-lg shadow-md hover:bg-green-600 transition duration-200 flex items-center space-x-4">
                <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path></svg>
                <div>
                    <h4 class="text-lg font-semibold">Book a Lesson</h4>
                    <p class="text-sm">Schedule a new driving lesson with an instructor.</p>
                </div>
            </a>
            <a href="<%= request.getContextPath() %>/lesson?action=list" class="bg-blue-500 text-white p-6 rounded-lg shadow-md hover:bg-blue-600 transition duration-200 flex items-center space-x-4">
                <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
                <div>
                    <h4 class="text-lg font-semibold">View Lessons</h4>
                    <p class="text-sm">Check your scheduled driving lessons.</p>
                </div>
            </a>
            <a href="<%= request.getContextPath() %>/user?action=edit&id=<%= ((User) session.getAttribute("loggedInUser")).getId() %>" class="bg-gray-500 text-white p-6 rounded-lg shadow-md hover:bg-gray-600 transition duration-200 flex items-center space-x-4">
                <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path></svg>
                <div>
                    <h4 class="text-lg font-semibold">View/Edit Profile</h4>
                    <p class="text-sm">Update your personal details.</p>
                </div>
            </a>
        </div>
    </div>
</div>

<script>
    // Save user ID to localStorage on page load
    const userId = '<%= ((User) session.getAttribute("loggedInUser")).getId() %>';
    localStorage.setItem('userId', userId);
    console.log('Stored userId in localStorage:', userId);

    // Fetch user details from server
    function fetchUserDetails() {
        const storedUserId = localStorage.getItem('userId');
        if (!storedUserId) {
            document.getElementById('userDetails').innerHTML = 'User ID not found in local storage.';
            console.error('No userId found in localStorage');
            return;
        }

        console.log('Fetching user details for userId:', storedUserId);
        fetch('<%= request.getContextPath() %>/user?action=getById&id=' + encodeURIComponent(storedUserId))
            .then(response => {
                console.log('Fetch response status:', response.status);
                if (!response.ok) {
                    throw new Error('User not found: ' + response.status);
                }
                return response.json();
            })
            .then(user => {
                console.log('Raw user data from fetch:', user);
                const userDetailsDiv = document.getElementById('userDetails');
                if (!userDetailsDiv) {
                    console.error('userDetails div not found in DOM');
                    return;
                }

                // Handle null, undefined, or empty strings
                const email = user.email && user.email.trim() !== '' ? user.email : 'Not available';
                const phone = user.phone && user.phone.trim() !== '' ? user.phone : 'Not available';
                const role = user.role && user.role.trim() !== '' ? user.role : 'Not available';
                const certification = user.certification && user.certification.trim() !== '' ? user.certification : null;

                console.log('Processed user data:', { email, phone, role, certification });

                // Build HTML with string concatenation
                let html = '';
                html += '<p><strong>Email:</strong> ' + email + '</p>';
                html += '<p><strong>Phone:</strong> ' + phone + '</p>';
                html += '<p><strong>Role:</strong> ' + role + '</p>';
                if (certification) {
                    html += '<p><strong>Certification:</strong> ' + certification + '</p>';
                }

                console.log('Generated HTML:', html);

                userDetailsDiv.innerHTML = html;
                console.log('Updated userDetails div with:', userDetailsDiv.innerHTML);
            })
            .catch(error => {
                console.error('Error fetching user details:', error);
                const userDetailsDiv = document.getElementById('userDetails');
                if (userDetailsDiv) {
                    userDetailsDiv.innerHTML = 'Error fetching user details: ' + error.message;
                }
            });
    }

    // Use DOMContentLoaded to ensure DOM is ready
    document.addEventListener('DOMContentLoaded', fetchUserDetails);
</script>
</body>
</html>