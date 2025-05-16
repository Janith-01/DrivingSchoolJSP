package com.Model;

import java.time.LocalDateTime;

public abstract class Payment {
    private String paymentId;
    private String studentId;
    private double amount;
    private LocalDateTime paymentDate;
    private String status; // "Pending", "Completed", "Failed"
    private String lessonId;

    public Payment(String paymentId, String studentId, double amount, LocalDateTime paymentDate, String status, String lessonId) {
        this.paymentId = paymentId;
        this.studentId = studentId;
        this.amount = amount;
        this.paymentDate = paymentDate;
        this.status = status;
        this.lessonId = lessonId;
    }

    // Getters and setters
    public String getPaymentId() { return paymentId; }
    public String getStudentId() { return studentId; }
    public double getAmount() { return amount; }
    public LocalDateTime getPaymentDate() { return paymentDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getLessonId() { return lessonId; }

    // Abstract method for payment processing
    public abstract boolean processPayment();

    // For FileHandler
    public String toFileString() {
        String type = this instanceof CardPayment ? "CardPayment" : "CashPayment";
        return String.format("%s,%s,%s,%.2f,%s,%s,%s",
                type, paymentId, studentId, amount, paymentDate.toString(), status, lessonId);
    }
}