package com.Model;

import java.time.LocalDateTime;

public class StudentInvoice implements Invoice {
    private String studentId;
    private String paymentId;
    private double amount;
    private LocalDateTime date;

    public StudentInvoice(String studentId, String paymentId, double amount, LocalDateTime date) {
        this.studentId = studentId;
        this.paymentId = paymentId;
        this.amount = amount;
        this.date = date;
    }

    @Override
    public String generateInvoice() {
        return String.format("Student Invoice\nPayment ID: %s\nStudent ID: %s\nAmount: $%.2f\nDate: %s",
                paymentId, studentId, amount, date);
    }
}