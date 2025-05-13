package com.Model;

public class Instructor extends User {
    private String certification;

    public Instructor(String id, String name, String email, String password, String phone, String certification) {
        super(id, name, email, password, phone);
        this.certification = certification;
    }

    public String getCertification() { return certification; }
    public void setCertification(String certification) { this.certification = certification; }

    @Override
    public String getRole() {
        return "Instructor";
    }
}