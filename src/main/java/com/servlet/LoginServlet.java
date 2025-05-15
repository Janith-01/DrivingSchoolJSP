package com.servlet;

import com.Model.User;
import com.Model.Instructor;
import com.Util.FileHandler;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/jsp/common/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String rootPath = getServletContext().getRealPath("/");

        // Check users.txt
        List<User> users = FileHandler.readUsers(rootPath);
        for (User user : users) {
            if (user.getEmail().equals(email) && user.getPassword().equals(password)) {
                req.getSession().setAttribute("loggedInUser", user);
                switch (user.getRole()) {
                    case "Admin":
                        resp.sendRedirect(req.getContextPath() + "/jsp/adminpages/adminHome.jsp");
                        return;
                    case "Student":
                        resp.sendRedirect(req.getContextPath() + "/jsp/studentPages/studentHome.jsp");
                        return;
                    case "Instructor":
                        resp.sendRedirect(req.getContextPath() + "/jsp/instructorPages/instructorHome.jsp");
                        return;
                    default:
                        req.setAttribute("error", "Invalid role.");
                        req.getRequestDispatcher("/jsp/common/login.jsp").forward(req, resp);
                        return;
                }
            }
        }

        // Check instructors.txt
        List<Instructor> instructors = FileHandler.readInstructors(rootPath);
        for (Instructor instructor : instructors) {
            if (instructor.getEmail().equals(email) && instructor.getPassword().equals(password)) {
                req.getSession().setAttribute("loggedInUser", instructor);
                resp.sendRedirect(req.getContextPath() + "/jsp/instructorPages/instructorHome.jsp");
                return;
            }
        }

        req.setAttribute("error", "Invalid email or password.");
        req.getRequestDispatcher("/jsp/common/login.jsp").forward(req, resp);
    }
}