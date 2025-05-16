package com.Model;

import java.time.LocalDateTime;

public class InvoiceImpl implements Invoice {
    private String invoiceId;
    private String paymentId;
    private String studentId;
    private double amount;
    private LocalDateTime invoiceDate;
    private String status;

    // Constructor for creating a new invoice
    public InvoiceImpl(String invoiceId, String paymentId, String studentId, double amount, LocalDateTime invoiceDate, String status) {
        this.invoiceId = invoiceId;
        this.paymentId = paymentId;
        this.studentId = studentId;
        this.amount = amount;
        this.invoiceDate = invoiceDate;
        this.status = status;
    }

    // Constructor for parsing from file
    public InvoiceImpl(String fileLine) {
        String[] parts = fileLine.split(",");
        if (parts.length >= 7 && "Invoice".equals(parts[0])) {
            this.invoiceId = parts[1];
            this.paymentId = parts[2];
            this.studentId = parts[3];
            this.amount = Double.parseDouble(parts[4]);
            this.invoiceDate = LocalDateTime.parse(parts[5]);
            this.status = parts[6];
        } else {
            throw new IllegalArgumentException("Invalid invoice format: " + fileLine);
        }
    }

    @Override
    public String generateInvoice() {
        return String.format("Invoice\nInvoice ID: %s\nPayment ID: %s\nStudent ID: %s\nAmount: $%.2f\nDate: %s\nStatus: %s",
                invoiceId, paymentId, studentId, amount, invoiceDate, status);
    }

    @Override
    public String getPaymentId() {
        return paymentId;
    }

    @Override
    public String toFileString() {
        return String.format("Invoice,%s,%s,%s,%.2f,%s,%s",
                invoiceId, paymentId, studentId, amount, invoiceDate, status);
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatus() {
        return status;
    }
}