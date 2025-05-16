package com.Util;

import com.Model.*;
import java.io.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class FileHandler {
    private static final String USER_FILE_PATH = "webapp/data/users.txt";
    private static final String INSTRUCTOR_FILE_PATH = "webapp/data/instructors.txt";
    private static final String LESSONS_FILE = "webapp/data/lessons.txt";
    private static final String PAYMENTS_FILE = "webapp/data/payments.txt";
    private static final String PROGRESS_FILE = "webapp/data/progress.txt";

    public static List<User> readAllUsersAndInstructors(String rootPath) throws IOException {
        List<User> allUsers = new ArrayList<>();
        allUsers.addAll(readUsers(rootPath)); // Students and Admins
        allUsers.addAll(readInstructors(rootPath)); // Instructors
        return allUsers;
    }

    public static List<User> readUsers(String rootPath) throws IOException {
        List<User> users = new ArrayList<>();
        File file = new File(rootPath + USER_FILE_PATH);

        // Initialize with admin user if file doesn't exist or is empty
        if (!file.exists() || file.length() == 0) {
            initializeAdminUser(rootPath);
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length >= 5) {
                    String id = parts[0];
                    String name = parts[1];
                    String email = parts[2];
                    String password = parts[3];
                    String phone = parts[4];
                    String role = parts.length > 5 ? parts[5] : "Student";
                    User user;
                    if ("Admin".equals(role)) {
                        user = new Admin(id, name, email, password, phone);
                    } else {
                        user = new Student(id, name, email, password, phone);
                        user.setRole(role); // Set role for Student (default or custom)
                    }
                    users.add(user);
                }
            }
        }
        return users;
    }

    public static void writeUsers(List<User> users, String rootPath) throws IOException {
        File file = new File(rootPath + USER_FILE_PATH);
        file.getParentFile().mkdirs();
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
            for (User user : users) {
                if (user instanceof Student || user instanceof Admin) { // Write Student and Admin objects
                    writer.write(String.format("%s,%s,%s,%s,%s,%s",
                            user.getId(),
                            user.getName() != null ? user.getName() : "",
                            user.getEmail() != null ? user.getEmail() : "",
                            user.getPassword() != null ? user.getPassword() : "",
                            user.getPhone() != null ? user.getPhone() : "",
                            user.getRole() != null ? user.getRole() : "Student"));
                    writer.newLine();
                }
            }
        }
    }

    private static void initializeAdminUser(String rootPath) throws IOException {
        File file = new File(rootPath + USER_FILE_PATH);
        List<User> users = new ArrayList<>();

        // Read existing users without calling readUsers to avoid recursion
        if (file.exists() && file.length() > 0) {
            try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    String[] parts = line.split(",");
                    if (parts.length >= 5) {
                        String id = parts[0];
                        String name = parts[1];
                        String email = parts[2];
                        String password = parts[3];
                        String phone = parts[4];
                        String role = parts.length > 5 ? parts[5] : "Student";
                        User user;
                        if ("Admin".equals(role)) {
                            user = new Admin(id, name, email, password, phone);
                        } else {
                            user = new Student(id, name, email, password, phone);
                            user.setRole(role);
                        }
                        users.add(user);
                    }
                }
            }
        }

        // Check if admin already exists
        boolean adminExists = users.stream().anyMatch(u -> "admin@drivingschool.com".equals(u.getEmail()));
        if (!adminExists) {
            User admin = new Admin("admin-001", "Admin User", "admin@drivingschool.com", "admin123", "555-123-4567");
            users.add(admin);
            writeUsers(users, rootPath);
        }
    }

    public static List<Instructor> readInstructors(String rootPath) throws IOException {
        List<Instructor> instructors = new ArrayList<>();
        File file = new File(rootPath + INSTRUCTOR_FILE_PATH);
        if (!file.exists()) return instructors;

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length >= 8) {
                    String id = parts[0];
                    String name = parts[1];
                    int experience = Integer.parseInt(parts[2]);
                    String availability = parts[3];
                    String certifications = parts[4];
                    String type = parts[5];
                    String email = parts[6];
                    String password = parts[7];
                    Instructor instructor;
                    if ("PartTime".equals(type)) {
                        instructor = new PartTimeInstructor(id, name, email, password, "", experience, availability, certifications);
                    } else {
                        instructor = new FullTimeInstructor(id, name, email, password, "", experience, availability, certifications);
                    }
                    instructor.setRole("Instructor");
                    instructors.add(instructor);
                }
            }
        }
        return instructors;
    }

    public static void writeInstructors(List<Instructor> instructors, String rootPath) throws IOException {
        File file = new File(rootPath + INSTRUCTOR_FILE_PATH);
        file.getParentFile().mkdirs();
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
            for (Instructor instructor : instructors) {
                String type = instructor instanceof PartTimeInstructor ? "PartTime" : "FullTime";
                writer.write(String.format("%s,%s,%d,%s,%s,%s,%s,%s",
                        instructor.getId(),
                        instructor.getName() != null ? instructor.getName() : "",
                        instructor.getExperience(),
                        instructor.getAvailability() != null ? instructor.getAvailability() : "",
                        instructor.getCertification() != null ? instructor.getCertification() : "",
                        type,
                        instructor.getEmail() != null ? instructor.getEmail() : "",
                        instructor.getPassword() != null ? instructor.getPassword() : ""));
                writer.newLine();
            }
        }
    }

    public static List<Instructor> sortInstructorsByExperience(List<Instructor> instructors) {
        List<Instructor> sorted = new ArrayList<>(instructors);
        sorted.sort((i1, i2) -> Integer.compare(i2.getExperience(), i1.getExperience()));
        return sorted;
    }

    public static List<Lesson> readLessons(String rootPath) throws IOException {
        List<Lesson> lessons = new ArrayList<>();
        File file = new File(rootPath + "webapp/data/lessons.txt");

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",", -1); // -1 keeps empty fields

                if (parts.length >= 8) {
                    String type = parts[0];
                    String lessonId = parts[1];
                    String studentName = parts[2];
                    String instructorName = parts[3];
                    String date = parts[4];
                    String time = parts[5];
                    String lessonType = parts[6];
                    String status = parts.length > 7 ? parts[7] : "PENDING"; // Default status

                    Lesson lesson = type.equals("BeginnerLesson")
                            ? new BeginnerLesson(lessonId, studentName, instructorName, date, time, lessonType, status)
                            : new AdvancedLesson(lessonId, studentName, instructorName, date, time, lessonType, status);

                    lessons.add(lesson);
                }
            }
        }
        return lessons;
    }

    private static Lesson createLessonFromParts(String lessonType, String[] parts) {
        String lessonId = parts[0];
        String studentName = parts[1];
        String instructorName = parts[2];
        String date = parts[3];
        String time = parts[4];
        String type = parts[5];
        String status = parts[6];

        if ("BeginnerLesson".equals(lessonType)) {
            return new BeginnerLesson(lessonId, studentName, instructorName,
                    date, time, type, status);
        } else if ("AdvancedLesson".equals(lessonType)) {
            return new AdvancedLesson(lessonId, studentName, instructorName,
                    date, time, type, status);
        }
        return null;
    }

    public static void writeLessons(List<Lesson> lessons, String rootPath) throws IOException {
        File file = new File(rootPath + LESSONS_FILE);
        file.getParentFile().mkdirs();
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
            for (Lesson lesson : lessons) {
                String lessonType = lesson instanceof BeginnerLesson ? "BeginnerLesson" : "AdvancedLesson";
                writer.write(lessonType + "," + lesson.toFileString());
                writer.newLine();
            }
        }
    }

    public static List<Payment> readPayments(String rootPath) throws IOException {
        List<Payment> payments = new ArrayList<>();
        File file = new File(rootPath + PAYMENTS_FILE);
        if (!file.exists()) return payments;

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",", 2);
                if (parts.length < 2) continue;
                String paymentType = parts[0];
                String[] paymentParts = parts[1].split(",", 6);
                if (paymentParts.length < 6) continue;

                String paymentId = paymentParts[0];
                String studentId = paymentParts[1];
                double amount = Double.parseDouble(paymentParts[2]);
                LocalDateTime paymentDate = LocalDateTime.parse(paymentParts[3]);
                String status = paymentParts[4];
                String lessonId = paymentParts[5];

                if (paymentType.equals("CardPayment")) {
                    if (paymentParts.length < 7) continue;
                    String cardNumber = paymentParts[6];
                    payments.add(new CardPayment(paymentId, studentId, amount, paymentDate, status, lessonId, cardNumber));
                } else if (paymentType.equals("CashPayment")) {
                    payments.add(new CashPayment(paymentId, studentId, amount, paymentDate, status, lessonId));
                }
            }
        }
        return payments;
    }

    public static void writePayments(List<Payment> payments, String rootPath) throws IOException {
        File file = new File(rootPath + PAYMENTS_FILE);
        file.getParentFile().mkdirs();
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
            for (Payment payment : payments) {
                writer.write(payment.toFileString());
                writer.newLine();
            }
        }
    }

    public static List<Progress> readProgress(String rootPath) throws IOException {
        List<Progress> progressList = new ArrayList<>();
        File file = new File(rootPath + PROGRESS_FILE);
        if (!file.exists()) return progressList;

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",", -1);
                if (parts.length >= 7) {
                    String progressId = parts[0];
                    String lessonId = parts[1];
                    String studentName = parts[2];
                    String instructorName = parts[3];
                    int score = Integer.parseInt(parts[4]);
                    String remarks = parts[5];
                    String date = parts[6];
                    // Determine lesson type from lessons.txt
                    List<Lesson> lessons = readLessons(rootPath);
                    Lesson lesson = lessons.stream()
                            .filter(l -> l.getLessonId().equals(lessonId))
                            .findFirst()
                            .orElse(null);
                    Progress progress = lesson instanceof BeginnerLesson
                            ? new Progress.BeginnerProgress(progressId, lessonId, studentName, instructorName, score, remarks, date)
                            : new Progress.AdvancedProgress(progressId, lessonId, studentName, instructorName, score, remarks, date);
                    progressList.add(progress);
                }
            }
        }
        return progressList;
    }

    public static void writeProgress(List<Progress> progressList, String rootPath) throws IOException {
        File file = new File(rootPath + PROGRESS_FILE);
        file.getParentFile().mkdirs();
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
            for (Progress progress : progressList) {
                writer.write(progress.toFileString());
                writer.newLine();
            }
        }
    }
}
