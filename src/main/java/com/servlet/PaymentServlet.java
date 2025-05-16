package com.servlet;

import com.Model.*;
import com.Util.FileHandler;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@WebServlet("/payment")
public class PaymentServlet extends HttpServlet {
    private List<Payment> payments;

    @Override
    public void init() throws ServletException {
        try {
            String rootPath = getServletContext().getRealPath("/");
            payments = FileHandler.readPayments(rootPath);
            System.out.println("Initialized payment list with " + payments.size() + " payments.");
        } catch (IOException e) {
            System.err.println("Error initializing payments: " + e.getMessage());
            payments = new ArrayList<>();
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String rootPath = getServletContext().getRealPath("/");
        User user = (User) req.getSession().getAttribute("loggedInUser");
        if (user == null || !(user instanceof Student)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if ("history".equals(action)) {
            // Fetch payment history for the logged-in student
            String studentId = req.getParameter("studentId");
            List<Payment> allPayments = FileHandler.readPayments(rootPath);
            List<Payment> studentPayments = allPayments.stream()
                    .filter(payment -> payment.getStudentId().equals(studentId))
                    .collect(Collectors.toList());
            req.setAttribute("payments", studentPayments);
            req.getRequestDispatcher("/jsp/studentPages/paymentHistory.jsp").forward(req, resp);
        } else {
            // Default to payment form (fetch accepted lessons)
            List<Lesson> allLessons = FileHandler.readLessons(rootPath);
            List<Lesson> acceptedLessons = allLessons.stream()
                    .filter(lesson -> lesson.getStudentName().equals(user.getName()) && "ACCEPTED".equals(lesson.getStatus()))
                    .collect(Collectors.toList());
            req.setAttribute("lessons", acceptedLessons);
            req.getRequestDispatcher("/jsp/studentPages/paymentForm.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String rootPath = getServletContext().getRealPath("/");

        if ("process".equals(action)) {
            String studentId = req.getParameter("studentId");
            String lessonId = req.getParameter("lessonId");
            double amount = Double.parseDouble(req.getParameter("amount"));
            String paymentType = req.getParameter("paymentType");
            String cardNumber = req.getParameter("cardNumber");

            // Validate inputs
            if (studentId == null || lessonId == null || amount <= 0 || paymentType == null) {
                req.setAttribute("error", "All fields are required, and amount must be positive.");
                req.getRequestDispatcher("/jsp/studentPages/paymentForm.jsp").forward(req, resp);
                return;
            }

            // Create payment
            String paymentId = UUID.randomUUID().toString();
            Payment payment;
            if ("Card".equals(paymentType)) {
                if (cardNumber == null || !cardNumber.matches("\\d{4}")) {
                    req.setAttribute("error", "Valid card number (last 4 digits) is required for card payments.");
                    req.getRequestDispatcher("/jsp/studentPages/paymentForm.jsp").forward(req, resp);
                    return;
                }
                payment = new CardPayment(paymentId, studentId, amount, LocalDateTime.now(), "Pending", lessonId, cardNumber);
            } else {
                payment = new CashPayment(paymentId, studentId, amount, LocalDateTime.now(), "Pending", lessonId);
            }

            // Process payment
            if (payment.processPayment()) {
                payment.setStatus("Completed");
            } else {
                payment.setStatus("Failed");
            }

            payments.add(payment);
            FileHandler.writePayments(payments, rootPath);

            // Generate invoice
            Invoice invoice = new StudentInvoice(studentId, paymentId, amount, payment.getPaymentDate());
            req.setAttribute("invoice", invoice.generateInvoice());
            req.getRequestDispatcher("/jsp/studentPages/invoice.jsp").forward(req, resp);
        }
    }
}