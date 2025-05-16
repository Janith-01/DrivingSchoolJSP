package com.Model;

import java.time.LocalDateTime;

public class CashPayment extends Payment {
    public CashPayment(String paymentId, String studentId, double amount, LocalDateTime paymentDate, String status, String lessonId) {
        super(paymentId, studentId, amount, paymentDate, status, lessonId);
    }

    @Override
    public boolean processPayment() {
        System.out.println("Cash payment received.");
        return true; // Mock success
    }
}