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
import java.util.List;
import java.util.UUID;

@WebServlet("/scheduleLesson")
public class ScheduleLessonServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("calendar".equals(action)) {
            String rootPath = getServletContext().getRealPath("/");
            List<Lesson> lessons = FileHandler.readLessons(rootPath);
            req.setAttribute("lessons", lessons);
            req.getRequestDispatcher("/jsp/calendar.jsp").forward(req, resp);
        } else {
            req.getRequestDispatcher("/jsp/bookingForm.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String rootPath = getServletContext().getRealPath("/");
        List<Lesson> lessons = FileHandler.readLessons(rootPath);

        if ("schedule".equals(action)) {
            String lessonId = UUID.randomUUID().toString();
            String studentId = req.getParameter("studentId");
            String instructorId = req.getParameter("instructorId");
            String date = req.getParameter("date");
            String time = req.getParameter("time");
            String type = req.getParameter("type");

            // Validate instructor availability and scheduling rules
            boolean isSlotAvailable = checkInstructorAvailability(lessons, instructorId, date, time, type);
            if (!isSlotAvailable) {
                req.setAttribute("error", "Instructor is not available at the selected time.");
                req.getRequestDispatcher("/jsp/bookingForm.jsp").forward(req, resp);
                return;
            }

            Lesson lesson;
            if ("Beginner".equals(type)) {
                lesson = new BeginnerLesson(lessonId, studentId, instructorId, date, time, type);
            } else {
                lesson = new AdvancedLesson(lessonId, studentId, instructorId, date, time, type);
            }
            lessons.add(lesson);
            FileHandler.writeLessons(lessons, rootPath);
            resp.sendRedirect("scheduleLesson?action=calendar");
        } else if ("reschedule".equals(action)) {
            String lessonId = req.getParameter("lessonId");
            String studentId = req.getParameter("studentId");
            String instructorId = req.getParameter("instructorId");
            String date = req.getParameter("date");
            String time = req.getParameter("time");
            String type = req.getParameter("type");

            // Validate instructor availability for the new time slot
            boolean isSlotAvailable = checkInstructorAvailability(lessons, instructorId, date, time, type);
            if (!isSlotAvailable) {
                req.setAttribute("error", "Instructor is not available at the selected time.");
                req.getRequestDispatcher("/jsp/reschedule.jsp").forward(req, resp);
                return;
            }

            lessons.removeIf(l -> l.getLessonId().equals(lessonId));
            Lesson lesson;
            if ("Beginner".equals(type)) {
                lesson = new BeginnerLesson(lessonId, studentId, instructorId, date, time, type);
            } else {
                lesson = new AdvancedLesson(lessonId, studentId, instructorId, date, time, type);
            }
            lessons.add(lesson);
            FileHandler.writeLessons(lessons, rootPath);
            resp.sendRedirect("scheduleLesson?action=calendar");
        }
    }

    // Helper method to check instructor availability and scheduling rules
    private boolean checkInstructorAvailability(List<Lesson> lessons, String instructorId, String date, String time, String type) {
        for (Lesson lesson : lessons) {
            if (lesson.getInstructorId().equals(instructorId) && lesson.getDate().equals(date)) {
                if (lesson.getTime().equals(time)) {
                    return false;
                }
                // Check duration based on lesson type (Beginner: 1 hour, Advanced: 2 hours)
                int lessonDuration = lesson.getType().equals("Beginner") ? 1 : 2;
                int requestedDuration = type.equals("Beginner") ? 1 : 2;

                int existingStartHour = Integer.parseInt(lesson.getTime().split(":")[0]);
                int requestedStartHour = Integer.parseInt(time.split(":")[0]);

                int existingEndHour = existingStartHour + lessonDuration;
                int requestedEndHour = requestedStartHour + requestedDuration;

                // Check for overlap
                if (requestedStartHour < existingEndHour && requestedEndHour > existingStartHour) {
                    return false; // Time slot overlaps with an existing lesson
                }
            }
        }
        return true; // Slot is available
    }
}