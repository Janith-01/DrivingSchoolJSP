<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.User" %>
<html>
<head>
    <title>Admin Home - Driving School</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="../css/styles.css" rel="stylesheet">
</head>
<body class="bg-gray-100">
<div class="container mx-auto p-4">
    <div class="bg-white shadow-md rounded-lg p-6 max-w-2xl mx-auto">
        <h2 class="text-3xl font-bold mb-4">Welcome, <%= ((User) session.getAttribute("loggedInUser")).getName() %>!</h2>
        <p class="text-lg mb-4">You are logged in as an <span class="font-semibold">Admin</span>.</p>
        <div id="userDetails" class="mb-4 text-gray-700" style="display: block; min-height: 100px; border: 1px solid blue;"></div>
        <div class="space-y-4">
            <a href="<%= request.getContextPath() %>/user?action=list" class="block bg-blue-500 text-white p-2 rounded-md text-center hover:bg-blue-600">Manage Users</a>
            <a href="<%= request.getContextPath() %>/lesson?action=list" class="block bg-green-500 text-white p-2 rounded-md text-center hover:bg-green-600">Manage Lessons</a>
            <a href="#" class="block bg-gray-500 text-white p-2 rounded-md text-center hover:bg-gray-600 opacity-50 cursor-not-allowed">System Settings (Coming Soon)</a>
        </div>
        <a href="<%= request.getContextPath() %>/logout" class="mt-6 inline-block text-red-500 hover:underline">Logout</a>
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