package com.Model;

public class AdvancedLesson extends Lesson {
    public AdvancedLesson(String lessonId, String studentName, String instructorName,
                          String date, String time, String type, String status) {
        super(lessonId, studentName, instructorName, date, time, type, status);
    }

    @Override
    public String getSchedulingRules() {
        return "2-hour sessions, requires completion of 5 beginner lessons";
    }
}