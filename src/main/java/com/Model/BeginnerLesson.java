package com.Model;

public class BeginnerLesson extends Lesson {
    public BeginnerLesson(String lessonId, String studentId, String instructorId, String date, String time, String type) {
        super(lessonId, studentId, instructorId, date, time, type);
    }

    @Override
    public String getSchedulingRules() {
        return "Beginner lesson " + getLessonId() + " requires a 1-hour slot with a certified instructor.";
    }
}