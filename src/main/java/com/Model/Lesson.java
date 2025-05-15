package com.Model;

public abstract class Lesson {
    private String lessonId;
    private String studentName;
    private String instructorName;
    private String date;
    private String time;
    private String type;
    private String status;

    public Lesson(String lessonId, String studentName, String instructorName,
                  String date, String time, String type, String status) {
        this.lessonId = lessonId;
        this.studentName = studentName != null ? studentName : "Unknown Student";
        this.instructorName = instructorName != null ? instructorName : "Unknown Instructor";
        this.date = date;
        this.time = time;
        this.type = type;
        this.status = status != null ? status : "PENDING";
    }

    // Getters and setters
    public String getLessonId() { return lessonId; }
    public String getStudentName() { return studentName; }
    public String getInstructorName() { return instructorName; }
    public String getDate() { return date; }
    public String getTime() { return time; }
    public String getType() { return type; }
    public String getStatus() { return status; }

    public void setStatus(String status) { this.status = status; }

    public String toFileString() {
        return String.format("%s,%s,%s,%s,%s,%s,%s",
                lessonId, studentName, instructorName, date, time, type, status);
    }

    public static Lesson fromFileString(String fileString) {
        String[] parts = fileString.split(",", 7);
        if (parts.length < 7) return null;
        return new BeginnerLesson(parts[0], parts[1], parts[2], parts[3],
                parts[4], parts[5], parts[6]);
    }

    public abstract String getSchedulingRules();
}