package com.Model;

import java.time.LocalDateTime;

public class CorporateInvoice implements Invoice {
    private String studentId;
    private String paymentId;
    private double amount;
    private LocalDateTime date;
    private String corporateId;

    public CorporateInvoice(String studentId, String paymentId, double amount, LocalDateTime date, String corporateId) {
        this.studentId = studentId;
        this.paymentId = paymentId;
        this.amount = amount;
        this.date = date;
        this.corporateId = corporateId;
    }

    @Override
    public String generateInvoice() {
        return String.format("Corporate Invoice\nPayment ID: %s\nStudent ID: %s\nCorporate ID: %s\nAmount: $%.2f\nDate: %s",
                paymentId, studentId, corporateId, amount, date);
    }
}