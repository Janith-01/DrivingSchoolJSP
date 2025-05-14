package com.Model;

public class AdvancedLesson extends Lesson {
    public AdvancedLesson(String lessonId, String studentName, String instructorName, String date, String time, String type) {
        super(lessonId, studentName, instructorName, date, time, type);
    }

    @Override
    public String getSchedulingRules() {
        return "Advanced lesson " + getLessonId() + " requires a 2-hour slot with an advanced certified instructor.";
    }
}