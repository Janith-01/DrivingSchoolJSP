package com.Model;

public class PartTimeInstructor extends Instructor {
    public PartTimeInstructor(String id, String name, String email, String password, String phone, int experience, String availability, String certification) {
        super(id, name, email, password, phone, certification);
        setExperience(experience);
        setAvailability(availability);
    }

    @Override
    public String allocateLesson() {
        return "Allocated lesson for PartTime Instructor: Limited hours based on availability.";
    }
}