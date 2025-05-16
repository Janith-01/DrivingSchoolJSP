package com.Model;

public abstract class Progress {
    private String progressId;
    private String lessonId;
    private String studentName;
    private String instructorName;
    private int score; // 0-100
    private String remarks;
    private String date;

    public Progress(String progressId, String lessonId, String studentName, String instructorName,
                    int score, String remarks, String date) {
        this.progressId = progressId;
        this.lessonId = lessonId;
        this.studentName = studentName != null ? studentName : "Unknown Student";
        this.instructorName = instructorName != null ? instructorName : "Unknown Instructor";
        this.score = score;
        this.remarks = remarks != null ? remarks : "";
        this.date = date;
    }

    // Getters and setters
    public String getProgressId() { return progressId; }
    public String getLessonId() { return lessonId; }
    public String getStudentName() { return studentName; }
    public String getInstructorName() { return instructorName; }
    public int getScore() { return score; }
    public String getRemarks() { return remarks; }
    public String getDate() { return date; }

    public void setScore(int score) { this.score = score; }
    public void setRemarks(String remarks) { this.remarks = remarks; }

    // Abstract method for readiness calculation
    public abstract boolean isReadyForTest();

    public String toFileString() {
        return String.format("%s,%s,%s,%s,%d,%s,%s",
                progressId, lessonId, studentName, instructorName, score, remarks, date);
    }

    public static class BeginnerProgress extends Progress {
        public BeginnerProgress(String progressId, String lessonId, String studentName, String instructorName,
                                int score, String remarks, String date) {
            super(progressId, lessonId, studentName, instructorName, score, remarks, date);
        }

        @Override
        public boolean isReadyForTest() {
            // Beginner students need a score of at least 80 and positive remarks
            return getScore() >= 80 && !getRemarks().isEmpty() && !getRemarks().toLowerCase().contains("fail");
        }
    }

    public static class AdvancedProgress extends Progress {
        public AdvancedProgress(String progressId, String lessonId, String studentName, String instructorName,
                                int score, String remarks, String date) {
            super(progressId, lessonId, studentName, instructorName, score, remarks, date);
        }

        @Override
        public boolean isReadyForTest() {
            // Advanced students need a score of at least 90 and specific remarks
            return getScore() >= 90 && getRemarks().toLowerCase().contains("confident");
        }
    }
}