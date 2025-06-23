<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Staff - Manage Reviews</title>

        <!-- Bootstrap 5 CSS & JS -->
        <link rel="stylesheet" href="../css/bootstrap.css" />
        <script src="../js/bootstrap.bundle.js"></script>

        <!--CSS for Sidebar-->
        <link rel="stylesheet" href="../css/sidebar.css" />

        <!--JS for Sidebar-->
        <script src="../js/sidebar.js"></script>

        <!-- Bootstrap Icons -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" />

        <style>
            body {
                margin: 0;
                font-family: 'Segoe UI', sans-serif;
                background-color: white;
                display: flex;
                min-height: 100vh;
            }

            .main {
                margin-left: 250px;
                width: calc(100% - 250px);
                min-height: 100vh;
                display: flex;
                flex-direction: column;
                transition: margin-left 0.3s ease-in-out;
            }

            .topbar {
                height: 60px;
                background-color: #fff;
                display: flex;
                justify-content: flex-end;
                align-items: center;
                padding: 0 30px;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
                z-index: 999;
            }

            .topbar .profile {
                display: flex;
                align-items: center;
                gap: 20px;
                visibility: visible;
                opacity: 1;
            }

            .topbar .profile i {
                font-size: 1.3rem;
                cursor: pointer;
                color: #2c3e50;
            }

            .topbar .username {
                font-weight: 400;
                color: #333;
            }

            .content {
                padding: 30px;
                background-color: white;
                flex-grow: 1;
            }

            .menu-toggle {
                display: none;
                font-size: 1.5rem;
                cursor: pointer;
                color: #333;
            }

            .wellcome-text{
                padding: 8px;
            }

            @media (max-width: 768px) {
                .main {
                    margin-left: 0;
                }

                .main.sidebar-active {
                    margin-left: 250px;
                }

                .menu-toggle {
                    display: block;
                }

                .topbar {
                    position: fixed;
                    justify-content: space-between;
                    top: 0;
                    width: 100%;
                    left: 0;
                }

                .content {
                    padding-top: 90px;
                }

                .topbar .profile {
                    display: flex;
                    visibility: visible;
                    opacity: 1;
                }

                .notification-popup {
                    right: 10px;
                    width: 90%;
                    max-width: 300px;
                }
            }

            @media (max-width: 576px) {
                .main.sidebar-active {
                    margin-left: 200px;
                }
            }
        </style>
    </head>
    <body>

        <!-- Sidebar -->
        <jsp:include page="staff_sidebar.jsp" />

        <!-- Main Section -->
        <div class="main">
            <nav class="navbar navbar-expand-lg navbar-light bg-light shadow-sm">
                <div class="container-fluid">
                    <a class="navbar-brand" href="${pageContext.request.contextPath}/staff/dashboard">Oiship</a>
                    <div class="collapse navbar-collapse" id="navbarNav">
                        <ul class="navbar-nav ms-auto">
                            <li class="wellcome-text">Welcome, <span><c:out value="${sessionScope.userName}" /></span>!</li>
                            <li class="nav-item">
                                <a class="nav-link" href="${pageContext.request.contextPath}/logout">Logout</a>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>

            <!-- Content -->
            <div class="content mt-5">
                <h2 class="mb-4 text-center">Manage Reviews</h2>

                <!-- Search and Filter -->
                <div class="row mb-4">
                    <div class="col-md-6">
                        <div class="d-flex align-items-center">
                            <label class="me-2 fw-semibold mb-0">Search Dish:</label>
                            <input type="text" id="dishSearch" class="form-control w-auto" placeholder="Enter dish name..." />
                        </div>
                    </div>

                </div>

                <!-- Reviews Table -->
                <div class="table-responsive">
                    <table id="reviewTable" class="table table-hover table-bordered text-center align-middle shadow-sm">
                        <thead class="table-dark">
                            <tr>
                                <th>#</th>
                                <th>Order ID</th>
                                <th>Dish</th>
                                <th>Category</th>
                                <th>Customer</th>
                                <th>Rating</th>
                                <th>Comment</th>
                                <th>Date</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${reviews}">
                                
                                <tr data-category="${r.catName}">
                                    <td class="fw-bold">${r.reviewID}</td>
                                    <td>${r.orderId}</td>
                                    <td>${r.dishName}</td>
                                    <td>${r.catName}</td>
                                    <td>${r.customerName}</td>
                                    <td>
                                        <span class="badge bg-warning text-dark fs-6">${r.rating} ★</span>
                                    </td>
                                    <td class="text-start">${r.comment}</td>
                                    <td><small class="text-muted">${r.reviewCreatedAt}</small></td>
                                    <td>
                                        <a href="manage-reviews?action=delete&reviewID=${r.reviewID}"
                                           class="btn btn-sm btn-outline-danger"
                                           onclick="return confirm('Bạn có chắc chắn muốn xóa đánh giá này không?');">
                                            🗑 Delete
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- JavaScript filter -->
            <script>
                // Bỏ dấu tiếng Việt để search tốt hơn
                function removeVietnameseTones(str) {
                    return str.normalize("NFD").replace(/[\u0300-\u036f]/g, "")
                            .replace(/đ/g, "d").replace(/Đ/g, "D");
                }

                document.addEventListener("DOMContentLoaded", () => {
                    const searchInput = document.getElementById("dishSearch");
                    const categoryFilter = document.getElementById("categoryFilter");
                    const rows = document.querySelectorAll("#reviewTable tbody tr");

                    function filterReviews() {
                        const searchKeyword = removeVietnameseTones(searchInput.value.trim().toLowerCase());
                        const selectedCategory = removeVietnameseTones(categoryFilter.value.trim().toLowerCase());

                        rows.forEach(row => {
                            const dishCell = row.children[2]; // Cột Dish
                            const dishName = removeVietnameseTones(dishCell.textContent.toLowerCase());
                            const category = removeVietnameseTones(row.getAttribute("data-category")?.toLowerCase() || "");

                            const matchesSearch = dishName.includes(searchKeyword);
                            const matchesCategory = selectedCategory === "all" || category === selectedCategory;

                            row.style.display = (matchesSearch && matchesCategory) ? "" : "none";
                        });
                    }

                    searchInput.addEventListener("input", filterReviews);
                    categoryFilter.addEventListener("change", filterReviews);
                });
            </script>


    </body>
</html>