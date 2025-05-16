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
        // Forward GET requests to login.jsp
        req.getRequestDispatcher("/jsp/common/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String rootPath = getServletContext().getRealPath("/");

        // Check instructors first
        List<Instructor> instructors = FileHandler.readInstructors(rootPath);
        for (Instructor instructor : instructors) {
            if (instructor.getEmail().equalsIgnoreCase(email) &&
                    instructor.getPassword().equals(password)) {
                req.getSession().setAttribute("loggedInUser", instructor);
                System.out.println("[LoginServlet] Logged in instructor: " + instructor.getName() + " (isInstructor: true)");
                resp.sendRedirect(req.getContextPath() + "/jsp/instructorPages/instructorHome.jsp");
                return;
            }
        }

        // Check regular users
        List<User> users = FileHandler.readUsers(rootPath);
        for (User user : users) {
            if (user.getEmail().equalsIgnoreCase(email) &&
                    user.getPassword().equals(password)) {
                req.getSession().setAttribute("loggedInUser", user);
                System.out.println("[LoginServlet] Logged in user: " + user.getName() + " (role: " + user.getRole() + ")");
                if ("Admin".equals(user.getRole())) {
                    resp.sendRedirect(req.getContextPath() + "/jsp/adminpages/adminHome.jsp");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/jsp/studentPages/studentHome.jsp");
                }
                return;
            }
        }

        req.setAttribute("error", "Invalid email or password.");
        req.getRequestDispatcher("/jsp/common/login.jsp").forward(req, resp);
    }
}
