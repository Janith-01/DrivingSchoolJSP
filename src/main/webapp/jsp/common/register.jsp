<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Register - Driving School</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="css/styles.css" rel="stylesheet">
</head>
<body>
<div class="container">
    <div class="card">
        <h2 class="text-2xl font-bold mb-4">Register</h2>
        <form action="user" method="post">
            <input type="hidden" name="action" value="register">
            <div class="mb-4">
                <label class="block text-sm font-medium">Role</label>
                <select name="role" class="w-full p-2 border rounded-md">
                    <option value="Student">Student</option>
                    <option value="Instructor">Instructor</option>
                </select>
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium">Name</label>
                <input type="text" name="name" required class="w-full p-2 border rounded-md">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium">Email</label>
                <input type="email" name="email" required class="w-full p-2 border rounded-md">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium">Password</label>
                <input type="password" name="password" required class="w-full p-2 border rounded-md">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium">Phone</label>
                <input type="text" name="phone" required class="w-full p-2 border rounded-md">
            </div>
            <div class="mb-4 hidden instructor-field">
                <label class="block text-sm font-medium">Certification</label>
                <input type="text" name="certification" class="w-full p-2 border rounded-md">
            </div>
            <button type="submit" class="btn btn-primary">Register</button>
        </form>
    </div>
</div>
<script>
    document.querySelector('select[name="role"]').addEventListener('change', function () {
        document.querySelector('.instructor-field').classList.toggle('hidden', this.value !== 'Instructor');
    });
</script>
</body>
</html>