package com.Model;

import java.time.LocalDateTime;

public class StudentInvoice implements Invoice {
    private String studentId;
    private String paymentId;
    private double amount;
    private LocalDateTime date;
    private String status; // Added field

    public StudentInvoice(String studentId, String paymentId, double amount, LocalDateTime date) {
        this.studentId = studentId;
        this.paymentId = paymentId;
        this.amount = amount;
        this.date = date;
        this.status = "Pending"; // Default status
    }

    @Override
    public String generateInvoice() {
        return String.format("Student Invoice\nPayment ID: %s\nStudent ID: %s\nAmount: $%.2f\nDate: %s\nStatus: %s",
                paymentId, studentId, amount, date, status);
    }

    @Override
    public String getPaymentId() {
        return paymentId;
    }

    @Override
    public String toFileString() {
        return String.format("Student,%s,%s,%.2f,%s,%s",
                paymentId, studentId, amount, date, status);
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatus() {
        return status;
    }
}