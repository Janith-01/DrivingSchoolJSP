package com.servlet;

import com.Model.*;
import com.Util.FileHandler;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@WebServlet("/payment")
public class PaymentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String rootPath = getServletContext().getRealPath("/");
        User user = (User) req.getSession().getAttribute("loggedInUser");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if ("history".equals(action)) {
            if (!(user instanceof Student)) {
                req.setAttribute("error", "Only students can view payment history");
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            String studentId = req.getParameter("studentId");
            List<Payment> allPayments = readPaymentsWithErrorHandling(rootPath, req);
            List<Payment> studentPayments = allPayments.stream()
                    .filter(payment -> payment.getStudentId().equals(studentId))
                    .collect(Collectors.toList());
            List<Lesson> allLessons = readLessonsWithErrorHandling(rootPath, req);
            double pendingDues = allLessons.stream()
                    .filter(lesson -> lesson.getStudentName().equals(user.getName()) && "ACCEPTED".equals(lesson.getStatus()))
                    .mapToDouble(lesson -> "Beginner".equals(lesson.getType()) ? 70.00 : 130.00)
                    .sum();
            req.setAttribute("payments", studentPayments);
            req.setAttribute("pendingDues", pendingDues);
            req.getRequestDispatcher("/jsp/studentPages/paymentHistory.jsp").forward(req, resp);
        } else if ("requests".equals(action)) {
            if (!(user instanceof Admin)) {
                req.setAttribute("error", "Only admins can view payment requests");
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            List<Payment> allPayments = readPaymentsWithErrorHandling(rootPath, req);
            System.out.println("All Payments: " + allPayments);
            List<Payment> pendingCashPayments = allPayments.stream()
                    .filter(payment -> {
                        boolean isCashPending = payment instanceof CashPayment &&
                                payment.getStatus() != null &&
                                "Pending".equalsIgnoreCase(payment.getStatus().trim());
                        System.out.println("Payment: " + payment + ", Is Cash Pending: " + isCashPending);
                        return isCashPending;
                    })
                    .collect(Collectors.toList());
            System.out.println("Pending Cash Payments: " + pendingCashPayments);
            req.setAttribute("pendingPayments", pendingCashPayments);
            req.getRequestDispatcher("/jsp/adminpages/paymentReq.jsp").forward(req, resp);
        } else if ("generateInvoice".equals(action)) {
            if (!(user instanceof Student)) {
                req.setAttribute("error", "Only students can generate invoices");
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            String paymentId = req.getParameter("paymentId");
            List<Payment> allPayments = readPaymentsWithErrorHandling(rootPath, req);
            Payment payment = allPayments.stream()
                    .filter(p -> p.getPaymentId().equals(paymentId) && p.getStudentId().equals(user.getId()))
                    .findFirst()
                    .orElse(null);
            if (payment == null) {
                req.setAttribute("error", "Payment not found or you do not have access to this payment.");
                resp.sendRedirect(req.getContextPath() + "/payment?action=history&studentId=" + user.getId());
                return;
            }
            List<Invoice> allInvoices = readInvoicesWithErrorHandling(rootPath, req);
            Invoice invoice = allInvoices.stream()
                    .filter(i -> i.getPaymentId().equals(paymentId))
                    .findFirst()
                    .orElse(null);
            if (invoice == null) {
                req.setAttribute("error", "Invoice not found for this payment.");
                resp.sendRedirect(req.getContextPath() + "/payment?action=history&studentId=" + user.getId());
                return;
            }
            req.setAttribute("invoice", invoice);
            req.setAttribute("payment", payment);
            req.getRequestDispatcher("/jsp/studentPages/InvoiceGeneration.jsp").forward(req, resp);
        } else {
            if (!(user instanceof Student)) {
                req.setAttribute("error", "Only students can make payments");
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            List<Lesson> allLessons = readLessonsWithErrorHandling(rootPath, req);
            List<Lesson> acceptedLessons = allLessons.stream()
                    .filter(lesson -> lesson.getStudentName().equals(user.getName()) && "ACCEPTED".equals(lesson.getStatus()))
                    .collect(Collectors.toList());
            req.setAttribute("lessons", acceptedLessons);
            req.getRequestDispatcher("/jsp/studentPages/paymentProcessing.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String rootPath = getServletContext().getRealPath("/");
        User user = (User) req.getSession().getAttribute("loggedInUser");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if ("process".equals(action)) {
            if (!(user instanceof Student)) {
                req.setAttribute("error", "Only students can make payments");
                req.getRequestDispatcher("/jsp/studentPages/paymentProcessing.jsp").forward(req, resp);
                return;
            }

            String studentId = req.getParameter("studentId");
            String lessonId = req.getParameter("lessonId");
            double amount;
            try {
                amount = Double.parseDouble(req.getParameter("amount"));
            } catch (NumberFormatException e) {
                req.setAttribute("error", "Invalid amount format");
                req.getRequestDispatcher("/jsp/studentPages/paymentProcessing.jsp").forward(req, resp);
                return;
            }
            String paymentType = req.getParameter("paymentType");
            String isCorporate = req.getParameter("isCorporate");

            // Validate inputs
            if (studentId == null || lessonId == null || amount <= 0 || paymentType == null) {
                req.setAttribute("error", "All fields are required, and amount must be positive.");
                req.getRequestDispatcher("/jsp/studentPages/paymentProcessing.jsp").forward(req, resp);
                return;
            }

            // Create new payment
            String paymentId = UUID.randomUUID().toString();
            LocalDateTime paymentDate = LocalDateTime.now();
            String status = paymentType.equals("Card") ? "Completed" : "Pending";
            Payment payment;

            if ("Card".equals(paymentType)) {
                String cardNumber = req.getParameter("cardNumber").replaceAll("\\s", "");
                if (cardNumber == null || !cardNumber.matches("\\d{16}")) {
                    req.setAttribute("error", "Valid 16-digit card number is required for card payments.");
                    req.getRequestDispatcher("/jsp/studentPages/paymentProcessing.jsp").forward(req, resp);
                    return;
                }
                payment = new CardPayment(paymentId, studentId, amount, paymentDate, status, lessonId, cardNumber);
            } else {
                payment = new CashPayment(paymentId, studentId, amount, paymentDate, status, lessonId);
            }

            // Save payment
            List<Payment> allPayments = readPaymentsWithErrorHandling(rootPath, req);
            allPayments.add(payment);
            try {
                FileHandler.writePayments(allPayments, rootPath);
            } catch (IOException e) {
                req.setAttribute("error", "Unable to save payment due to a server error.");
                req.getRequestDispatcher("/jsp/studentPages/paymentProcessing.jsp").forward(req, resp);
                return;
            }

            // Generate and save invoice
            Invoice invoice;
            if ("true".equalsIgnoreCase(isCorporate)) {
                String corporateId = req.getParameter("corporateId");
                if (corporateId == null || corporateId.trim().isEmpty()) {
                    req.setAttribute("error", "Corporate ID is required for corporate invoices.");
                    req.getRequestDispatcher("/jsp/studentPages/paymentProcessing.jsp").forward(req, resp);
                    return;
                }
                invoice = new CorporateInvoice(studentId, paymentId, amount, paymentDate, corporateId);
            } else {
                invoice = new StudentInvoice(studentId, paymentId, amount, paymentDate);
            }
            List<Invoice> allInvoices = readInvoicesWithErrorHandling(rootPath, req);
            allInvoices.add(invoice);
            try {
                FileHandler.writeInvoices(allInvoices, rootPath);
            } catch (IOException e) {
                req.setAttribute("error", "Unable to save invoice due to a server error.");
                req.getRequestDispatcher("/jsp/studentPages/paymentProcessing.jsp").forward(req, resp);
                return;
            }

            // Update lesson status to "PAID" only for card payments
            if ("Card".equals(paymentType)) {
                List<Lesson> allLessons = readLessonsWithErrorHandling(rootPath, req);
                allLessons.stream()
                        .filter(lesson -> lesson.getLessonId().equals(lessonId))
                        .findFirst()
                        .ifPresent(lesson -> lesson.setStatus("PAID"));
                try {
                    FileHandler.writeLessons(allLessons, rootPath);
                } catch (IOException e) {
                    req.setAttribute("error", "Unable to update lesson status due to a server error.");
                    req.getRequestDispatcher("/jsp/studentPages/paymentProcessing.jsp").forward(req, resp);
                    return;
                }
            }

            resp.sendRedirect(req.getContextPath() + "/payment?action=history&studentId=" + studentId);
        } else if ("updateStatus".equals(action)) {
            if (!(user instanceof Admin)) {
                req.setAttribute("error", "Only admins can update payment status");
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }

            String paymentId = req.getParameter("paymentId");
            String newStatus = req.getParameter("status");
            if (!newStatus.equals("Completed") && !newStatus.equals("Denied")) {
                req.setAttribute("error", "Invalid status");
                resp.sendRedirect(req.getContextPath() + "/payment?action=requests");
                return;
            }

            // Update payment status
            List<Payment> allPayments = readPaymentsWithErrorHandling(rootPath, req);
            Payment updatedPayment = allPayments.stream()
                    .filter(payment -> payment.getPaymentId().equals(paymentId))
                    .findFirst()
                    .orElse(null);

            if (updatedPayment == null) {
                req.setAttribute("error", "Payment not found.");
                resp.sendRedirect(req.getContextPath() + "/payment?action=requests");
                return;
            }

            updatedPayment.setStatus(newStatus);

            try {
                FileHandler.writePayments(allPayments, rootPath);
            } catch (IOException e) {
                req.setAttribute("error", "Unable to save payment status due to a server error.");
                resp.sendRedirect(req.getContextPath() + "/payment?action=requests");
                return;
            }

            // Update lesson status to "PAID" if payment is approved
            if ("Completed".equals(newStatus)) {
                List<Lesson> allLessons = readLessonsWithErrorHandling(rootPath, req);
                allLessons.stream()
                        .filter(lesson -> lesson.getLessonId().equals(updatedPayment.getLessonId()))
                        .findFirst()
                        .ifPresent(lesson -> lesson.setStatus("PAID"));
                try {
                    FileHandler.writeLessons(allLessons, rootPath);
                } catch (IOException e) {
                    req.setAttribute("error", "Unable to update lesson status due to a server error.");
                    resp.sendRedirect(req.getContextPath() + "/payment?action=requests");
                    return;
                }
            }

            // Update invoice status
            List<Invoice> allInvoices = readInvoicesWithErrorHandling(rootPath, req);
            boolean invoiceFound = allInvoices.stream()
                    .filter(invoice -> invoice.getPaymentId().equals(paymentId))
                    .findFirst()
                    .map(invoice -> {
                        if (invoice instanceof CorporateInvoice) {
                            ((CorporateInvoice) invoice).setStatus(newStatus);
                        } else if (invoice instanceof StudentInvoice) {
                            ((StudentInvoice) invoice).setStatus(newStatus);
                        }
                        return true;
                    })
                    .orElse(false);

            if (!invoiceFound) {
                req.setAttribute("error", "Invoice not found.");
                resp.sendRedirect(req.getContextPath() + "/payment?action=requests");
                return;
            }

            try {
                FileHandler.writeInvoices(allInvoices, rootPath);
            } catch (IOException e) {
                req.setAttribute("error", "Unable to update invoice status due to a server error.");
                resp.sendRedirect(req.getContextPath() + "/payment?action=requests");
                return;
            }

            resp.sendRedirect(req.getContextPath() + "/payment?action=requests");
        } else if ("delete".equals(action)) {
            if (!(user instanceof Admin)) {
                req.setAttribute("error", "Only admins can delete payments");
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }

            String paymentId = req.getParameter("paymentId");
            List<Payment> allPayments = readPaymentsWithErrorHandling(rootPath, req);
            allPayments.removeIf(payment -> payment.getPaymentId().equals(paymentId));
            try {
                FileHandler.writePayments(allPayments, rootPath);
            } catch (IOException e) {
                req.setAttribute("error", "Unable to delete payment due to a server error.");
                resp.sendRedirect(req.getContextPath() + "/payment?action=requests");
                return;
            }

            List<Invoice> allInvoices = readInvoicesWithErrorHandling(rootPath, req);
            allInvoices.removeIf(invoice -> invoice.getPaymentId().equals(paymentId));
            try {
                FileHandler.writeInvoices(allInvoices, rootPath);
            } catch (IOException e) {
                req.setAttribute("error", "Unable to delete invoice due to a server error.");
                resp.sendRedirect(req.getContextPath() + "/payment?action=requests");
                return;
            }

            resp.sendRedirect(req.getContextPath() + "/payment?action=requests");
        }
    }

    private List<Payment> readPaymentsWithErrorHandling(String rootPath, HttpServletRequest req) {
        try {
            Path paymentsFile = Paths.get(rootPath, "webapp/data/payments.txt");
            if (!Files.exists(paymentsFile)) {
                Files.createDirectories(paymentsFile.getParent());
                Files.createFile(paymentsFile);
                req.setAttribute("warning", "Payments file was created as it was missing.");
            }
            return FileHandler.readPayments(rootPath);
        } catch (IOException e) {
            req.setAttribute("error", "Unable to read payments due to a server error: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    private List<Invoice> readInvoicesWithErrorHandling(String rootPath, HttpServletRequest req) {
        try {
            Path invoicesFile = Paths.get(rootPath, "webapp/data/invoices.txt");
            if (!Files.exists(invoicesFile)) {
                Files.createDirectories(invoicesFile.getParent());
                Files.createFile(invoicesFile);
                req.setAttribute("warning", "Invoices file was created as it was missing.");
            }
            return FileHandler.readInvoices(rootPath);
        } catch (IOException e) {
            req.setAttribute("error", "Unable to read invoices due to a server error: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    private List<Lesson> readLessonsWithErrorHandling(String rootPath, HttpServletRequest req) {
        try {
            Path lessonsFile = Paths.get(rootPath, "webapp/data/lessons.txt");
            if (!Files.exists(lessonsFile)) {
                Files.createDirectories(lessonsFile.getParent());
                Files.createFile(lessonsFile);
                req.setAttribute("warning", "Lessons file was created as it was missing.");
            }
            return FileHandler.readLessons(rootPath);
        } catch (IOException e) {
            req.setAttribute("error", "Unable to read lessons due to a server error: " + e.getMessage());
            return new ArrayList<>();
        }
    }
}