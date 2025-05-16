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
import java.util.*;
import java.util.stream.Collectors;

@WebServlet("/review")
public class ReviewServlet extends HttpServlet {

    private static final Set<String> VALID_STATUSES = Set.of("Pending", "Approved", "Removed");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String rootPath = getServletContext().getRealPath("/");
        System.out.println("Root path: " + rootPath);

        User user = (User) req.getSession().getAttribute("loggedInUser");
        if (user == null) {
            System.out.println("No user in session, redirecting to login");
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        System.out.println("Logged-in user: " + user.getName() + ", Role: " + user.getRole());

        String action = req.getParameter("action");
        System.out.println("Action: " + action);

        if ("submit".equals(action)) {
            System.out.println("Forwarding to FeedbackSubmission.jsp");
            req.getRequestDispatcher("/jsp/studentPages/FeedbackSubmission.jsp").forward(req, resp);
        } else if ("view".equals(action)) {
            String targetId = req.getParameter("targetId");
            String type = req.getParameter("type");
            System.out.println("Viewing reviews for targetId: " + targetId + ", type: " + type);

            if (type != null && !type.equals("lesson") && !type.equals("instructor")) {
                System.out.println("Invalid type parameter: " + type);
                req.setAttribute("error", "Invalid review type");
                req.getRequestDispatcher("/jsp/studentPages/ViewReviews.jsp").forward(req, resp);
                return;
            }

            try {
                List<Review> reviews = FileHandler.readReviews(rootPath);
                System.out.println("Total reviews read: " + reviews.size());

                List<Review> filteredReviews;
                if (reviews.isEmpty()) {
                    System.out.println("No reviews found in reviews.txt");
                    filteredReviews = Collections.emptyList();
                } else if (targetId != null && type != null) {
                    filteredReviews = reviews.stream()
                            .filter(r -> r.getTargetId().equals(targetId) &&
                                    (("lesson".equals(type) && r instanceof LessonReview) ||
                                            ("instructor".equals(type) && r instanceof InstructorReview)) &&
                                    "Approved".equals(r.getStatus()))
                            .collect(Collectors.toList());
                    System.out.println("Filtered reviews: " + filteredReviews.size());
                } else {
                    filteredReviews = reviews.stream()
                            .filter(r -> "Approved".equals(r.getStatus()))
                            .collect(Collectors.toList());
                    System.out.println("All approved reviews: " + filteredReviews.size());
                }

                req.setAttribute("reviews", filteredReviews);
                req.setAttribute("targetId", targetId);
                req.setAttribute("type", type);
            } catch (Exception e) {
                System.out.println("Error fetching reviews: " + e.getMessage());
                e.printStackTrace();
                req.setAttribute("error", "Failed to fetch reviews: " + e.getMessage());
            }

            req.getRequestDispatcher("/jsp/studentPages/ViewReviews.jsp").forward(req, resp);
        } else if ("getAllReviews".equals(action)) {
            try {
                List<Review> allReviews = FileHandler.readReviews(rootPath);
                System.out.println("Total reviews fetched: " + allReviews.size());

                List<Review> approvedReviews = allReviews.isEmpty() ? Collections.emptyList() :
                        allReviews.stream()
                                .filter(r -> "Approved".equals(r.getStatus()))
                                .collect(Collectors.toList());
                System.out.println("Approved reviews: " + approvedReviews.size());

                req.setAttribute("reviews", approvedReviews);
                req.getRequestDispatcher("/jsp/studentPages/ViewReviews.jsp").forward(req, resp);
            } catch (Exception e) {
                System.out.println("Error fetching all reviews: " + e.getMessage());
                e.printStackTrace();
                req.setAttribute("error", "Failed to fetch reviews: " + e.getMessage());
                req.getRequestDispatcher("/jsp/studentPages/ViewReviews.jsp").forward(req, resp);
            }
        } else if ("moderate".equals(action)) {
            if (!(user instanceof Admin)) {
                System.out.println("User is not an admin, redirecting to login");
                req.setAttribute("error", "Only admins can moderate reviews");
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            try {
                List<Review> reviews = FileHandler.readReviews(rootPath);
                System.out.println("Total reviews for moderation: " + reviews.size());
                req.setAttribute("reviews", reviews);
            } catch (Exception e) {
                System.out.println("Error fetching reviews for moderation: " + e.getMessage());
                e.printStackTrace();
                req.setAttribute("error", "Failed to fetch reviews: " + e.getMessage());
            }
            req.getRequestDispatcher("/jsp/adminpages/ReviewModeration.jsp").forward(req, resp);
        } else if ("fetchLessons".equals(action)) {
            if (!(user instanceof Student)) {
                System.out.println("User is not a student, sending 403");
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Only students can fetch lessons");
                return;
            }
            try {
                List<Lesson> lessons = FileHandler.readLessons(rootPath);
                System.out.println("Total lessons read: " + lessons.size());

                List<Lesson> studentLessons = lessons.stream()
                        .filter(lesson -> lesson.getStudentName() != null &&
                                lesson.getStudentName().equals(user.getName()))
                        .collect(Collectors.toList());

                System.out.println("Lessons for student " + user.getName() + ": " + studentLessons.size());

                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");

                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < studentLessons.size(); i++) {
                    Lesson lesson = studentLessons.get(i);
                    if (i > 0) json.append(",");
                    json.append("{")
                            .append("\"lessonId\":\"").append(escapeJson(lesson.getLessonId())).append("\",")
                            .append("\"studentName\":\"").append(escapeJson(lesson.getStudentName())).append("\",")
                            .append("\"instructorName\":\"").append(escapeJson(lesson.getInstructorName())).append("\",")
                            .append("\"date\":\"").append(escapeJson(lesson.getDate())).append("\",")
                            .append("\"time\":\"").append(escapeJson(lesson.getTime())).append("\",")
                            .append("\"status\":\"").append(escapeJson(lesson.getStatus())).append("\"")
                            .append("}");
                }
                json.append("]");

                System.out.println("Sending lessons JSON: " + json.toString());
                resp.getWriter().write(json.toString());
            } catch (Exception e) {
                System.out.println("Error fetching lessons: " + e.getMessage());
                e.printStackTrace();
                sendErrorResponse(resp, "Failed to fetch lessons: " + e.getMessage());
            }
        } else if ("fetchInstructors".equals(action)) {
            if (!(user instanceof Student)) {
                System.out.println("User is not a student, sending 403");
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Only students can fetch instructors");
                return;
            }
            try {
                List<Lesson> lessons = FileHandler.readLessons(rootPath);
                System.out.println("Total lessons read for instructors: " + lessons.size());

                Map<String, String> instructorMap = new HashMap<>();
                lessons.stream()
                        .filter(lesson -> lesson.getStudentName() != null &&
                                lesson.getStudentName().equals(user.getName()) &&
                                lesson.getInstructorName() != null)
                        .forEach(lesson -> instructorMap.put(lesson.getInstructorName(), lesson.getInstructorName()));

                System.out.println("Found " + instructorMap.size() + " unique instructors for student " + user.getName());

                StringBuilder json = new StringBuilder("[");
                int i = 0;
                for (Map.Entry<String, String> entry : instructorMap.entrySet()) {
                    if (i > 0) json.append(",");
                    json.append("{")
                            .append("\"id\":\"").append(escapeJson(entry.getKey())).append("\",")
                            .append("\"name\":\"").append(escapeJson(entry.getValue())).append("\"")
                            .append("}");
                    i++;
                }
                json.append("]");

                System.out.println("Sending instructors JSON: " + json.toString());

                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write(json.toString());
            } catch (Exception e) {
                System.out.println("Error fetching instructors: " + e.getMessage());
                e.printStackTrace();
                sendErrorResponse(resp, "Failed to fetch instructors: " + e.getMessage());
            }
        } else {
            System.out.println("Invalid action: " + action);
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String rootPath = getServletContext().getRealPath("/");
        User user = (User) req.getSession().getAttribute("loggedInUser");

        System.out.println("User: " + (user != null ? user.getId() + ", Role: " + user.getClass().getSimpleName() : "Not logged in"));

        if (user == null) {
            req.setAttribute("error", "User not logged in.");
            req.getRequestDispatcher("/jsp/studentPages/FeedbackSubmission.jsp").forward(req, resp);
            return;
        }

        String action = req.getParameter("action");
        if ("create".equals(action)) {
            try {
                String targetId = req.getParameter("targetId");
                String feedback = req.getParameter("feedback");
                String ratingStr = req.getParameter("rating");
                String type = req.getParameter("type");
                System.out.println("Received - targetId: " + targetId + ", type: " + type + ", feedback: " + feedback + ", rating: " + ratingStr);

                if (targetId == null || feedback == null || ratingStr == null || type == null) {
                    req.setAttribute("error", "Missing required fields.");
                    req.getRequestDispatcher("/jsp/studentPages/FeedbackSubmission.jsp").forward(req, resp);
                    return;
                }

                int rating = Integer.parseInt(ratingStr);
                if (rating < 1 || rating > 5) {
                    req.setAttribute("error", "Rating must be between 1 and 5.");
                    req.getRequestDispatcher("/jsp/studentPages/FeedbackSubmission.jsp").forward(req, resp);
                    return;
                }

                String reviewId = UUID.randomUUID().toString();
                String studentId = user.getId();

                Review review = "lesson".equals(type)
                        ? new LessonReview(reviewId, studentId, targetId, feedback, rating, LocalDateTime.now(), "Pending")
                        : new InstructorReview(reviewId, studentId, targetId, feedback, rating, LocalDateTime.now(), "Pending");

                List<Review> existingReviews = FileHandler.readReviews(rootPath);
                existingReviews.add(review);
                FileHandler.writeReviews(existingReviews, rootPath);

                req.getSession().setAttribute("successMessage", "Feedback submitted successfully.");
                req.getSession().setAttribute("redirectType", type);
                req.getSession().setAttribute("redirectTargetId", targetId);

                resp.sendRedirect(req.getContextPath() + "/review?action=submit");
            } catch (NumberFormatException e) {
                req.setAttribute("error", "Invalid rating format.");
                req.getRequestDispatcher("/jsp/studentPages/FeedbackSubmission.jsp").forward(req, resp);
            } catch (Exception e) {
                req.setAttribute("error", "Error: " + e.getMessage());
                req.getRequestDispatcher("/jsp/studentPages/FeedbackSubmission.jsp").forward(req, resp);
            }
        } else if ("updateStatus".equals(action)) {
            if (!(user instanceof Admin)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Only admins can update review status");
                return;
            }

            String reviewId = req.getParameter("reviewId");
            String status = req.getParameter("status");

            if (reviewId == null || status == null) {
                req.setAttribute("error", "Missing reviewId or status parameter");
                req.getRequestDispatcher("/jsp/adminpages/ReviewModeration.jsp").forward(req, resp);
                return;
            }

            try {
                List<Review> reviews = FileHandler.readReviews(rootPath);
                boolean updated = false;

                for (Review review : reviews) {
                    if (review.getReviewId().equals(reviewId)) {
                        review.setStatus(status);
                        updated = true;
                        break;
                    }
                }

                if (updated) {
                    FileHandler.writeReviews(reviews, rootPath);
                    req.getSession().setAttribute("successMessage", "Review status updated successfully.");
                    resp.sendRedirect(req.getContextPath() + "/review?action=moderate");
                } else {
                    req.setAttribute("error", "Review not found");
                    req.getRequestDispatcher("/jsp/adminpages/ReviewModeration.jsp").forward(req, resp);
                }
            } catch (Exception e) {
                System.out.println("Error updating review: " + e.getMessage());
                e.printStackTrace();
                req.setAttribute("error", "Error updating review: " + e.getMessage());
                req.getRequestDispatcher("/jsp/adminpages/ReviewModeration.jsp").forward(req, resp);
            }
        } else if ("delete".equals(action)) {
            if (!(user instanceof Admin)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Only admins can delete reviews");
                return;
            }

            String reviewId = req.getParameter("reviewId");
            if (reviewId == null) {
                req.setAttribute("error", "Missing reviewId parameter");
                req.getRequestDispatcher("/jsp/adminpages/ReviewModeration.jsp").forward(req, resp);
                return;
            }

            try {
                List<Review> reviews = FileHandler.readReviews(rootPath);
                boolean deleted = reviews.removeIf(review -> review.getReviewId().equals(reviewId));
                if (deleted) {
                    FileHandler.writeReviews(reviews, rootPath);
                    req.getSession().setAttribute("successMessage", "Review deleted successfully.");
                    resp.sendRedirect(req.getContextPath() + "/review?action=moderate");
                } else {
                    req.setAttribute("error", "Review not found");
                    req.getRequestDispatcher("/jsp/adminpages/ReviewModeration.jsp").forward(req, resp);
                }
            } catch (Exception e) {
                System.out.println("Error deleting review: " + e.getMessage());
                e.printStackTrace();
                req.setAttribute("error", "Error deleting review: " + e.getMessage());
                req.getRequestDispatcher("/jsp/adminpages/ReviewModeration.jsp").forward(req, resp);
            }
        } else {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }

    private void sendErrorResponse(HttpServletResponse resp, String errorMessage) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        resp.getWriter().write("{\"status\":\"error\",\"message\":\"" + escapeJson(errorMessage) + "\"}");
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\"", "\\\"")
                .replace("\\", "\\\\")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
