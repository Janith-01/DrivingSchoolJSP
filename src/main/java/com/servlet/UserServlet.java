package com.servlet;

import com.Model.Student;
import com.Model.User;
import com.Util.FileHandler;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.UUID;

@WebServlet("/user")
public class UserServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String rootPath = getServletContext().getRealPath("/");
        List<User> users = FileHandler.readUsers(rootPath); // Only students

        if ("list".equals(action)) {
            req.setAttribute("users", users);
            req.getRequestDispatcher("/jsp/adminpages/userList.jsp").forward(req, resp);
        } else if ("edit".equals(action)) {
            String id = req.getParameter("id");
            User user = users.stream().filter(u -> u.getId().equals(id)).findFirst().orElse(null);
            req.setAttribute("user", user);
            req.getRequestDispatcher("/jsp/common/profile.jsp").forward(req, resp);
        } else if ("getById".equals(action)) {
            String id = req.getParameter("id");
            User user = users.stream().filter(u -> u.getId().equals(id)).findFirst().orElse(null);
            resp.setContentType("application/json");
            PrintWriter out = resp.getWriter();
            if (user != null) {
                String email = user.getEmail() != null ? user.getEmail() : "";
                String phone = user.getPhone() != null ? user.getPhone() : "";
                String role = user.getRole() != null ? user.getRole() : "";
                String json = String.format("{\"id\":\"%s\",\"name\":\"%s\",\"email\":\"%s\",\"role\":\"%s\",\"phone\":\"%s\"}",
                        user.getId(), user.getName() != null ? user.getName() : "",
                        email, role, phone);
                out.print(json);
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\":\"User not found\"}");
            }
            out.flush();
        } else {
            req.getRequestDispatcher("/jsp/common/register.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String rootPath = getServletContext().getRealPath("/");
        List<User> users = FileHandler.readUsers(rootPath); // Only students

        if ("register".equals(action)) {
            String id = UUID.randomUUID().toString();
            String name = req.getParameter("name");
            String email = req.getParameter("email");
            String password = req.getParameter("password");
            String phone = req.getParameter("phone");

            // Basic validation
            if (name == null || email == null || password == null || phone == null ||
                    name.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty() || phone.trim().isEmpty()) {
                req.setAttribute("error", "All fields are required.");
                req.getRequestDispatcher("/jsp/common/register.jsp").forward(req, resp);
                return;
            }

            User user = new Student(id, name, email, password, phone);
            users.add(user);
            FileHandler.writeUsers(users, rootPath);
            // Redirect to login with success message
            resp.sendRedirect("login?success=registered");
        } else if ("update".equals(action)) {
            String id = req.getParameter("id");
            String name = req.getParameter("name");
            String email = req.getParameter("email");
            String password = req.getParameter("password");
            String phone = req.getParameter("phone");

            users.removeIf(u -> u.getId().equals(id));
            User user = new Student(id, name, email, password, phone);
            users.add(user);
            FileHandler.writeUsers(users, rootPath);
            resp.sendRedirect("user?action=list");
        } else if ("delete".equals(action)) {
            String id = req.getParameter("id");
            users.removeIf(u -> u.getId().equals(id));
            FileHandler.writeUsers(users, rootPath);
            resp.sendRedirect("user?action=list");
        }
    }
}