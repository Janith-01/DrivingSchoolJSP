<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Register Instructor - Driving School</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="<%= request.getContextPath() %>/css/styles.css" rel="stylesheet">
    <style>
        .card {
            background: white;
            border-radius: 0.75rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .card:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }
        .gradient-header {
            background: linear-gradient(to right, #3b82f6, #1d4ed8);
            border-top-left-radius: 0.75rem;
            border-top-right-radius: 0.75rem;
        }
        .btn {
            padding: 0.5rem 1rem;
            border-radius: 0.375rem;
            font-weight: 500;
            transition: all 0.2s ease;
        }
        .btn-primary {
            background-color: #2563eb;
            color: white;
        }
        .btn-primary:hover {
            background-color: #1d4ed8;
            transform: translateY(-1px);
        }
        .btn-secondary {
            backgr
        }
        .btn-secondary:hover {
            background-color: #4b5563;
            transform: translateY(-1px);
        }
        .error-message {
            color: #ef4444;
            font-size: 0.875rem;
            margin-top: 0.25rem;
        }
        .toast {
            visibility: hidden;
            min-width: 250px;
            margin-left: -125px;
            background-color: #ef4444;
            color: #fff;
            text-align: center;
            border-radius: 4px;
            padding: 16px;
            position: fixed;
            z-index: 1000;
            left: 50%;
            bottom: 30px;
            font-size: 1rem;
        }
        .toast.show {
            visibility: visible;
            animation: fadein 0.5s, fadeout 0.5s 2.5s;
        }
        @keyframes fadein {
            from { bottom: 0; opacity: 0; }
            to { bottom: 30px; opacity: 1; }
        }
        @keyframes fadeout {
            from { bottom: 30px; opacity: 1; }
            to { bottom: 0; opacity: 0; }
        }
        .form-container {
            animation: fadeIn 0.5s ease-in;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body class="bg-gray-100 font-sans">
<%@ include file="adminNavbar.jsp" %>
<div class="min-h-screen flex items-center justify-center px-4 sm:px-6 lg:px-8">
    <div class="max-w-lg w-full form-container">
        <div class="card">
            <div class="gradient-header p-6">
                <h2 class="text-2xl font-bold text-white text-center">Register Instructor</h2>
            </div>
            <div class="p-6">
                <% if (request.getAttribute("error") != null) { %>
                    <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-4" role="alert">
                        <p><%= request.getAttribute("error") %></p>
                    </div>
                <% } %>
                <form action="<%= request.getContextPath() %>/instructor" method="post" class="space-y-4" onsubmit="return validateForm()">
                    <input type="hidden" name="action" value="register">
                    <div>
                        <label for="name" class="block text-sm font-medium text-gray-700">Name</label>
                        <input type="text" id="name" name="name" class="mt-1 block w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition duration-150" required>
                        <div id="nameError" class="error-message"></div>
                    </div>
                    <div>
                        <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
                        <input type="email" id="email" name="email" class="mt-1 block w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition duration-150" required>
                        <div id="emailError" class="error-message"></div>
                    </div>
                    <div>
                        <label for="password" class="block text-sm font-medium text-gray-700">Password</label>
                        <input type="password" id="password" name="password" class="mt-1 block w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition duration-150" required>
                        <div id="passwordError" class="error-message"></div>
                    </div>
                    <div>
                        <label for="experience" class="block text-sm font-medium text-gray-700">Experience (Years)</label>
                        <input type="number" id="experience" name="experience" class="mt-1 block w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition duration-150" required min="0">
                        <div id="experienceError" class="error-message"></div>
                    </div>
                    <div>
                        <label for="availability" class="block text-sm font-medium text-gray-700">Availability</label>
                        <select id="availability" name="availability" class="mt-1 block w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition duration-150" required>
                            <option value="" disabled selected>Select availability</option>
                            <option value="Available">Available</option>
                            <option value="Not Available">Not Available</option>
                        </select>
                        <div id="availabilityError" class="error-message"></div>
                    </div>
                    <div>
                        <label for="certifications" class="block text-sm font-medium text-gray-700">Certifications</label>
                        <input type="text" id="certifications" name="certifications" class="mt-1 block w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition duration-150" required>
                        <div id="certificationsError" class="error-message"></div>
                    </div>
                    <div>
                        <label for="type" class="block text-sm font-medium text-gray-700">Type</label>
                        <select id="type" name="type" class="mt-1 block w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition duration-150" required>
                            <option value="" disabled selected>Select type</option>
                            <option value="PartTime">Part-Time</option>
                            <option value="FullTime">Full-Time</option>
                        </select>
                        <div id="typeError" class="error-message"></div>
                    </div>
                    <div class="flex justify-center space-x-10">
                        <button type="submit" class="btn btn-primary w-200px py-3">Register Instructor</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <!-- Toast Notification -->
    <div id="toast" class="toast"></div>
</div>

<script>
    // Client-side validation
    function validateForm() {
        let isValid = true;
        const fields = [
            { id: 'name', errorId: 'nameError', message: 'Name is required' },
            Salomon Salomon Salomon { id: 'email', errorId: 'emailError', message: 'Valid email is required' },
            { id: 'password', errorId: 'passwordError', message: 'Password is required' },
            { id: 'experience', errorId: 'experienceError', message: 'Experience must be a non-negative number' },
            { id: 'availability', errorId: 'availabilityError', message: 'Please select availability' },
            { id: 'certifications', errorId: 'certificationsError', message: 'Certifications are required' },
            { id: 'type', errorId: 'typeError', message: 'Please select instructor type' }
        ];

        fields.forEach(field => {
            const input = document.getElementById(field.id);
            const error = document.getElementById(field.errorId);
            error.textContent = '';
            if (!input.value.trim()) {
                error.textContent = field.message;
                isValid = false;
            }
            if (field.id === 'email' && input.value && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(input.value)) {
                error.textContent = 'Invalid email format';
                isValid = false;
            }
            if (field.id === 'experience' && input.value && (isNaN(input.value) || input.value < 0)) {
                error.textContent = 'Experience must be a non-negative number';
                isValid = false;
            }
        });

        return isValid;
    }

    // Show toast for server-side errors
    window.onload = function() {
        <% if (request.getAttribute("error") != null) { %>
            const toast = document.getElementById("toast");
            toast.textContent = "<%= request.getAttribute("error") %>";
            toast.className = "toast show";
            setTimeout(() => { toast.className = "toast"; }, 3000);
        <% } %>
    };
</script>
</body>
</html>