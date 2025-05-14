package com.servlet;

import com.Model.User;
import com.Util.FileHandler;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Forward to login.jsp for GET requests
        req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String rootPath = getServletContext().getRealPath("/");
        List<User> users = FileHandler.readUsers(rootPath);

        User user = users.stream()
                .filter(u -> u.getEmail().equals(email) && u.getPassword().equals(password))
                .findFirst()
                .orElse(null);

        if (user != null) {
            req.getSession().setAttribute("loggedInUser", user);
            String role = user.getRole();
            switch (role) {
                case "Student":
                    resp.sendRedirect(req.getContextPath() + "/jsp/studentHome.jsp");
                    break;
                case "Instructor":
                    resp.sendRedirect(req.getContextPath() + "/jsp/instructorHome.jsp");
                    break;
                case "Admin":
                    resp.sendRedirect(req.getContextPath() + "/jsp/adminHome.jsp");
                    break;
                default:
                    req.setAttribute("error", "Unknown user role");
                    req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
            }
        } else {
            req.setAttribute("error", "Invalid login credentials");
            req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
        }
    }
}