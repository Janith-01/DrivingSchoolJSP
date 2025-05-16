package com.Model;

import java.time.LocalDateTime;

public class CardPayment extends Payment {
    private String cardNumber; // Last 4 digits for simplicity

    public CardPayment(String paymentId, String studentId, double amount, LocalDateTime paymentDate, String status, String lessonId, String cardNumber) {
        super(paymentId, studentId, amount, paymentDate, status, lessonId);
        this.cardNumber = cardNumber;
    }

    public String getCardNumber() { return cardNumber; }

    @Override
    public boolean processPayment() {
        System.out.println("Processing card payment for card ending in " + cardNumber);
        return true; // Mock success
    }

    @Override
    public String toFileString() {
        return String.format("CardPayment,%s,%s,%.2f,%s,%s,%s,%s",
                getPaymentId(), getStudentId(), getAmount(), getPaymentDate().toString(), getStatus(), getLessonId(), cardNumber);
    }
}