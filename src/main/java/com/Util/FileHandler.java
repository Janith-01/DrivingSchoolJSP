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
        if (!file.exists()) return lessons;

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",", 2); // Split into type and the rest
                if (parts.length < 2) continue; // Skip malformed lines
                String lessonType = parts[0];
                Lesson lesson = Lesson.fromFileString(parts[1]);
                if (lessonType.equals("BeginnerLesson")) {
                    lessons.add(new BeginnerLesson(
                            lesson.getLessonId(),
                            lesson.getStudentId(),
                            lesson.getInstructorId(),
                            lesson.getDate(),
                            lesson.getTime(),
                            lesson.getType()
                    ));
                } else if (lessonType.equals("AdvancedLesson")) {
                    lessons.add(new AdvancedLesson(
                            lesson.getLessonId(),
                            lesson.getStudentId(),
                            lesson.getInstructorId(),
                            lesson.getDate(),
                            lesson.getTime(),
                            lesson.getType()
                    ));
                } else {
                    lessons.add(lesson); // Fallback to base Lesson if type is unknown
                }
            }
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
        }
    }
}

