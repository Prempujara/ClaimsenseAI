package model;

import java.time.LocalDateTime;

/** A ClaimSense user - either an EMPLOYEE or a MANAGER. */
public class User {

    private int userId;
    private String name;
    private String email;
    private String password;      // SHA-256 hash (never plaintext)
    private String role;          // EMPLOYEE | MANAGER
    private LocalDateTime createdAt;

    public User() { }

    public User(int userId, String name, String email, String role) {
        this.userId = userId;
        this.name = name;
        this.email = email;
        this.role = role;
    }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public boolean isManager()  { return "MANAGER".equalsIgnoreCase(role); }
    public boolean isEmployee() { return "EMPLOYEE".equalsIgnoreCase(role); }

    /** Two-letter initials for the avatar chip in the UI (e.g. "Prem Pujara" -> "PP"). */
    public String getInitials() {
        if (name == null || name.isBlank()) return "?";
        String[] parts = name.trim().split("\\s+");
        String s = parts.length >= 2
                ? "" + parts[0].charAt(0) + parts[parts.length - 1].charAt(0)
                : parts[0].substring(0, Math.min(2, parts[0].length()));
        return s.toUpperCase();
    }
}
