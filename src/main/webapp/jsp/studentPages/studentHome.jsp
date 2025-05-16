<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.Lesson" %>
<%@ page import="com.Model.Progress" %>
<%@ page import="com.Model.Instructor" %>
<%@ page import="com.Util.FileHandler" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student Dashboard</title>
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
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (user instanceof com.Model.Instructor) {
            response.sendRedirect(request.getContextPath() + "/jsp/instructorPages/instructorHome.jsp");
            return;
        }
        String studentName = user.getName();
        String rootPath = getServletContext().getRealPath("/");

        // Fetch lessons and progress
        List<Lesson> allLessons = FileHandler.readLessons(rootPath);
        List<Progress> allProgress = FileHandler.readProgress(rootPath);
        List<Instructor> instructors = FileHandler.readInstructors(rootPath);

        // Filter lessons for the student
        List<Lesson> studentLessons = allLessons.stream()
                .filter(l -> l.getStudentName().equalsIgnoreCase(studentName))
                .collect(Collectors.toList());

        // Calculate progress
        int completedLessons = (int) allProgress.stream()
                .filter(p -> p.getStudentName().equalsIgnoreCase(studentName))
                .count();
        int totalLessons = studentLessons.size();
        double progress = (totalLessons > 0) ? ((double) completedLessons / totalLessons) * 100 : 0;

        // Find next lesson (earliest PENDING or ACCEPTED)
        Lesson nextLesson = studentLessons.stream()
                .filter(l -> "PENDING".equalsIgnoreCase(l.getStatus()) || "ACCEPTED".equalsIgnoreCase(l.getStatus()))
                .sorted((l1, l2) -> {
                    LocalDate date1 = LocalDate.parse(l1.getDate(), DateTimeFormatter.ISO_LOCAL_DATE);
                    LocalDate date2 = LocalDate.parse(l2.getDate(), DateTimeFormatter.ISO_LOCAL_DATE);
                    LocalTime time1 = LocalTime.parse(l1.getTime(), DateTimeFormatter.ofPattern("HH:mm"));
                    LocalTime time2 = LocalTime.parse(l2.getTime(), DateTimeFormatter.ofPattern("HH:mm"));
                    return date1.atTime(time1).compareTo(date2.atTime(time2));
                })
                .findFirst()
                .orElse(null);
    %>
<%@ include file="studentNavbar.jsp" %>
    <!-- Main Content -->
    <main class="pt-16 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto">
        <div class="py-8">
            <!-- Welcome Section -->
            <div class="flex items-center justify-between mb-8">
                <div>
                    <h1 class="text-3xl font-bold text-gray-900">Welcome back, <%= studentName %>!</h1>
                    <p class="mt-2 text-gray-600">Ready for your next driving lesson?</p>
                </div>
                <div class="flex items-center space-x-4">
                    <a href="<%= request.getContextPath() %>/lesson" class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center">
                        <i data-lucide="calendar" class="w-5 h-5 mr-2"></i>
                        Book Lesson
                    </a>
                    <button class="relative p-2 text-gray-600 hover:bg-gray-100 rounded-full">
                        <i data-lucide="bell" class="w-6 h-6"></i>
                        <span class="absolute top-0 right-0 w-2 h-2 bg-red-500 rounded-full"></span>
                    </button>
                </div>
            </div>

            <!-- Grid Layout: Next Lesson and Progress Card -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
                <!-- Next Lesson -->
                <div class="lg:col-span-2">
                    <div class="bg-white p-6 rounded-lg shadow">
                        <h2 class="text-xl font-semibold text-gray-900 mb-4">Next Lesson</h2>
                        <% if (nextLesson != null) { %>
                            <p class="text-gray-600">Date: <%= nextLesson.getDate() %></p>
                            <p class="text-gray-600">Time: <%= nextLesson.getTime() %></p>
                            <p class="text-gray-600">Instructor: <%= nextLesson.getInstructorName() %></p>
                            <p class="text-gray-600">Type: <%= nextLesson.getType() %></p>
                            <p class="text-gray-600">Status: <%= nextLesson.getStatus() %></p>
                            <div class="mt-4">
                                <a href="<%= request.getContextPath() %>/lesson?action=edit&lessonId=<%= nextLesson.getLessonId() %>" class="text-blue-600 hover:underline">Edit</a>
                                <span class="mx-2">|</span>
                                <a href="<%= request.getContextPath() %>/lesson?action=delete&lessonId=<%= nextLesson.getLessonId() %>" class="text-red-600 hover:underline">Delete</a>
                            </div>
                        <% } else { %>
                            <p class="text-gray-600">No upcoming lessons scheduled.</p>
                            <div class="mt-4">
                                <a href="<%= request.getContextPath() %>/lesson" class="text-blue-600 hover:underline">Book a Lesson</a>
                            </div>
                        <% } %>
                    </div>
                </div>

                <!-- Progress Card -->
                <div>
                    <div class="bg-white p-6 rounded-lg shadow">
                        <h2 class="text-xl font-semibold text-gray-900 mb-4">Your Progress</h2>
                        <p class="text-gray-600">Lessons Completed: <%= completedLessons %> / <%= totalLessons %></p>
                        <div class="mt-4">
                            <div class="w-full bg-gray-200 rounded-full h-4">
                                <div class="bg-blue-600 h-4 rounded-full" style="width: <%= progress %>%"></div>
                            </div>
                            <p class="mt-2 text-sm text-gray-600"><%= String.format("%.0f", progress) %>% Complete</p>
                        </div>
                        <div class="mt-4">
                            <a href="<%= request.getContextPath() %>/progress?action=studentProgress" class="text-blue-600 hover:underline">View Details</a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Grid Layout: Learning Path and Quick Booking -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Learning Path -->
                <div class="lg:col-span-2">
                    <div class="bg-white p-6 rounded-lg shadow">
                        <h2 class="text-xl font-semibold text-gray-900 mb-4">Your Learning Path</h2>
                        <ul class="space-y-4">
                            <%
                                for (Lesson lesson : studentLessons) {
                                    boolean isCompleted = allProgress.stream()
                                            .anyMatch(p -> p.getLessonId().equals(lesson.getLessonId()));
                                    String icon = isCompleted ? "check-circle" :
                                                 "ACCEPTED".equalsIgnoreCase(lesson.getStatus()) ? "play-circle" : "circle";
                                    String iconColor = isCompleted ? "text-green-500" :
                                                      "ACCEPTED".equalsIgnoreCase(lesson.getStatus()) ? "text-blue-500" : "text-gray-400";
                                    String status = isCompleted ? "Completed" :
                                                   "ACCEPTED".equalsIgnoreCase(lesson.getStatus()) ? "In Progress" :
                                                   "Pending";
                            %>
                                <li class="flex items-center">
                                    <i data-lucide="<%= icon %>" class="<%= iconColor %> w-5 h-5 mr-2"></i>
                                    <span><%= lesson.getType() %> Lesson on <%= lesson.getDate() %> - <%= status %></span>
                                </li>
                            <% } %>
                            <% if (studentLessons.isEmpty()) { %>
                                <li class="text-gray-600">No lessons in your learning path yet.</li>
                            <% } %>
                        </ul>
                        <div class="mt-4">
                            <a href="<%= request.getContextPath() %>/lesson?action=list" class="text-blue-600 hover:underline">View All Lessons</a>
                        </div>
                    </div>
                </div>

                <!-- Quick Booking -->
                <div>
                    <div class="bg-white p-6 rounded-lg shadow">
                        <h2 class="text-xl font-semibold text-gray-900 mb-4">Quick Booking</h2>
                        <form action="<%= request.getContextPath() %>/lesson" method="post">
                            <input type="hidden" name="action" value="register">
                            <div class="space-y-4">
                                <div>
                                    <label class="block text-sm text-gray-600">Preferred Date</label>
                                    <input type="date" name="date" class="w-full p-2 border rounded-lg" required>
                                </div>
                                <div>
                                    <label class="block text-sm text-gray-600">Preferred Time</label>
                                    <input type="time" name="time" class="w-full p-2 border rounded-lg" required>
                                </div>
                                <div>
                                    <label class="block text-sm text-gray-600">Instructor</label>
                                    <select name="instructorName" class="w-full p-2 border rounded-lg" required>
                                        <option value="">Select Instructor</option>
                                        <% for (Instructor instructor : instructors) { %>
                                            <option value="<%= instructor.getName() %>"><%= instructor.getName() %></option>
                                        <% } %>
                                    </select>
                                </div>
                                <div>
                                    <label class="block text-sm text-gray-600">Lesson Type</label>
                                    <select name="type" class="w-full p-2 border rounded-lg" required>
                                        <option value="Beginner">Beginner</option>
                                        <option value="Advanced">Advanced</option>
                                    </select>
                                </div>
                                <button type="submit" class="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition-colors">
                                    Book Lesson
                                </button>
                            </div>
                        </form>
                        <%
                            String success = request.getParameter("success");
                            if ("true".equals(success)) {
                        %>
                            <p class="mt-4 text-green-600">Lesson booked successfully!</p>
                        <% } %>
                        <%
                            String error = (String) request.getAttribute("error");
                            if (error != null) {
                        %>
                            <p class="mt-4 text-red-600"><%= error %></p>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </main>
</body>
</html>