package com.servlet;

import com.Model.*;
import com.Util.FileHandler;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;
import java.util.UUID;
import java.util.stream.Collectors;

@WebServlet("/lesson")
public class LessonServlet extends HttpServlet {
    private Queue<Lesson> lessonQueue = new LinkedList<>();

    @Override
    public void init() throws ServletException {
        try {
            String rootPath = getServletContext().getRealPath("/");
            List<Lesson> lessons = FileHandler.readLessons(rootPath);
            System.out.println("[LessonServlet] Initialized lessons: " + lessons.size() + " lessons");
            lessonQueue = lessons.stream()
                    .filter(l -> "PENDING".equalsIgnoreCase(l.getStatus()))
                    .collect(Collectors.toCollection(LinkedList::new));
            System.out.println("[LessonServlet] Initialized lessonQueue: " + lessonQueue.size() + " pending lessons");
        } catch (IOException e) {
            System.err.println("[LessonServlet] Error initializing lesson queue: " + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String rootPath = getServletContext().getRealPath("/");
        User user = (User) req.getSession().getAttribute("loggedInUser");
        List<Lesson> allLessons = FileHandler.readLessons(rootPath);
        System.out.println("[LessonServlet] All lessons: " + allLessons.size() + " lessons");
        System.out.println("[LessonServlet] Logged-in user: " + (user != null ? user.getName() + " (isInstructor: " + (user instanceof Instructor) + ")" : "null"));

        if (user == null) {
            System.out.println("[LessonServlet] No logged-in user, redirecting to login");
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if ("list".equals(action)) {
            List<Lesson> lessons;
            if (user instanceof Instructor) {
                // Filter for PENDING and ACCEPTED lessons
                lessons = allLessons.stream()
                        .filter(l -> l.getInstructorName().equalsIgnoreCase(user.getName()) &&
                                ("PENDING".equalsIgnoreCase(l.getStatus()) || "ACCEPTED".equalsIgnoreCase(l.getStatus())))
                        .collect(Collectors.toList());
                // Load progress to identify lessons with progress
                List<Progress> allProgress = FileHandler.readProgress(rootPath);
                List<String> lessonsWithProgress = allProgress.stream()
                        .map(Progress::getLessonId)
                        .collect(Collectors.toList());
                System.out.println("[LessonServlet] Lessons filtered for instructor '" + user.getName() + "': " + lessons.size() + " lessons (PENDING or ACCEPTED)");
                System.out.println("[LessonServlet] Instructor lessons: " + lessons);
                System.out.println("[LessonServlet] Lessons with progress: " + lessonsWithProgress.size());
                req.setAttribute("instructorLessons", lessons);
                req.setAttribute("lessonsWithProgress", lessonsWithProgress);
                req.getRequestDispatcher("/jsp/instructorPages/pendingProgressList.jsp").forward(req, resp);
            } else {
                lessons = allLessons.stream()
                        .filter(l -> l.getStudentName().equalsIgnoreCase(user.getName()))
                        .collect(Collectors.toList());
                System.out.println("[LessonServlet] Student lessons: " + lessons);
                req.setAttribute("lessons", lessons);
                req.getRequestDispatcher("/jsp/studentPages/lessonList.jsp").forward(req, resp);
            }
        } else if ("edit".equals(action)) {
            String lessonId = req.getParameter("lessonId");
            Lesson lesson = allLessons.stream()
                    .filter(l -> l.getLessonId().equals(lessonId) && l.getStudentName().equals(user.getName()))
                    .findFirst()
                    .orElse(null);
            if (lesson == null || !"PENDING".equalsIgnoreCase(lesson.getStatus())) {
                req.setAttribute("error", "Lesson not found or cannot be edited");
                req.getRequestDispatcher("/jsp/studentPages/lessonList.jsp").forward(req, resp);
                return;
            }
            req.setAttribute("lesson", lesson);
            req.setAttribute("instructors", FileHandler.readInstructors(rootPath));
            req.getRequestDispatcher("/jsp/studentPages/UpdateBookingInfo.jsp").forward(req, resp);
        } else if ("delete".equals(action)) {
            String lessonId = req.getParameter("lessonId");
            Lesson lesson = allLessons.stream()
                    .filter(l -> l.getLessonId().equals(lessonId) && l.getStudentName().equals(user.getName()))
                    .findFirst()
                    .orElse(null);

            if (lesson == null || !"PENDING".equalsIgnoreCase(lesson.getStatus())) {
                req.setAttribute("error", "Lesson not found or cannot be deleted");
                req.getRequestDispatcher("/jsp/studentPages/lessonList.jsp").forward(req, resp);
                return;
            }

            allLessons.removeIf(l -> l.getLessonId().equals(lessonId));
            lessonQueue.removeIf(l -> l.getLessonId().equals(lessonId));
            FileHandler.writeLessons(allLessons, rootPath);
            resp.sendRedirect(req.getContextPath() + "/lesson?action=list");
        } else {
            req.getRequestDispatcher("/jsp/studentPages/bookingForm.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String rootPath = getServletContext().getRealPath("/");
        User user = (User) req.getSession().getAttribute("loggedInUser");
        List<Lesson> allLessons = FileHandler.readLessons(rootPath);

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if ("register".equals(action)) {
            String lessonId = UUID.randomUUID().toString();
            String instructorName = req.getParameter("instructorName");
            String date = req.getParameter("date");
            String time = req.getParameter("time");
            String type = req.getParameter("type");

            if (instructorName == null || date == null || time == null || type == null ||
                    instructorName.trim().isEmpty() || date.trim().isEmpty() || time.trim().isEmpty() || type.trim().isEmpty()) {
                req.setAttribute("error", "All fields are required");
                req.getRequestDispatcher("/jsp/studentPages/bookingForm.jsp").forward(req, resp);
                return;
            }

            Lesson lesson = "Beginner".equals(type) ?
                    new BeginnerLesson(lessonId, user.getName(), instructorName, date, time, type, "PENDING") :
                    new AdvancedLesson(lessonId, user.getName(), instructorName, date, time, type, "PENDING");
            lessonQueue.add(lesson);
            allLessons.add(lesson);
            FileHandler.writeLessons(allLessons, rootPath);
            resp.sendRedirect(req.getContextPath() + "/jsp/studentPages/bookingForm.jsp?success=true");
        } else if ("update".equals(action)) {
            String lessonId = req.getParameter("lessonId");
            String instructorName = req.getParameter("instructorName");
            String date = req.getParameter("date");
            String time = req.getParameter("time");
            String type = req.getParameter("type");

            if (lessonId == null || instructorName == null || date == null || time == null || type == null) {
                req.setAttribute("error", "All fields are required");
                req.getRequestDispatcher("/jsp/studentPages/UpdateBookingInfo.jsp").forward(req, resp);
                return;
            }

            Lesson existingLesson = allLessons.stream()
                    .filter(l -> l.getLessonId().equals(lessonId) && l.getStudentName().equals(user.getName()))
                    .findFirst()
                    .orElse(null);

            if (existingLesson == null || !"PENDING".equalsIgnoreCase(existingLesson.getStatus())) {
                req.setAttribute("error", "Lesson not found or cannot be updated");
                req.getRequestDispatcher("/jsp/studentPages/lessonList.jsp").forward(req, resp);
                return;
            }

            Lesson updatedLesson = "Beginner".equals(type) ?
                    new BeginnerLesson(lessonId, user.getName(), instructorName, date, time, type, "PENDING") :
                    new AdvancedLesson(lessonId, user.getName(), instructorName, date, time, type, "PENDING");

            allLessons.removeIf(l -> l.getLessonId().equals(lessonId));
            lessonQueue.removeIf(l -> l.getLessonId().equals(lessonId));
            allLessons.add(updatedLesson);
            lessonQueue.add(updatedLesson);
            FileHandler.writeLessons(allLessons, rootPath);
            resp.sendRedirect(req.getContextPath() + "/lesson?action=list");
        } else if ("delete".equals(action)) {
            String lessonId = req.getParameter("lessonId");
            Lesson lesson = allLessons.stream()
                    .filter(l -> l.getLessonId().equals(lessonId) && l.getStudentName().equals(user.getName()))
                    .findFirst()
                    .orElse(null);

            if (lesson == null || !"PENDING".equalsIgnoreCase(lesson.getStatus())) {
                req.setAttribute("error", "Lesson not found or cannot be deleted");
                req.getRequestDispatcher("/jsp/studentPages/lessonList.jsp").forward(req, resp);
                return;
            }

            allLessons.removeIf(l -> l.getLessonId().equals(lessonId));
            lessonQueue.removeIf(l -> l.getLessonId().equals(lessonId));
            FileHandler.writeLessons(allLessons, rootPath);
            resp.sendRedirect(req.getContextPath() + "/lesson?action=list");
        } else if ("ACCEPTED".equals(action) || "DENIED".equals(action)) {
            if (!(user instanceof Instructor)) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            String lessonId = req.getParameter("lessonId");
            allLessons.stream()
                    .filter(l -> l.getLessonId().equals(lessonId))
                    .findFirst()
                    .ifPresent(l -> {
                        l.setStatus(action);
                        lessonQueue.removeIf(lesson -> lesson.getLessonId().equals(lessonId));
                    });
            FileHandler.writeLessons(allLessons, rootPath);
            resp.sendRedirect(req.getContextPath() + "/lesson?action=list");
        }
    }
}