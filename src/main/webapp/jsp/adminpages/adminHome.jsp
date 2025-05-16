<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.Instructor" %>
<%@ page import="com.Model.Lesson" %>
<%@ page import="com.Model.Progress" %>
<%@ page import="com.Util.FileHandler" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard</title>
    <!-- Tailwind CSS CDN for styling -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Lucide Icons (client-side rendering via script) -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            lucide.createIcons();
        });
    </script>
</head>
<body class="bg-gray-50 min-h-screen">
    <%
        // Check logged-in user
        User user = (User) session.getAttribute("loggedInUser");
        if (user == null || !"Admin".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String rootPath = getServletContext().getRealPath("/");

        // Fetch data
        List<User> users = FileHandler.readUsers(rootPath);
        List<Instructor> instructors = FileHandler.readInstructors(rootPath);
        List<Lesson> lessons = FileHandler.readLessons(rootPath);
        List<Progress> progressList = FileHandler.readProgress(rootPath);

        // Calculate stats
        long totalStudents = users.stream().filter(u -> "Student".equals(u.getRole())).count();
        long activeInstructors = instructors.size();
        LocalDate currentMonth = LocalDate.now();
        long monthlyLessons = lessons.stream()
                .filter(l -> {
                    try {
                        LocalDate lessonDate = LocalDate.parse(l.getDate(), DateTimeFormatter.ISO_LOCAL_DATE);
                        return lessonDate.getYear() == currentMonth.getYear() &&
                               lessonDate.getMonth() == currentMonth.getMonth();
                    } catch (Exception e) {
                        return false;
                    }
                })
                .count();
        // Placeholder revenue: Assume $100 per lesson
        double revenue = monthlyLessons * 100.0;
    %>
    <%@ include file="adminNavbar.jsp" %>

    <!-- Main Content -->
    <main class="pt-16 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto">
        <div class="py-8">
            <!-- Welcome Section -->
            <div class="flex items-center justify-between mb-8">
                <div>
                    <h1 class="text-3xl font-bold text-gray-900">Admin Dashboard</h1>
                    <p class="mt-2 text-gray-600">Manage your driving school operations</p>
                </div>

            </div>

            <!-- Stat Cards -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                <!-- Total Students -->
                <div class="bg-blue-500 text-white p-6 rounded-lg shadow">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium">Total Students</p>
                            <h3 class="text-2xl font-bold"><%= totalStudents %></h3>
                            <p class="text-xs mt-1">+10% from last month</p>
                        </div>
                        <i data-lucide="users" class="w-6 h-6"></i>
                    </div>
                </div>
                <!-- Active Instructors -->
                <div class="bg-green-500 text-white p-6 rounded-lg shadow">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium">Active Instructors</p>
                            <h3 class="text-2xl font-bold"><%= activeInstructors %></h3>
                            <p class="text-xs mt-1">+5% from last month</p>
                        </div>
                        <i data-lucide="user-check" class="w-6 h-6"></i>
                    </div>
                </div>
                <!-- Monthly Lessons -->
                <div class="bg-purple-500 text-white p-6 rounded-lg shadow">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium">Monthly Lessons</p>
                            <h3 class="text-2xl font-bold"><%= monthlyLessons %></h3>
                            <p class="text-xs mt-1">+8% from last month</p>
                        </div>
                        <i data-lucide="calendar" class="w-6 h-6"></i>
                    </div>
                </div>
                <!-- Revenue (Placeholder) -->
                <div class="bg-orange-500 text-white p-6 rounded-lg shadow">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium">Revenue</p>
                            <h3 class="text-2xl font-bold">$<%= String.format("%,.0f", revenue) %></h3>
                            <p class="text-xs mt-1">+15% from last month</p>
                        </div>
                        <i data-lucide="trending-up" class="w-6 h-6"></i>
                    </div>
                </div>
            </div>

            <!-- User Management and System Status -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
                <!-- User Management -->
                <div class="lg:col-span-2">
                    <div class="bg-white p-6 rounded-lg shadow">
                        <h2 class="text-xl font-semibold text-gray-900 mb-4">User Management</h2>
                        <div class="overflow-x-auto">
                            <table class="min-w-full divide-y divide-gray-200">
                                <thead class="bg-gray-50">
                                    <tr>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                                    </tr>
                                </thead>
                                <tbody class="bg-white divide-y divide-gray-200">
                                    <%
                                        for (User u : users) {
                                            if ("Student".equals(u.getRole())) {
                                    %>
                                        <tr>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><%= u.getName() %></td>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= u.getEmail() %></td>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= u.getRole() %></td>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm">
                                                <a href="<%= request.getContextPath() %>/user?action=edit&id=<%= u.getId() %>" class="text-blue-600 hover:underline">Edit</a>
                                                <span class="mx-2">|</span>
                                                <a href="<%= request.getContextPath() %>/user?action=delete&id=<%= u.getId() %>" class="text-red-600 hover:underline">Delete</a>
                                            </td>
                                        </tr>
                                    <%
                                            }
                                        }
                                    %>
                                    <% if (users.stream().noneMatch(u -> "Student".equals(u.getRole()))) { %>
                                        <tr>
                                            <td colspan="4" class="px-6 py-4 text-center text-sm text-gray-500">No students found.</td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                        <div class="mt-4">
                            <a href="<%= request.getContextPath() %>/user?action=list" class="text-blue-600 hover:underline">View All Users</a>
                        </div>
                    </div>
                </div>

                <!-- System Status -->
                <div>
                    <div class="bg-white p-6 rounded-lg shadow">
                        <h2 class="text-xl font-semibold text-gray-900 mb-4">System Status</h2>
                        <div class="space-y-4">
                            <div class="flex items-center">
                                <i data-lucide="alert-circle" class="w-5 h-5 text-green-500 mr-2"></i>
                                <span class="text-gray-600">All systems operational</span>
                            </div>
                            <div class="flex items-center">
                                <i data-lucide="calendar" class="w-5 h-5 text-blue-500 mr-2"></i>
                                <span class="text-gray-600">Last backup: <%= LocalDate.now().minusDays(1).format(DateTimeFormatter.ofPattern("MMM dd, yyyy")) %></span>
                            </div>
                            <div class="flex items-center">
                                <i data-lucide="users" class="w-5 h-5 text-purple-500 mr-2"></i>
                                <span class="text-gray-600">Active users: <%= users.size() %></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Instructor Overview and Recent Activities -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Instructor Overview -->
                <div class="lg:col-span-2">
                    <div class="bg-white p-6 rounded-lg shadow">
                        <h2 class="text-xl font-semibold text-gray-900 mb-4">Instructor Overview</h2>
                        <div class="overflow-x-auto">
                            <table class="min-w-full divide-y divide-gray-200">
                                <thead class="bg-gray-50">
                                    <tr>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Experience</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Availability</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                                    </tr>
                                </thead>
                                <tbody class="bg-white divide-y divide-gray-200">
                                    <%
                                        for (Instructor i : instructors) {
                                    %>
                                        <tr>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><%= i.getName() %></td>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= i.getExperience() %> years</td>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= i.getAvailability() %></td>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm">
                                                <a href="<%= request.getContextPath() %>/instructor?action=profile&id=<%= i.getId() %>" class="text-blue-600 hover:underline">View</a>
                                                <span class="mx-2">|</span>
                                                <a href="<%= request.getContextPath() %>/instructor?action=delete&id=<%= i.getId() %>" class="text-red-600 hover:underline">Delete</a>
                                            </td>
                                        </tr>
                                    <%
                                        }
                                    %>
                                    <% if (instructors.isEmpty()) { %>
                                        <tr>
                                            <td colspan="4" class="px-6 py-4 text-center text-sm text-gray-500">No instructors found.</td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                        <div class="mt-4">
                            <a href="<%= request.getContextPath() %>/instructor?action=list" class="text-blue-600 hover:underline">View All Instructors</a>
                        </div>
                    </div>
                </div>

                <!-- Recent Activities -->
                <div>
                    <div class="bg-white p-6 rounded-lg shadow">
                        <h2 class="text-xl font-semibold text-gray-900 mb-4">Recent Activities</h2>
                        <ul class="space-y-4">
                            <%
                                List<Lesson> recentLessons = lessons.stream()
                                        .sorted((l1, l2) -> {
                                            try {
                                                LocalDate date1 = LocalDate.parse(l1.getDate(), DateTimeFormatter.ISO_LOCAL_DATE);
                                                LocalDate date2 = LocalDate.parse(l2.getDate(), DateTimeFormatter.ISO_LOCAL_DATE);
                                                return date2.compareTo(date1);
                                            } catch (Exception e) {
                                                return 0;
                                            }
                                        })
                                        .limit(3)
                                        .collect(Collectors.toList());
                                for (Lesson lesson : recentLessons) {
                                    String status = lesson.getStatus();
                                    String icon = "ACCEPTED".equalsIgnoreCase(status) ? "check-circle" :
                                                  "PENDING".equalsIgnoreCase(status) ? "clock" : "x-circle";
                                    String iconColor = "ACCEPTED".equalsIgnoreCase(status) ? "text-green-500" :
                                                      "PENDING".equalsIgnoreCase(status) ? "text-yellow-500" : "text-red-500";
                            %>
                                <li class="flex items-center">
                                    <i data-lucide="<%= icon %>" class="<%= iconColor %> w-5 h-5 mr-2"></i>
                                    <span class="text-sm text-gray-600">
                                        <%= lesson.getStudentName() %> booked <%= lesson.getType() %> lesson on <%= lesson.getDate() %>
                                    </span>
                                </li>
                            <%
                                }
                            %>
                            <%
                                List<Progress> recentProgress = progressList.stream()
                                        .sorted((p1, p2) -> p2.getDate().compareTo(p1.getDate()))
                                        .limit(2)
                                        .collect(Collectors.toList());
                                for (Progress progress : recentProgress) {
                            %>
                                <li class="flex items-center">
                                    <i data-lucide="trending-up" class="text-blue-500 w-5 h-5 mr-2"></i>
                                    <span class="text-sm text-gray-600">
                                        <%= progress.getInstructorName() %> updated progress for <%= progress.getStudentName() %> on <%= progress.getDate() %>
                                    </span>
                                </li>
                            <%
                                }
                            %>
                            <% if (recentLessons.isEmpty() && recentProgress.isEmpty()) { %>
                                <li class="text-sm text-gray-600">No recent activities.</li>
                            <% } %>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </main>
</body>
</html>