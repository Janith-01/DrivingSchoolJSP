package com.Model;

public interface Invoice {
    String generateInvoice();
    String getPaymentId();
    String toFileString();
}