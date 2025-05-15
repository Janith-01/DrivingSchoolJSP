<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Register Instructor - Driving School</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="css/styles.css" rel="stylesheet">
</head>
<body>
<%@ include file="adminNavbar.jsp" %>
<div class="container">
    <div class="card">
        <h2 class="text-2xl font-bold mb-4">Register as Instructor</h2>
        <form action="instructor" method="post">
            <input type="hidden" name="action" value="register">
            <div class="mb-4">
                <label class="block text-sm font-medium">Name</label>
                <input type="text" name="name" class="w-full p-2 border rounded-md" required>
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium">Email</label>
                <input type="email" name="email" class="w-full p-2 border rounded-md" required>
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium">Password</label>
                <input type="password" name="password" class="w-full p-2 border rounded-md" required>
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium">Experience (Years)</label>
                <input type="number" name="experience" class="w-full p-2 border rounded-md" required min="0">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium">Availability</label>
                <select name="availability" class="w-full p-2 border rounded-md" required>
                    <option value="Available">Available</option>
                    <option value="Not Available">Not Available</option>
                </select>
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium">Certifications</label>
                <input type="text" name="certifications" class="w-full p-2 border rounded-md" required>
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium">Type</label>
                <select name="type" class="w-full p-2 border rounded-md" required>
                    <option value="PartTime">Part-Time</option>
                    <option value="FullTime">Full-Time</option>
                </select>
            </div>
            <div class="flex space-x-4">
                <button type="submit" class="btn btn-primary">Register</button>
                <a href="login" class="btn btn-secondary">Back to Login</a>
            </div>
        </form>
        <div class="mt-4 text-center">
            <p class="text-sm text-gray-600">Want to register as a student?</p>
            <a href="user" class="text-blue-500 hover:underline">Register as Student</a>
        </div>
    </div>
</div>
</body>
</html>