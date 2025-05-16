package com.Model;

import java.time.LocalDateTime;

public class CorporateInvoice implements Invoice {
    private String studentId;
    private String paymentId;
    private double amount;
    private LocalDateTime date;
    private String corporateId;
    private String status; // Added field

    public CorporateInvoice(String studentId, String paymentId, double amount, LocalDateTime date, String corporateId) {
        this.studentId = studentId;
        this.paymentId = paymentId;
        this.amount = amount;
        this.date = date;
        this.corporateId = corporateId;
        this.status = "Pending"; // Default status
    }

    @Override
    public String generateInvoice() {
        return String.format("Corporate Invoice\nPayment ID: %s\nStudent ID: %s\nCorporate ID: %s\nAmount: $%.2f\nDate: %s\nStatus: %s",
                paymentId, studentId, corporateId, amount, date, status);
    }

    @Override
    public String getPaymentId() {
        return paymentId;
    }

    @Override
    public String toFileString() {
        return String.format("Corporate,%s,%s,%s,%.2f,%s,%s",
                paymentId, studentId, corporateId, amount, date, status);
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatus() {
        return status;
    }
}