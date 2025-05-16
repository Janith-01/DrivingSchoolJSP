package com.servlet;

import com.Model.*;
import com.Util.FileHandler;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@WebServlet("/progress")
public class ProgressServlet extends HttpServlet {

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

        switch (action != null ? action : "") {
            case "viewProgress":
                handleViewProgress(req, resp, rootPath, user);
                break;
            case "editProgress":
                handleEditProgress(req, resp, rootPath, user);
                break;
            case "feedback":
                handleFeedbackView(req, resp, rootPath, user);
                break;
            case "studentProgress":
                handleStudentProgress(req, resp, rootPath, user);
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

        switch (action != null ? action : "") {
            case "addProgress":
                handleAddProgress(req, resp, rootPath, user);
                break;
            case "updateProgress":
                handleUpdateProgress(req, resp, rootPath, user);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/login");
        }
    }

    private void handleViewProgress(HttpServletRequest req, HttpServletResponse resp,
                                    String rootPath, User user)
            throws ServletException, IOException {
        if (!(user instanceof Instructor)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Instructor instructor = (Instructor) user;
        List<Progress> allProgress = FileHandler.readProgress(rootPath);
        List<Progress> progressList = allProgress.stream()
                .filter(p -> p.getInstructorName().equalsIgnoreCase(instructor.getName()))
                .collect(Collectors.toList());

        req.setAttribute("progressList", progressList);
        req.getRequestDispatcher("/jsp/instructorPages/progressList.jsp").forward(req, resp);
    }

    private void handleEditProgress(HttpServletRequest req, HttpServletResponse resp,
                                    String rootPath, User user)
            throws ServletException, IOException {
        if (!(user instanceof Instructor)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String progressId = req.getParameter("progressId");
        List<Progress> allProgress = FileHandler.readProgress(rootPath);
        Progress progress = allProgress.stream()
                .filter(p -> p.getProgressId().equals(progressId) &&
                        p.getInstructorName().equalsIgnoreCase(user.getName()))
                .findFirst()
                .orElse(null);

        if (progress == null) {
            req.setAttribute("error", "Progress record not found or access denied");
            handleViewProgress(req, resp, rootPath, user);
            return;
        }

        req.setAttribute("progress", progress);
        req.getRequestDispatcher("/jsp/instructorPages/updateProgressForm.jsp").forward(req, resp);
    }

    private void handleFeedbackView(HttpServletRequest req, HttpServletResponse resp,
                                    String rootPath, User user)
            throws ServletException, IOException {
        if (!(user instanceof Instructor)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String lessonId = req.getParameter("lessonId");
        List<Lesson> allLessons = FileHandler.readLessons(rootPath);
        Lesson lesson = allLessons.stream()
                .filter(l -> l.getLessonId().equals(lessonId) &&
                        l.getInstructorName().equalsIgnoreCase(user.getName()) &&
                        "ACCEPTED".equalsIgnoreCase(l.getStatus()))
                .findFirst()
                .orElse(null);

        if (lesson == null) {
            req.setAttribute("error", "Lesson not found or access denied");
            req.getRequestDispatcher("/jsp/instructorPages/instructorHome.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("lesson", lesson);
        req.getRequestDispatcher("/jsp/instructorPages/feedBackForm.jsp").forward(req, resp);
    }

    private void handleStudentProgress(HttpServletRequest req, HttpServletResponse resp,
                                       String rootPath, User user)
            throws ServletException, IOException {
        List<Progress> allProgress = FileHandler.readProgress(rootPath);
        List<Progress> progressList = allProgress.stream()
                .filter(p -> p.getStudentName().equalsIgnoreCase(user.getName()))
                .collect(Collectors.toList());

        req.setAttribute("progressList", progressList);
        req.getRequestDispatcher("/jsp/studentPages/studentProgress.jsp").forward(req, resp);
    }

    private void handleAddProgress(HttpServletRequest req, HttpServletResponse resp,
                                   String rootPath, User user)
            throws ServletException, IOException {
        if (!(user instanceof Instructor)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String lessonId = req.getParameter("lessonId");
        String studentName = req.getParameter("studentName");
        String instructorName = req.getParameter("instructorName");
        String date = req.getParameter("date");
        String scoreStr = req.getParameter("score");
        String remarks = req.getParameter("remarks");

        // Validate inputs
        if (lessonId == null || studentName == null || instructorName == null ||
                date == null || scoreStr == null || remarks == null) {
            req.setAttribute("error", "All fields are required");
            handleFeedbackView(req, resp, rootPath, user);
            return;
        }

        int score;
        try {
            score = Integer.parseInt(scoreStr);
            if (score < 0 || score > 100) {
                req.setAttribute("error", "Score must be between 0 and 100");
                handleFeedbackView(req, resp, rootPath, user);
                return;
            }
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Invalid score format");
            handleFeedbackView(req, resp, rootPath, user);
            return;
        }

        // Verify lesson exists and is ACCEPTED
        List<Lesson> allLessons = FileHandler.readLessons(rootPath);
        Lesson lesson = allLessons.stream()
                .filter(l -> l.getLessonId().equals(lessonId) &&
                        l.getInstructorName().equalsIgnoreCase(user.getName()) &&
                        "ACCEPTED".equalsIgnoreCase(l.getStatus()))
                .findFirst()
                .orElse(null);

        if (lesson == null) {
            req.setAttribute("error", "Lesson not found or access denied");
            req.getRequestDispatcher("/jsp/instructorPages/instructorHome.jsp").forward(req, resp);
            return;
        }

        // Check if progress already exists
        List<Progress> progressList = FileHandler.readProgress(rootPath);
        if (progressList.stream().anyMatch(p -> p.getLessonId().equals(lessonId))) {
            req.setAttribute("error", "Progress already recorded for this lesson");
            req.getRequestDispatcher("/jsp/instructorPages/instructorHome.jsp").forward(req, resp);
            return;
        }

        // Create new progress entry
        String progressId = UUID.randomUUID().toString();
        Progress progress = lesson instanceof BeginnerLesson
                ? new Progress.BeginnerProgress(progressId, lessonId, studentName, instructorName, score, remarks, date)
                : new Progress.AdvancedProgress(progressId, lessonId, studentName, instructorName, score, remarks, date);

        progressList.add(progress);
        FileHandler.writeProgress(progressList, rootPath);

        req.setAttribute("successMessage", "Progress successfully recorded");
        req.getRequestDispatcher("/jsp/instructorPages/instructorHome.jsp").forward(req, resp);
    }

    private void handleUpdateProgress(HttpServletRequest req, HttpServletResponse resp,
                                      String rootPath, User user)
            throws ServletException, IOException {
        if (!(user instanceof Instructor)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String progressId = req.getParameter("progressId");
        String lessonId = req.getParameter("lessonId");
        String studentName = req.getParameter("studentName");
        String instructorName = req.getParameter("instructorName");
        String date = req.getParameter("date");
        String scoreStr = req.getParameter("score");
        String remarks = req.getParameter("remarks");

        // Validate inputs
        if (progressId == null || lessonId == null || studentName == null ||
                instructorName == null || date == null || scoreStr == null || remarks == null) {
            req.setAttribute("error", "All fields are required");
            handleEditProgress(req, resp, rootPath, user);
            return;
        }

        int score;
        try {
            score = Integer.parseInt(scoreStr);
            if (score < 0 || score > 100) {
                req.setAttribute("error", "Score must be between 0 and 100");
                handleEditProgress(req, resp, rootPath, user);
                return;
            }
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Invalid score format");
            handleEditProgress(req, resp, rootPath, user);
            return;
        }

        // Verify progress exists
        List<Progress> allProgress = FileHandler.readProgress(rootPath);
        Progress existingProgress = allProgress.stream()
                .filter(p -> p.getProgressId().equals(progressId) &&
                        p.getInstructorName().equalsIgnoreCase(user.getName()))
                .findFirst()
                .orElse(null);

        if (existingProgress == null) {
            req.setAttribute("error", "Progress record not found or access denied");
            handleViewProgress(req, resp, rootPath, user);
            return;
        }

        // Verify lesson exists and is ACCEPTED
        List<Lesson> allLessons = FileHandler.readLessons(rootPath);
        Lesson lesson = allLessons.stream()
                .filter(l -> l.getLessonId().equals(lessonId) &&
                        l.getInstructorName().equalsIgnoreCase(user.getName()) &&
                        "ACCEPTED".equalsIgnoreCase(l.getStatus()))
                .findFirst()
                .orElse(null);

        if (lesson == null) {
            req.setAttribute("error", "Associated lesson not found or access denied");
            handleViewProgress(req, resp, rootPath, user);
            return;
        }

        // Create updated progress entry
        Progress updatedProgress = lesson instanceof BeginnerLesson
                ? new Progress.BeginnerProgress(progressId, lessonId, studentName, instructorName, score, remarks, date)
                : new Progress.AdvancedProgress(progressId, lessonId, studentName, instructorName, score, remarks, date);

        // Update progress list
        allProgress.removeIf(p -> p.getProgressId().equals(progressId));
        allProgress.add(updatedProgress);
        FileHandler.writeProgress(allProgress, rootPath);

        req.setAttribute("successMessage", "Progress successfully updated");
        handleViewProgress(req, resp, rootPath, user);
    }
}