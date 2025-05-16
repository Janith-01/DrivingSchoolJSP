package com.Model;

import java.time.LocalDateTime;

public abstract class Review {
    private String reviewId;
    private String studentId;
    private String targetId; // Instructor ID or Lesson ID
    private String feedback;
    private int rating; // 1-5
    private LocalDateTime submissionDate;
    private String status; // e.g., "Pending", "Approved", "Removed"

    public Review(String reviewId, String studentId, String targetId, String feedback, int rating, LocalDateTime submissionDate, String status) {
        if (rating < 1 || rating > 5) throw new IllegalArgumentException("Rating must be between 1 and 5");
        this.reviewId = reviewId;
        this.studentId = studentId;
        this.targetId = targetId;
        this.feedback = feedback;
        this.rating = rating;
        this.submissionDate = submissionDate;
        this.status = status;
    }

    public String getReviewId() { return reviewId; }
    public String getStudentId() { return studentId; }
    public String getTargetId() { return targetId; }
    public String getFeedback() { return feedback; }
    public int getRating() { return rating; }
    public LocalDateTime getSubmissionDate() { return submissionDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public void setFeedback(String feedback) { this.feedback = feedback; }
    public void setRating(int rating) {
        if (rating < 1 || rating > 5) throw new IllegalArgumentException("Rating must be between 1 and 5");
        this.rating = rating;
    }

    public abstract String toFileString();
    public abstract String displayForStudent(); // Polymorphism for different display formats
    public abstract String displayForAdmin();   // Polymorphism for different display formats
}