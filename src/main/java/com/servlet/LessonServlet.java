package com.servlet;

import com.Model.Lesson;
import com.Model.BeginnerLesson;
import com.Model.AdvancedLesson;
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

@WebServlet("/lesson")
public class LessonServlet extends HttpServlet {
    private Queue<Lesson> lessonQueue; // Queue to manage lesson scheduling

    @Override
    public void init() throws ServletException {
        // Initialize the queue from the file on servlet startup
        try {
            String rootPath = getServletContext().getRealPath("/");
            List<Lesson> lessons = FileHandler.readLessons(rootPath);
            lessonQueue = new LinkedList<>(lessons);
            System.out.println("Initialized lesson queue with " + lessonQueue.size() + " lessons: " + lessonQueue);
        } catch (IOException e) {
            System.err.println("Error initializing lesson queue: " + e.getMessage());
            lessonQueue = new LinkedList<>();
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("list".equals(action)) {
            // Pass the queue as a list to the JSP for display
            List<Lesson> lessonsToDisplay = new LinkedList<>(lessonQueue);
            System.out.println("Lessons to display in list action: " + lessonsToDisplay);
            req.setAttribute("lessons", lessonsToDisplay);
            req.getRequestDispatcher("/jsp/studentPages/lessonList.jsp").forward(req, resp);
        } else if ("edit".equals(action)) {
            String lessonId = req.getParameter("lessonId");
            Lesson lesson = lessonQueue.stream()
                    .filter(l -> l.getLessonId().equals(lessonId))
                    .findFirst()
                    .orElse(null);
            req.setAttribute("lesson", lesson);
            req.getRequestDispatcher("/jsp/studentPages/reschedule.jsp").forward(req, resp);
        } else {
            req.getRequestDispatcher("/jsp/studentPages/bookingForm.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String rootPath = getServletContext().getRealPath("/");

        if ("register".equals(action)) {
            String lessonId = UUID.randomUUID().toString();
            String studentName = req.getParameter("studentName");
            String instructorName = req.getParameter("instructorName");
            String date = req.getParameter("date");
            String time = req.getParameter("time");
            String type = req.getParameter("type");

            // Validate inputs to avoid null values
            if (studentName == null || instructorName == null || date == null || time == null || type == null) {
                req.setAttribute("error", "All fields are required.");
                req.getRequestDispatcher("/jsp/studentPages/bookingForm.jsp").forward(req, resp);
                return;
            }

            Lesson lesson;
            if ("Beginner".equals(type)) {
                lesson = new BeginnerLesson(lessonId, studentName, instructorName, date, time, type);
            } else {
                lesson = new AdvancedLesson(lessonId, studentName, instructorName, date, time, type);
            }

            // Add to the queue (FIFO scheduling)
            lessonQueue.offer(lesson);
            System.out.println("Added lesson to queue: " + lesson.getLessonId());

            // Persist the queue to the file
            FileHandler.writeLessons(new LinkedList<>(lessonQueue), rootPath);
            resp.sendRedirect(req.getContextPath() + "/jsp/studentPages/bookingForm.jsp?success=true");
        } else if ("update".equals(action)) {
            String lessonId = req.getParameter("lessonId");
            String studentName = req.getParameter("studentName");
            String instructorName = req.getParameter("instructorName");
            String date = req.getParameter("date");
            String time = req.getParameter("time");
            String type = req.getParameter("type");

            if (lessonId == null || studentName == null || instructorName == null || date == null || time == null || type == null) {
                req.setAttribute("error", "All fields are required.");
                req.getRequestDispatcher("/jsp/studentPages/reschedule.jsp").forward(req, resp);
                return;
            }

            // Remove the old lesson from the queue
            lessonQueue.removeIf(l -> l.getLessonId().equals(lessonId));

            // Add the updated lesson to the queue (at the end, as a new booking)
            Lesson lesson;
            if ("Beginner".equals(type)) {
                lesson = new BeginnerLesson(lessonId, studentName, instructorName, date, time, type);
            } else {
                lesson = new AdvancedLesson(lessonId, studentName, instructorName, date, time, type);
            }
            lessonQueue.offer(lesson);
            System.out.println("Updated lesson in queue: " + lessonId);

            // Persist the queue to the file
            FileHandler.writeLessons(new LinkedList<>(lessonQueue), rootPath);
            resp.sendRedirect("lesson?action=list");
        } else if ("delete".equals(action)) {
            String lessonId = req.getParameter("lessonId");
            lessonQueue.removeIf(l -> l.getLessonId().equals(lessonId));
            System.out.println("Deleted lesson from queue: " + lessonId);

            // Persist the queue to the file
            FileHandler.writeLessons(new LinkedList<>(lessonQueue), rootPath);
            resp.sendRedirect("lesson?action=list");
        }
    }
}