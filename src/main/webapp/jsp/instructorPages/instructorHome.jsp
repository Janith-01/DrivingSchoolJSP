<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Model.User" %>
<html>
<head>
    <title>Instructor Dashboard - Driving School</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="../css/styles.css" rel="stylesheet">
</head>
<body class="bg-gray-100">
<!-- Include Navigation Bar -->
<%@ include file="instructorNavbar.jsp" %>

<div class="container mx-auto p-6">
    <div class="bg-white shadow-lg rounded-lg p-8 max-w-4xl mx-auto">
        <h2 class="text-4xl font-bold text-gray-800 mb-6">Welcome, <%= ((User) session.getAttribute("loggedInUser")).getName() %>!</h2>
        <p class="text-lg text-gray-600 mb-8">You are logged in as an <span class="font-semibold text-green-600">Instructor</span>. Manage your schedule and profile efficiently from this dashboard.</p>

        <!-- Instructor Details Section -->
        <div class="mb-8 bg-green-50 p-6 rounded-lg border border-green-200">
            <h3 class="text-xl font-semibold text-gray-800 mb-4">Your Profile</h3>
            <div id="userDetails" class="text-gray-700"></div>
        </div>

        <!-- Quick Actions Section -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <a href="<%= request.getContextPath() %>/scheduleLesson?action=calendar" class="bg-blue-500 text-white p-6 rounded-lg shadow-md hover:bg-blue-600 transition duration-200 flex items-center space-x-4">
                <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
                <div>
                    <h4 class="text-lg font-semibold">View Schedule</h4>
                    <p class="text-sm">Check your upcoming lessons and availability.</p>
                </div>
            </a>
            <a href="<%= request.getContextPath() %>/instructor?action=updateAvailability&id=<%= ((User) session.getAttribute("loggedInUser")).getId() %>" class="bg-green-500 text-white p-6 rounded-lg shadow-md hover:bg-green-600 transition duration-200 flex items-center space-x-4">
                <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                <div>
                    <h4 class="text-lg font-semibold">Update Availability</h4>
                    <p class="text-sm">Set your availability status.</p>
                </div>
            </a>
            <a href="<%= request.getContextPath() %>/instructor?action=profile&id=<%= ((User) session.getAttribute("loggedInUser")).getId() %>" class="bg-gray-500 text-white p-6 rounded-lg shadow-md hover:bg-gray-600 transition duration-200 flex items-center space-x-4">
                <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path></svg>
                <div>
                    <h4 class="text-lg font-semibold">View/Edit Profile</h4>
                    <p class="text-sm">Update your personal and professional details.</p>
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

    // Fetch instructor details from server
    function fetchUserDetails() {
        const storedUserId = localStorage.getItem('userId');
        if (!storedUserId) {
            document.getElementById('userDetails').innerHTML = 'User ID not found in local storage.';
            console.error('No userId found in localStorage');
            return;
        }

        console.log('Fetching instructor details for userId:', storedUserId);
        fetch('<%= request.getContextPath() %>/instructor?action=getById&id=' + encodeURIComponent(storedUserId))
            .then(response => {
                console.log('Fetch response status:', response.status);
                if (!response.ok) {
                    throw new Error('Instructor not found: ' + response.status);
                }
                return response.json();
            })
            .then(instructor => {
                console.log('Raw instructor data from fetch:', instructor);
                const userDetailsDiv = document.getElementById('userDetails');
                if (!userDetailsDiv) {
                    console.error('userDetails div not found in DOM');
                    return;
                }

                // Handle null, undefined, or empty strings
                const email = instructor.email && instructor.email.trim() !== '' ? instructor.email : 'Not available';
                const phone = instructor.phone && instructor.phone.trim() !== '' ? instructor.phone : 'Not available';
                const certifications = instructor.certifications && instructor.certifications.trim() !== '' ? instructor.certifications : 'Not available';
                const availability = instructor.availability && instructor.availability.trim() !== '' ? instructor.availability : 'Not available';
                const experience = instructor.experience != null ? instructor.experience : 'Not available';
                const type = instructor.type && instructor.type.trim() !== '' ? instructor.type : 'Not available';

                console.log('Processed instructor data:', { email, phone, certifications, availability, experience, type });

                // Build HTML with string concatenation
                let html = '';
                html += '<p><strong>Email:</strong> ' + email + '</p>';
                html += '<p><strong>Phone:</strong> ' + phone + '</p>';
                html += '<p><strong>Certifications:</strong> ' + certifications + '</p>';
                html += '<p><strong>Availability:</strong> ' + availability + '</p>';
                html += '<p><strong>Experience (Years):</strong> ' + experience + '</p>';
                html += '<p><strong>Type:</strong> ' + type + '</p>';

                console.log('Generated HTML:', html);

                userDetailsDiv.innerHTML = html;
                console.log('Updated userDetails div with:', userDetailsDiv.innerHTML);
            })
            .catch(error => {
                console.error('Error fetching instructor details:', error);
                const userDetailsDiv = document.getElementById('userDetails');
                if (userDetailsDiv) {
                    userDetailsDiv.innerHTML = 'Error fetching instructor details: ' + error.message;
                }
            });
    }

    // Use DOMContentLoaded to ensure DOM is ready
    document.addEventListener('DOMContentLoaded', fetchUserDetails);
</script>
</body>
</html>