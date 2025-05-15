<%@ page contentType="text/html;charset=UTF-8" language="java" %>
  <html>
  <head>
      <title>Register Student - Driving School</title>
      <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
      <link href="css/styles.css" rel="stylesheet">
  </head>
  <body>
  <div class="container">
      <div class="card">
          <h2 class="text-2xl font-bold mb-4">Register as Student</h2>
          <% if (request.getAttribute("error") != null) { %>
              <p class="text-red-500 mb-4"><%= request.getAttribute("error") %></p>
          <% } %>
          <form action="user" method="post">
              <input type="hidden" name="action" value="register">
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
              <div class="flex space-x-4">
                  <button type="submit" class="btn btn-primary">Register</button>
                  <a href="login" class="btn btn-secondary">Back to Login</a>
              </div>
          </form>
          <div class="mt-4 text-center">
              <p class="text-sm text-gray-600">Want to register as an instructor?</p>
              <a href="instructor?action=register" class="text-blue-500 hover:underline">Register as Instructor</a>
          </div>
      </div>
  </div>
  </body>
  </html>