package com.servlet;

import com.Model.*;
import com.Util.FileHandler;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet("/lesson")
public class LessonServlet extends HttpServlet {
    private Queue<Lesson> lessonQueue = new LinkedList<>();

    @Override
    public void init() throws ServletException {
        try {
            String rootPath = getServletContext().getRealPath("/");
            List<Lesson> lessons = FileHandler.readLessons(rootPath);
            lessonQueue = lessons.stream()
                    .filter(l -> "PENDING".equalsIgnoreCase(l.getStatus()))
                    .collect(Collectors.toCollection(LinkedList::new));
        } catch (IOException e) {
            System.err.println("Error initializing lesson queue: " + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        String rootPath = getServletContext().getRealPath("/");
        User user = (User) req.getSession().getAttribute("loggedInUser");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        switch (action) {
            case "instructorView":
                handleInstructorView(req, resp, rootPath, user);
                break;
            case "list":
                handleStudentView(req, resp, rootPath, user);
                break;
            case "edit":
                handleEditView(req, resp, rootPath, user);
                break;
            case "delete":
                handleDeleteLesson(req, resp, rootPath, user);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/login");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        String rootPath = getServletContext().getRealPath("/");
        User user = (User) req.getSession().getAttribute("loggedInUser");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        switch (action) {
            case "register":
                handleLessonRegistration(req, resp, rootPath, user);
                break;
            case "update":
                handleLessonUpdate(req, resp, rootPath, user);
                break;
            case "ACCEPTED":
            case "DENIED":
                handleStatusChange(req, resp, rootPath, action);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/login");
        }
    }

    private void handleInstructorView(HttpServletRequest req, HttpServletResponse resp,
                                      String rootPath, User user)
            throws ServletException, IOException {
        if (!(user instanceof Instructor)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Instructor instructor = (Instructor) user;
        List<Lesson> instructorLessons = lessonQueue.stream()
                .filter(l -> l.getInstructorName().equalsIgnoreCase(instructor.getName()))
                .collect(Collectors.toList());

        req.setAttribute("pendingLessons", instructorLessons);
        req.getRequestDispatcher("/jsp/instructorPages/instructorHome.jsp").forward(req, resp);
    }

    private void handleStudentView(HttpServletRequest req, HttpServletResponse resp,
                                   String rootPath, User user)
            throws ServletException, IOException {
        List<Lesson> allLessons = FileHandler.readLessons(rootPath);
        List<Lesson> studentLessons = allLessons.stream()
                .filter(l -> l.getStudentName().equalsIgnoreCase(user.getName()))
                .collect(Collectors.toList());

        req.setAttribute("lessons", studentLessons);
        req.getRequestDispatcher("/jsp/studentPages/lessonList.jsp").forward(req, resp);
    }

    private void handleEditView(HttpServletRequest req, HttpServletResponse resp,
                                String rootPath, User user)
            throws ServletException, IOException {
        String lessonId = req.getParameter("lessonId");
        List<Lesson> allLessons = FileHandler.readLessons(rootPath);

        Lesson lessonToEdit = allLessons.stream()
                .filter(l -> l.getLessonId().equals(lessonId))
                .findFirst()
                .orElse(null);

        if (lessonToEdit == null || !lessonToEdit.getStudentName().equals(user.getName())) {
            req.setAttribute("error", "Lesson not found or access denied");
            handleStudentView(req, resp, rootPath, user);
            return;
        }

        // Check if lesson can be edited (only PENDING status)
        if (!"PENDING".equalsIgnoreCase(lessonToEdit.getStatus())) {
            req.setAttribute("error", "Only pending lessons can be modified");
            handleStudentView(req, resp, rootPath, user);
            return;
        }

        // Get available instructors for the dropdown
        List<Instructor> instructors = FileHandler.readInstructors(rootPath).stream()
                .filter(i -> "Available".equalsIgnoreCase(i.getAvailability()))
                .collect(Collectors.toList());

        req.setAttribute("lesson", lessonToEdit);
        req.setAttribute("instructors", instructors);
        req.getRequestDispatcher("/jsp/studentPages/UpdateBookingInfo.jsp").forward(req, resp);
    }

    private void handleLessonRegistration(HttpServletRequest req, HttpServletResponse resp,
                                          String rootPath, User user)
            throws ServletException, IOException {
        String lessonId = UUID.randomUUID().toString();
        String studentName = user.getName();
        String instructorName = req.getParameter("instructorName");
        String date = req.getParameter("date");
        String time = req.getParameter("time");
        String type = req.getParameter("type");

        // Validate inputs
        if (instructorName == null || date == null || time == null || type == null) {
            req.setAttribute("error", "All fields are required");
            req.getRequestDispatcher("/jsp/studentPages/bookingForm.jsp").forward(req, resp);
            return;
        }

        Lesson lesson;
        if ("Beginner".equals(type)) {
            lesson = new BeginnerLesson(lessonId, studentName, instructorName, date, time, type, "PENDING");
        } else {
            lesson = new AdvancedLesson(lessonId, studentName, instructorName, date, time, type, "PENDING");
        }

        lessonQueue.add(lesson);
        List<Lesson> allLessons = FileHandler.readLessons(rootPath);
        allLessons.add(lesson);
        FileHandler.writeLessons(allLessons, rootPath);

        resp.sendRedirect(req.getContextPath() + "/jsp/studentPages/bookingForm.jsp?success=true");
    }

    private void handleLessonUpdate(HttpServletRequest req, HttpServletResponse resp,
                                    String rootPath, User user)
            throws ServletException, IOException {
        String lessonId = req.getParameter("lessonId");
        String instructorName = req.getParameter("instructorName");
        String date = req.getParameter("date");
        String time = req.getParameter("time");
        String type = req.getParameter("type");

        // Validate inputs
        if (lessonId == null || instructorName == null || date == null || time == null || type == null) {
            req.setAttribute("error", "All fields are required");
            handleEditView(req, resp, rootPath, user);
            return;
        }

        List<Lesson> allLessons = FileHandler.readLessons(rootPath);
        Lesson existingLesson = allLessons.stream()
                .filter(l -> l.getLessonId().equals(lessonId))
                .findFirst()
                .orElse(null);

        if (existingLesson == null || !existingLesson.getStudentName().equals(user.getName())) {
            req.setAttribute("error", "Lesson not found or access denied");
            handleStudentView(req, resp, rootPath, user);
            return;
        }

        // Check if lesson can be edited (only PENDING status)
        if (!"PENDING".equalsIgnoreCase(existingLesson.getStatus())) {
            req.setAttribute("error", "Only pending lessons can be modified");
            handleStudentView(req, resp, rootPath, user);
            return;
        }

        // Create updated lesson
        Lesson updatedLesson;
        if ("Beginner".equals(type)) {
            updatedLesson = new BeginnerLesson(lessonId, user.getName(), instructorName, date, time, type, existingLesson.getStatus());
        } else {
            updatedLesson = new AdvancedLesson(lessonId, user.getName(), instructorName, date, time, type, existingLesson.getStatus());
        }

        // Update in all collections
        allLessons.removeIf(l -> l.getLessonId().equals(lessonId));
        allLessons.add(updatedLesson);

        lessonQueue.removeIf(l -> l.getLessonId().equals(lessonId));
        if ("PENDING".equalsIgnoreCase(existingLesson.getStatus())) {
            lessonQueue.add(updatedLesson);
        }

        FileHandler.writeLessons(allLessons, rootPath);

        req.setAttribute("successMessage", "Lesson successfully updated");
        handleStudentView(req, resp, rootPath, user);
    }

    private void handleDeleteLesson(HttpServletRequest req, HttpServletResponse resp,
                                    String rootPath, User user)
            throws ServletException, IOException {
        String lessonId = req.getParameter("lessonId");
        List<Lesson> allLessons = FileHandler.readLessons(rootPath);

        Lesson lessonToDelete = allLessons.stream()
                .filter(l -> l.getLessonId().equals(lessonId))
                .findFirst()
                .orElse(null);

        if (lessonToDelete == null || !lessonToDelete.getStudentName().equals(user.getName())) {
            req.setAttribute("error", "Lesson not found or access denied");
            handleStudentView(req, resp, rootPath, user);
            return;
        }

        // Check if lesson can be deleted (only PENDING status)
        if (!"PENDING".equalsIgnoreCase(lessonToDelete.getStatus())) {
            req.setAttribute("error", "Only pending lessons can be deleted");
            handleStudentView(req, resp, rootPath, user);
            return;
        }

        // Remove from all collections
        allLessons.removeIf(l -> l.getLessonId().equals(lessonId));
        lessonQueue.removeIf(l -> l.getLessonId().equals(lessonId));

        FileHandler.writeLessons(allLessons, rootPath);

        req.setAttribute("successMessage", "Lesson successfully deleted");
        handleStudentView(req, resp, rootPath, user);
    }


    private void handleStatusChange(HttpServletRequest req, HttpServletResponse resp,
                                    String rootPath, String action)
            throws IOException {
        String lessonId = req.getParameter("lessonId");
        String newStatus = "ACCEPTED".equals(action) ? "ACCEPTED" : "DENIED";

        List<Lesson> allLessons = FileHandler.readLessons(rootPath);
        allLessons.stream()
                .filter(l -> l.getLessonId().equals(lessonId))
                .findFirst()
                .ifPresent(lesson -> {
                    lesson.setStatus(newStatus);
                    lessonQueue.removeIf(l -> l.getLessonId().equals(lessonId));
                });

        FileHandler.writeLessons(allLessons, rootPath);
        resp.sendRedirect(req.getContextPath() + "/lesson?action=instructorView");
    }
}