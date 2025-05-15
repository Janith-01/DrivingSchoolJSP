package com.Model;

public class Admin extends User {
    public Admin(String id, String name, String email, String password, String phone) {
        super(id, name, email, password, phone);
        setRole("Admin"); // Set role to Admin by default
    }
}