package com.Model;

public class AdvancedLesson extends Lesson {
    public AdvancedLesson(String lessonId, String studentId, String instructorId, String date, String time, String type) {
        super(lessonId, studentId, instructorId, date, time, type);
    }

    @Override
    public String getSchedulingRules() {
        return "Advanced lesson " + getLessonId() + " requires a 2-hour slot with an experienced instructor.";
    }
}
