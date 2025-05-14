package com.Util;

import com.Model.*;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class FileHandler {
    private static final String FILE_PATH = "webapp/data/users.txt";
    private static final String LESSONS_FILE = "webapp/data/lessons.txt";

    public static List<User> readUsers(String rootPath) throws IOException {
        List<User> users = new ArrayList<>();
        File file = new File(rootPath + FILE_PATH);
        if (!file.exists()) return users;

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length >= 6) {
                    String id = parts[0];
                    String role = parts[1];
                    String name = parts[2];
                    String email = parts[3];
                    String password = parts[4];
                    String phone = parts[5];
                    if (role.equals("Student")) {
                        users.add(new Student(id, name, email, password, phone));
                    } else if (role.equals("Instructor")) {
                        String certification = parts[6];
                        users.add(new Instructor(id, name, email, password, phone, certification));
                    }
                }
            }
        }
        return users;
    }

    public static void writeUsers(List<User> users, String rootPath) throws IOException {
        File file = new File(rootPath + FILE_PATH);
        file.getParentFile().mkdirs();
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
            for (User user : users) {
                writer.write(user.getId() + "," + user.getRole() + "," + user.getName() + "," +
                        user.getEmail() + "," + user.getPassword() + "," + user.getPhone());
                if (user instanceof Instructor) {
                    writer.write("," + ((Instructor) user).getCertification());
                }
                writer.newLine();
            }
        }
    }

    public static List<Lesson> readLessons(String rootPath) throws IOException {
        List<Lesson> lessons = new ArrayList<>();
        File file = new File(rootPath + LESSONS_FILE);
        System.out.println("Attempting to read lessons from: " + file.getAbsolutePath());
        if (!file.exists()) {
            System.out.println("Lessons file does not exist at: " + file.getAbsolutePath());
            return lessons;
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                System.out.println("Processing line: " + line);
                String[] parts = line.split(",", 2); // Split into type and the rest
                if (parts.length < 2) {
                    System.out.println("Skipping malformed line: " + line);
                    continue;
                }
                String lessonType = parts[0];
                String[] lessonParts = parts[1].split(",", 6);
                if (lessonParts.length < 6) {
                    System.out.println("Skipping malformed lesson data: " + parts[1]);
                    continue;
                }
                String lessonId = lessonParts[0];
                String studentName = lessonParts[1];
                String instructorName = lessonParts[2];
                String date = lessonParts[3];
                String time = lessonParts[4];
                String type = lessonParts[5];

                if (lessonType.equals("BeginnerLesson")) {
                    lessons.add(new BeginnerLesson(lessonId, studentName, instructorName, date, time, type));
                } else if (lessonType.equals("AdvancedLesson")) {
                    lessons.add(new AdvancedLesson(lessonId, studentName, instructorName, date, time, type));
                } else {
                    System.out.println("Unknown lesson type: " + lessonType);
                }
            }
            System.out.println("Successfully read " + lessons.size() + " lessons from file.");
        } catch (IOException e) {
            System.err.println("Error reading lessons: " + e.getMessage());
        }
        return lessons;
    }

    public static void writeLessons(List<Lesson> lessons, String rootPath) throws IOException {
        File file = new File(rootPath + LESSONS_FILE);
        file.getParentFile().mkdirs();
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
            for (Lesson lesson : lessons) {
                String lessonType = (lesson instanceof BeginnerLesson) ? "BeginnerLesson" :
                        (lesson instanceof AdvancedLesson) ? "AdvancedLesson" : "Lesson";
                writer.write(lessonType + "," + lesson.toFileString());
                writer.newLine();
            }
            System.out.println("Wrote " + lessons.size() + " lessons to file.");
        }
    }
}