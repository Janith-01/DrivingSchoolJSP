package com.Model;

public class BeginnerLesson extends Lesson {
    public BeginnerLesson(String lessonId, String studentName, String instructorName, String date, String time, String type) {
        super(lessonId, studentName, instructorName, date, time, type);
    }

    @Override
    public String getSchedulingRules() {
        return "Beginner lesson " + getLessonId() + " requires a 1-hour slot with a certified instructor.";
    }
}