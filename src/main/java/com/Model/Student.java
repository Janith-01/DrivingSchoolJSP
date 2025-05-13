package com.Model;

public class Student extends User {
    public Student(String id, String name, String email, String password, String phone) {
        super(id, name, email, password, phone);
    }

    @Override
    public String getRole() {
        return "Student";
    }
}