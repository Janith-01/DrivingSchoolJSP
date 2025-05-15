package com.Model;

public class Instructor extends User {
    private String certification;
    private String availability;
    private int experience;

    public Instructor(String id, String name, String email, String password, String phone, String certification) {
        super(id, name, email, password, phone);
        this.certification = certification;
        this.availability = "Available"; // Default value
        this.experience = 0; // Default value
    }

    public String getCertification() {
        return certification;
    }

    public void setCertification(String certification) {
        this.certification = certification;
    }

    public String getAvailability() {
        return availability;
    }

    public void setAvailability(String availability) {
        this.availability = availability;
    }

    public int getExperience() {
        return experience;
    }

    public void setExperience(int experience) {
        this.experience = experience;
    }


    @Override
    public String getRole() {
        return "Instructor";
    }

    // Add allocateLesson method for polymorphism
    public String allocateLesson() {
        return "Default lesson allocation for Instructor.";
    }
}