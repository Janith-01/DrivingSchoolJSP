<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.Lesson, com.Model.Instructor, com.Model.User, com.Model.Progress, com.Util.FileHandler, java.util.List, java.util.stream.Collectors, java.util.Calendar, java.util.Date, java.text.SimpleDateFormat" %>
<%
    // Ensure user is an instructor
    Object loggedInUser = session.getAttribute("loggedInUser");
    if (loggedInUser == null || !(loggedInUser instanceof com.Model.Instructor)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    Instructor instructor = (Instructor) loggedInUser;

    // Fetch lessons for the instructor
    String rootPath = getServletContext().getRealPath("/");
    List<Lesson> allLessons = FileHandler.readLessons(rootPath);
    List<Lesson> instructorLessons = allLessons.stream()
            .filter(l -> l.getInstructorName().equalsIgnoreCase(instructor.getName()) &&
                    ("PENDING".equalsIgnoreCase(l.getStatus()) || "ACCEPTED".equalsIgnoreCase(l.getStatus())))
            .collect(Collectors.toList());

    // Fetch students
    List<User> students = FileHandler.readUsers(rootPath);

    // Calculate metrics
    int totalStudents = students.size();
    long lessonsThisWeek = instructorLessons.stream()
            .filter(l -> {
                try {
                    Date lessonDate = new SimpleDateFormat("yyyy-MM-dd").parse(l.getDate());
                    Calendar cal = Calendar.getInstance();
                    cal.setTime(new Date());
                    int week = cal.get(Calendar.WEEK_OF_YEAR);
                    cal.setTime(lessonDate);
                    return cal.get(Calendar.WEEK_OF_YEAR) == week;
                } catch (Exception e) {
                    return false;
                }
            })
            .count();
    int hoursTaught = instructorLessons.size() * 2; // Assume 2 hours per lesson
    double passRate = 92.0; // Mock data

    // Fetch progress for students
    List<Progress> allProgress = FileHandler.readProgress(rootPath);
    List<String> lessonsWithProgress = allProgress.stream()
            .map(Progress::getLessonId)
            .collect(Collectors.toList());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Instructor Dashboard</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Lucide Icons CDN -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        .sidebar { transition: all 0.3s ease-in-out; }
        @media (min-width: 1024px) {
            .sidebar-hidden { transform: translateX(0); width: 16rem; }
        }
        .sidebar-hidden { transform: translateX(-100%); width: 0; }
        .progress-bar { transition: width 0.5s ease-in-out; }
    </style>
</head>
<body class="bg-gray-100 min-h-screen">
<%@ include file="instructorNavbar.jsp" %>

    <!-- Main Content -->
    <main class="pt-16 lg:pl-center">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <div class="mb-6">
                <h1 class="text-2xl font-bold text-gray-900">Welcome back, <%= instructor.getName() %>!</h1>
                <p class="text-gray-600 mt-1">Here's what's happening with your students today.</p>
            </div>

            <!-- Stat Cards -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                <div class="bg-white rounded-lg shadow-md p-5 hover:shadow-lg transition-all">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500">Total Students</p>
                            <h3 class="text-2xl font-bold text-gray-700"><%= totalStudents %></h3>
                            <div class="flex items-center mt-2">
                                <span class="text-green-500">↑ 12%</span>
                                <span class="text-xs text-gray-500 ml-1">vs last month</span>
                            </div>
                        </div>
                        <div class="p-3 rounded-full bg-emerald-100 text-emerald-600">
                            <i data-lucide="users" class="w-6 h-6"></i>
                        </div>
                    </div>
                </div>
                <div class="bg-white rounded-lg shadow-md p-5 hover:shadow-lg transition-all">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500">Lessons This Week</p>
                            <h3 class="text-2xl font-bold text-gray-700"><%= lessonsThisWeek %></h3>
                            <div class="flex items-center mt-2">
                                <span class="text-green-500">↑ 5%</span>
                                <span class="text-xs text-gray-500 ml-1">vs last month</span>
                            </div>
                        </div>
                        <div class="p-3 rounded-full bg-emerald-100 text-emerald-600">
                            <i data-lucide="calendar" class="w-6 h-6"></i>
                        </div>
                    </div>
                </div>
                <div class="bg-white rounded-lg shadow-md p-5 hover:shadow-lg transition-all">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500">Hours Taught</p>
                            <h3 class="text-2xl font-bold text-gray-700"><%= hoursTaught %></h3>
                            <div class="flex items-center mt-2">
                                <span class="text-green-500">↑ 3%</span>
                                <span class="text-xs text-gray-500 ml-1">vs last month</span>
                            </div>
                        </div>
                        <div class="p-3 rounded-full bg-emerald-100 text-emerald-600">
                            <i data-lucide="clock" class="w-6 h-6"></i>
                        </div>
                    </div>
                </div>
                <div class="bg-white rounded-lg shadow-md p-5 hover:shadow-lg transition-all">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500">Pass Rate</p>
                            <h3 class="text-2xl font-bold text-gray-700"><%= passRate %>%</h3>
                            <div class="flex items-center mt-2">
                                <span class="text-green-500">↑ 2%</span>
                                <span class="text-xs text-gray-500 ml-1">vs last month</span>
                            </div>
                        </div>
                        <div class="p-3 rounded-full bg-emerald-100 text-emerald-600">
                            <i data-lucide="award" class="w-6 h-6"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Main Grid -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Upcoming Lessons -->
                <div class="lg:col-span-2 bg-white rounded-lg shadow-md">
                    <div class="px-6 py-4 border-b border-gray-200">
                        <h2 class="text-lg font-semibold text-gray-800">Upcoming Lessons</h2>
                    </div>
                    <div class="divide-y divide-gray-200">
                        <%
                            for (Lesson lesson : instructorLessons) {
                        %>
                            <div class="p-5 hover:bg-gray-50 transition-colors">
                                <div class="flex justify-between items-start">
                                    <div>
                                        <h3 class="font-medium text-gray-900"><%= lesson.getStudentName() %></h3>
                                        <p class="text-sm text-gray-600 mt-1"><%= lesson.getType() %></p>
                                        <div class="mt-3 flex items-center text-sm text-gray-500">
                                            <i data-lucide="clock" class="w-4 h-4 mr-1"></i>
                                            <span><%= lesson.getDate() %>, <%= lesson.getTime() %></span>
                                        </div>
                                        <div class="mt-1 flex items-center text-sm text-gray-500">
                                            <i data-lucide="map-pin" class="w-4 h-4 mr-1"></i>
                                            <span>Location TBD</span>
                                        </div>
                                    </div>
                                    <span class="inline-flex px-2 py-1 text-xs font-medium rounded-full <%= lesson.getStatus().equals("ACCEPTED") ? "bg-green-100 text-green-600" : "bg-yellow-100 text-yellow-600" %>">
                                        <%= lesson.getStatus() %>
                                    </span>
                                </div>
                                <div class="mt-4 flex justify-end space-x-3">
                                    <form action="<%= request.getContextPath() %>/lesson" method="post">
                                        <input type="hidden" name="action" value="ACCEPTED">
                                        <input type="hidden" name="lessonId" value="<%= lesson.getLessonId() %>">
                                        <button type="submit" class="px-3 py-1 text-sm bg-emerald-600 rounded-md text-white hover:bg-emerald-700">Accept</button>
                                    </form>
                                    <form action="<%= request.getContextPath() %>/lesson" method="post">
                                        <input type="hidden" name="action" value="DENIED">
                                        <input type="hidden" name="lessonId" value="<%= lesson.getLessonId() %>">
                                        <button type="submit" class="px-3 py-1 text-sm bg-red-600 rounded-md text-white hover:bg-red-700">Deny</button>
                                    </form>
                                </div>
                            </div>
                        <%
                            }
                        %>
                    </div>
                    <div class="px-6 py-3 border-t border-gray-200">
                        <a href="<%= request.getContextPath() %>/lesson?action=list" class="text-sm text-emerald-600 hover:text-emerald-700 font-medium">
                            View all lessons →
                        </a>
                    </div>
                </div>

                <!-- Right Column -->
                <div class="space-y-6">
                    <!-- Progress Chart -->
                    <div class="bg-white rounded-lg shadow-md p-5">
                        <h2 class="text-lg font-semibold text-gray-800 mb-4">Student Progress</h2>
                        <div class="space-y-4">
                            <%
                                int index = 0;
                                for (Lesson lesson : instructorLessons) {
                                    if (lessonsWithProgress.contains(lesson.getLessonId())) {
                                        int progress = index * 20 + 45; // Mock progress
                            %>
                                <div class="space-y-2">
                                    <div class="flex justify-between">
                                        <span class="text-sm font-medium text-gray-700"><%= lesson.getStudentName() %></span>
                                        <span class="text-sm text-gray-500"><%= progress %>%</span>
                                    </div>
                                    <div class="w-full bg-gray-200 rounded-full Ascending
                                    <div class="bg-emerald-600 h-2.5 rounded-full progress-bar" style="width: <%= progress %>%"></div>
                                </div>
                            <%
                                        index++;
                                    }
                                }
                            %>
                        </div>
                        <div class="mt-5 pt-3 border-t border-gray-200">
                            <a href="<%= request.getContextPath() %>/progress?action=viewProgress" class="text-sm text-emerald-600 hover:text-emerald-700 font-medium">
                                View all students →
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>