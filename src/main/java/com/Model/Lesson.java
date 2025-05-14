package com.Model;

public class Lesson {
    private String lessonId;
    private String studentId;
    private String instructorId;
    private String date;
    private String time;
    private String type;

    public Lesson(String lessonId, String studentId, String instructorId, String date, String time, String type) {
        this.lessonId = lessonId;
        this.studentId = studentId;
        this.instructorId = instructorId;
        this.date = date;
        this.time = time;
        this.type = type;
    }
    public String toFileString() {
        return lessonId + "," + studentId + "," + instructorId + "," + date + "," + time + "," + type;
    }

    public static Lesson fromFileString(String line) {
        String[] data = line.split(",");
        return new Lesson(data[0], data[1], data[2], data[3], data[4], data[5]);
    }

    public String getLessonId() { return lessonId; }
    public void setLessonId(String lessonId) { this.lessonId = lessonId; }
    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }
    public String getInstructorId() { return instructorId; }
    public void setInstructorId(String instructorId) { this.instructorId = instructorId; }
    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }
    public String getTime() { return time; }
    public void setTime(String time) { this.time = time; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getSchedulingRules() {
        return "Default scheduling rules for lesson " + lessonId;
    }


}