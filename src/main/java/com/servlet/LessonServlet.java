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

        if ("instructorView".equals(action)) {
            handleInstructorView(req, resp, rootPath, user);
        } else if ("list".equals(action)) {
            handleStudentView(req, resp, rootPath, user);
        } else {
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

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        String rootPath = getServletContext().getRealPath("/");
        User user = (User) req.getSession().getAttribute("loggedInUser");

        if ("register".equals(action)) {
            handleLessonRegistration(req, resp, rootPath, user);
        } else if ("ACCEPTED".equals(action) || "DENIED".equals(action)) {
            handleStatusChange(req, resp, rootPath, action);
        }
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