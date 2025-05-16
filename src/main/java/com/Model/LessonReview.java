package com.Model;

import java.time.LocalDateTime;

public class LessonReview extends Review {
    public LessonReview(String reviewId, String studentId, String lessonId, String feedback, int rating, LocalDateTime submissionDate, String status) {
        super(reviewId, studentId, lessonId, feedback, rating, submissionDate, status);
    }

    @Override
    public String toFileString() {
        return String.format("LessonReview,%s,%s,%s,%s,%d,%s,%s",
                getReviewId(), getStudentId(), getTargetId(), getFeedback(), getRating(), getSubmissionDate(), getStatus());
    }

    @Override
    public String displayForStudent() {
        return String.format("Lesson Review (ID: %s) - Rating: %d/5, Feedback: %s, Date: %s",
                getTargetId(), getRating(), getFeedback(), getSubmissionDate());
    }

    @Override
    public String displayForAdmin() {
        return String.format("Lesson Review [ID: %s] by Student %s - Rating: %d/5, Feedback: %s, Status: %s, Date: %s",
                getTargetId(), getStudentId(), getRating(), getFeedback(), getStatus(), getSubmissionDate());
    }
}