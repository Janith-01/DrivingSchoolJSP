package com.servlet;

import com.Model.Instructor;
import com.Model.PartTimeInstructor;
import com.Model.FullTimeInstructor;
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

@WebServlet("/instructor")
public class InstructorServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String rootPath = getServletContext().getRealPath("/");
        List<Instructor> instructors = FileHandler.readInstructors(rootPath);

        if ("list".equals(action)) {
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
            req.getRequestDispatcher("/jsp/adminpages/instructorList.jsp").forward(req, resp);
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

            // Validation
            if (name == null || email == null || password == null || experienceStr == null ||
                    availability == null || certifications == null || type == null ||
                    name.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty() ||
                    certifications.trim().isEmpty()) {
                req.setAttribute("error", "All fields are required.");
                req.getRequestDispatcher("/jsp/adminpages/instructorRegister.jsp").forward(req, resp);
                return;
            }
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

            instructors.removeIf(i -> i.getId().equals(id));
            Instructor instructor;
            if ("PartTime".equals(type)) {
                instructor = new PartTimeInstructor(id, name, email, password, "", experience, "Available", certifications);
            } else {
                instructor = new FullTimeInstructor(id, name, email, password, "", experience, "Available", certifications);
            }
            instructors.add(instructor);
            FileHandler.writeInstructors(instructors, rootPath);
            resp.sendRedirect("instructor?action=list");
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
            resp.sendRedirect("instructor?action=list");
        } else if ("delete".equals(action)) {
            String id = req.getParameter("id");
            instructors.removeIf(i -> i.getId().equals(id));
            FileHandler.writeInstructors(instructors, rootPath);
            resp.sendRedirect("instructor?action=list");
        }
    }
}