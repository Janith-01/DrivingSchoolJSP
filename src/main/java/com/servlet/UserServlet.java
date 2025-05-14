package com.servlet;

import com.Model.User;
import com.Model.Student;
import com.Model.Instructor;
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
        List<User> users = FileHandler.readUsers(rootPath);

        if ("list".equals(action)) {
            req.setAttribute("users", users);
            req.getRequestDispatcher("/jsp/userList.jsp").forward(req, resp);
        } else if ("edit".equals(action)) {
            String id = req.getParameter("id");
            User user = users.stream().filter(u -> u.getId().equals(id)).findFirst().orElse(null);
            req.setAttribute("user", user);
            req.getRequestDispatcher("/jsp/profile.jsp").forward(req, resp);
        } else if ("getById".equals(action)) {
            String id = req.getParameter("id");
            User user = users.stream().filter(u -> u.getId().equals(id)).findFirst().orElse(null);
            resp.setContentType("application/json");
            PrintWriter out = resp.getWriter();
            if (user != null) {
                // Sanitize fields to avoid null values
                String email = user.getEmail() != null ? user.getEmail() : "";
                String phone = user.getPhone() != null ? user.getPhone() : "";
                String role = user.getRole() != null ? user.getRole() : "";
                String certification = user instanceof Instructor ? ((Instructor) user).getCertification() : null;

                String json = String.format("{\"id\":\"%s\",\"name\":\"%s\",\"email\":\"%s\",\"role\":\"%s\",\"phone\":\"%s\"%s}",
                        user.getId(), user.getName() != null ? user.getName() : "",
                        email, role, phone,
                        certification != null ? ",\"certification\":\"" + certification + "\"" : "");
                out.print(json);
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\":\"User not found\"}");
            }
            out.flush();
        } else {
            req.getRequestDispatcher("/jsp/register.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String rootPath = getServletContext().getRealPath("/");
        List<User> users = FileHandler.readUsers(rootPath);

        if ("register".equals(action)) {
            String id = UUID.randomUUID().toString();
            String role = req.getParameter("role");
            String name = req.getParameter("name");
            String email = req.getParameter("email");
            String password = req.getParameter("password");
            String phone = req.getParameter("phone");
            String certification = req.getParameter("certification");

            User user;
            if ("Student".equals(role)) {
                user = new Student(id, name, email, password, phone);
            } else {
                user = new Instructor(id, name, email, password, phone, certification);
            }
            users.add(user);
            FileHandler.writeUsers(users, rootPath);
            resp.sendRedirect("user?action=list");
        } else if ("update".equals(action)) {
            String id = req.getParameter("id");
            String name = req.getParameter("name");
            String email = req.getParameter("email");
            String password = req.getParameter("password");
            String phone = req.getParameter("phone");
            String certification = req.getParameter("certification");

            users.removeIf(u -> u.getId().equals(id));
            User user;
            if (certification != null && !certification.isEmpty()) {
                user = new Instructor(id, name, email, password, phone, certification);
            } else {
                user = new Student(id, name, email, password, phone);
            }
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