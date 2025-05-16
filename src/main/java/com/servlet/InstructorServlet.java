package com.servlet;

import com.Model.Instructor;
import com.Model.PartTimeInstructor;
import com.Model.FullTimeInstructor;
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
import java.util.regex.Pattern;

@WebServlet("/instructor")
public class InstructorServlet extends HttpServlet {
    private static final String EMAIL_REGEX = "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String rootPath = getServletContext().getRealPath("/");
        List<Instructor> instructors = FileHandler.readInstructors(rootPath);
        User loggedInUser = (User) req.getSession().getAttribute("loggedInUser");

        if ("studentList".equals(action)) {
            if (loggedInUser == null || !(loggedInUser instanceof Student)) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            instructors = FileHandler.sortInstructorsByExperience(instructors);
            req.setAttribute("instructors", instructors);
            req.getRequestDispatcher("/jsp/studentPages/instructorList.jsp").forward(req, resp);
        } else if ("list".equals(action)) {
            if (loggedInUser == null || !"Admin".equals(loggedInUser.getRole())) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            instructors = FileHandler.sortInstructorsByExperience(instructors);
            req.setAttribute("instructors", instructors);
            req.getRequestDispatcher("/jsp/adminpages/instructorList.jsp").forward(req, resp);
        } else if ("profile".equals(action)) {
            String id = req.getParameter("id");
            Instructor instructor = instructors.stream().filter(i -> i.getId().equals(id)).findFirst().orElse(null);
            req.setAttribute("instructor", instructor);
            req.getRequestDispatcher("/jsp/instructorPages/instructorProfile.jsp").forward(req, resp);
        } else if ("updateAvailability".equals(action)) {
            String id = req.getParameter("id");
            Instructor instructor = instructors.stream().filter(i -> i.getId().equals(id)).findFirst().orElse(null);
            req.setAttribute("instructor", instructor);
            req.getRequestDispatcher("/jsp/instructorPages/instructorAvailability.jsp").forward(req, resp);
        } else if ("search".equals(action)) {
            String searchTerm = req.getParameter("searchTerm");
            if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                instructors = instructors.stream()
                        .filter(i -> i.getName().toLowerCase().contains(searchTerm.toLowerCase()))
                        .toList();
            }
            req.setAttribute("instructors", instructors);
            if (loggedInUser != null && loggedInUser instanceof Student) {
                req.getRequestDispatcher("/jsp/studentPages/instructorList.jsp").forward(req, resp);
            } else {
                if (loggedInUser == null || !"Admin".equals(loggedInUser.getRole())) {
                    resp.sendRedirect(req.getContextPath() + "/login");
                    return;
                }
                req.getRequestDispatcher("/jsp/adminpages/instructorList.jsp").forward(req, resp);
            }
        } else if ("getById".equals(action)) {
            String id = req.getParameter("id");
            Instructor instructor = instructors.stream().filter(i -> i.getId().equals(id)).findFirst().orElse(null);
            resp.setContentType("application/json");
            PrintWriter out = resp.getWriter();
            if (instructor != null) {
                String email = instructor.getEmail() != null ? instructor.getEmail() : "";
                String phone = instructor.getPhone() != null ? instructor.getPhone() : "";
                String role = instructor.getRole() != null ? instructor.getRole() : "";
                String certifications = instructor.getCertification() != null ? instructor.getCertification() : "";
                String availability = instructor.getAvailability() != null ? instructor.getAvailability() : "";
                int experience = instructor.getExperience();
                String type = instructor instanceof PartTimeInstructor ? "PartTime" : "FullTime";

                String json = String.format(
                        "{\"id\":\"%s\",\"name\":\"%s\",\"email\":\"%s\",\"role\":\"%s\",\"phone\":\"%s\",\"certifications\":\"%s\",\"availability\":\"%s\",\"experience\":%d,\"type\":\"%s\"}",
                        instructor.getId(), instructor.getName() != null ? instructor.getName() : "",
                        email, role, phone, certifications, availability, experience, type);
                out.print(json);
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\":\"Instructor not found\"}");
            }
            out.flush();
        } else {
            req.getRequestDispatcher("/jsp/adminpages/instructorRegister.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String rootPath = getServletContext().getRealPath("/");
        List<Instructor> instructors = FileHandler.readInstructors(rootPath);

        if ("register".equals(action)) {
            String id = UUID.randomUUID().toString();
            String name = req.getParameter("name");
            String email = req.getParameter("email");
            String password = req.getParameter("password");
            String experienceStr = req.getParameter("experience");
            String availability = req.getParameter("availability");
            String certifications = req.getParameter("certifications");
            String type = req.getParameter("type");

            // Basic validation
            if (name == null || email == null || password == null || experienceStr == null ||
                    availability == null || certifications == null || type == null ||
                    name.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty() ||
                    certifications.trim().isEmpty()) {
                req.setAttribute("error", "All fields are required.");
                req.getRequestDispatcher("/jsp/adminpages/instructorRegister.jsp").forward(req, resp);
                return;
            }

            // Email structure validation
            if (!Pattern.matches(EMAIL_REGEX, email)) {
                req.setAttribute("error", "Invalid email format.");
                req.getRequestDispatcher("/jsp/adminpages/instructorRegister.jsp").forward(req, resp);
                return;
            }

            // Check if email already exists
            boolean emailExists = instructors.stream().anyMatch(i -> i.getEmail().equalsIgnoreCase(email));
            if (emailExists) {
                req.setAttribute("error", "Email already exists.");
                req.getRequestDispatcher("/jsp/adminpages/instructorRegister.jsp").forward(req, resp);
                return;
            }

            // Experience validation
            int experience;
            try {
                experience = Integer.parseInt(experienceStr);
                if (experience < 0) throw new NumberFormatException();
            } catch (NumberFormatException e) {
                req.setAttribute("error", "Invalid experience value.");
                req.getRequestDispatcher("/jsp/adminpages/instructorRegister.jsp").forward(req, resp);
                return;
            }

            Instructor instructor;
            if ("PartTime".equals(type)) {
                instructor = new PartTimeInstructor(id, name, email, password, "", experience, availability, certifications);
            } else {
                instructor = new FullTimeInstructor(id, name, email, password, "", experience, availability, certifications);
            }
            instructors.add(instructor);
            FileHandler.writeInstructors(instructors, rootPath);
            resp.sendRedirect("instructor?action=list");
        } else if ("update".equals(action)) {
            String id = req.getParameter("id");
            String name = req.getParameter("name");
            String email = req.getParameter("email");
            String password = req.getParameter("password");
            int experience = Integer.parseInt(req.getParameter("experience"));
            String certifications = req.getParameter("certifications");
            String type = req.getParameter("type");

            // Email structure validation
            if (!Pattern.matches(EMAIL_REGEX, email)) {
                req.setAttribute("error", "Invalid email format.");
                req.getRequestDispatcher("/jsp/instructorPages/instructorHome.jsp").forward(req, resp);
                return;
            }

            instructors.removeIf(i -> i.getId().equals(id));
            Instructor instructor;
            if ("PartTime".equals(type)) {
                instructor = new PartTimeInstructor(id, name, email, password, "", experience, "Available", certifications);
            } else {
                instructor = new FullTimeInstructor(id, name, email, password, "", experience, "Available", certifications);
            }
            instructors.add(instructor);
            FileHandler.writeInstructors(instructors, rootPath);
            resp.sendRedirect("/DrivingSchoolSystem/jsp/instructorPages/instructorHome.jsp");
        } else if ("updateAvailability".equals(action)) {
            String id = req.getParameter("id");
            String availability = req.getParameter("availability");

            for (Instructor instructor : instructors) {
                if (instructor.getId().equals(id)) {
                    instructor.setAvailability(availability);
                    break;
                }
            }
            FileHandler.writeInstructors(instructors, rootPath);
            resp.sendRedirect("/DrivingSchoolSystem/jsp/instructorPages/instructorHome.jsp");
        } else if ("delete".equals(action)) {
            String id = req.getParameter("id");
            System.out.println("Delete action called for instructor ID: " + id);
            int initialSize = instructors.size();
            boolean removed = instructors.removeIf(i -> i.getId().equals(id));
            System.out.println("Instructor removed: " + removed + ", Initial size: " + initialSize + ", New size: " + instructors.size());
            try {
                FileHandler.writeInstructors(instructors, rootPath);
                System.out.println("Instructors written to file successfully");
                req.setAttribute("success", "Instructor deleted successfully.");
            } catch (IOException e) {
                System.err.println("Failed to write instructors: " + e.getMessage());
                req.setAttribute("error", "Failed to delete instructor due to file error.");
                req.getRequestDispatcher("/jsp/adminpages/instructorList.jsp").forward(req, resp);
                return;
            }
            resp.sendRedirect("instructor?action=list");
        }
    }
}