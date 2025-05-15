<%@ page contentType="text/html;charset=UTF-8" language="java" %>
  <%@ page import="com.Model.User" %>
  <html>
  <head>
      <title>Login - Driving School</title>
      <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
      <link href="css/styles.css" rel="stylesheet">
  </head>
  <body>
  <div class="container">
      <div class="card">
          <h2 class="text-2xl font-bold mb-4">Login</h2>
          <% if (request.getAttribute("error") != null) { %>
              <p class="text-red-500 mb-4"><%= request.getAttribute("error") %></p>
          <% } %>
          <% if ("registered".equals(request.getParameter("success"))) { %>
              <p class="text-green-500 mb-4">Registration successful! Please log in.</p>
          <% } %>
          <form action="login" method="post">
              <div class="mb-4">
                  <label class="block text-sm font-medium">Email</label>
                  <input type="email" name="email" required class="w-full p-2 border rounded-md">
              </div>
              <div class="mb-4">
                  <label class="block text-sm font-medium">Password</label>
                  <input type="password" name="password" required class="w-full p-2 border rounded-md">
              </div>
              <div class="flex space-x-4">
                  <button type="submit" class="btn btn-primary">Login</button>
                  <a href="user" class="btn btn-secondary">Register</a>
              </div>
          </form>
          <div class="mt-4 text-center">
              <p class="text-sm text-gray-600">Don't have an account?</p>
              <a href="user" class="text-blue-500 hover:underline">Create a student account</a>
              <br>
              <a href="instructor?action=register" class="text-blue-500 hover:underline">Create an instructor account</a>
          </div>
      </div>
  </div>
  <script>
      // Check if user is logged in (set by LoginServlet after redirect back to login.jsp with success)
      <% User loggedInUser = (User) session.getAttribute("loggedInUser"); %>
      <% if (loggedInUser != null) { %>
          localStorage.setItem('userId', '<%= loggedInUser.getId() %>');
      <% } %>
  </script>
  </body>
  </html>