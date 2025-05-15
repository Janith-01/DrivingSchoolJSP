package com.Model;

public class BeginnerLesson extends Lesson {
    public BeginnerLesson(String lessonId, String studentName, String instructorName,
                          String date, String time, String type, String status) {
        super(lessonId, studentName, instructorName, date, time, type, status);
    }

    @Override
    public String getSchedulingRules() {
        return "1-hour sessions, maximum 2 sessions per week";
    }
}