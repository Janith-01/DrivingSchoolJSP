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

@WebServlet("/lesson")
public class LessonServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String rootPath = getServletContext().getRealPath("/");
        List<Lesson> lessons = FileHandler.readLessons(rootPath);

        if ("list".equals(action)) {
            req.setAttribute("lessons", lessons);
            req.getRequestDispatcher("/jsp/lessonList.jsp").forward(req, resp);
        } else if ("edit".equals(action)) {
            String lessonId = req.getParameter("lessonId");
            Lesson lesson = lessons.stream().filter(l -> l.getLessonId().equals(lessonId)).findFirst().orElse(null);
            req.setAttribute("lesson", lesson);
            req.getRequestDispatcher("/jsp/reschedule.jsp").forward(req, resp);
        } else {
            req.getRequestDispatcher("/jsp/bookingForm.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String rootPath = getServletContext().getRealPath("/");
        List<Lesson> lessons = FileHandler.readLessons(rootPath);

        if ("register".equals(action)) {
            String lessonId = UUID.randomUUID().toString();
            String studentId = req.getParameter("studentId");
            String instructorId = req.getParameter("instructorId");
            String date = req.getParameter("date");
            String time = req.getParameter("time");
            String type = req.getParameter("type");

            Lesson lesson;
            if ("Beginner".equals(type)) {
                lesson = new BeginnerLesson(lessonId, studentId, instructorId, date, time, type);
            } else {
                lesson = new AdvancedLesson(lessonId, studentId, instructorId, date, time, type);
            }
            lessons.add(lesson);
            FileHandler.writeLessons(lessons, rootPath);
            resp.sendRedirect("lesson?action=list");
        } else if ("update".equals(action)) {
            String lessonId = req.getParameter("lessonId");
            String studentId = req.getParameter("studentId");
            String instructorId = req.getParameter("instructorId");
            String date = req.getParameter("date");
            String time = req.getParameter("time");
            String type = req.getParameter("type");

            lessons.removeIf(l -> l.getLessonId().equals(lessonId));
            Lesson lesson;
            if ("Beginner".equals(type)) {
                lesson = new BeginnerLesson(lessonId, studentId, instructorId, date, time, type);
            } else {
                lesson = new AdvancedLesson(lessonId, studentId, instructorId, date, time, type);
            }
            lessons.add(lesson);
            FileHandler.writeLessons(lessons, rootPath);
            resp.sendRedirect("lesson?action=list");
        } else if ("delete".equals(action)) {
            String lessonId = req.getParameter("lessonId");
            lessons.removeIf(l -> l.getLessonId().equals(lessonId));
            FileHandler.writeLessons(lessons, rootPath);
            resp.sendRedirect("lesson?action=list");
        }
    }
}
