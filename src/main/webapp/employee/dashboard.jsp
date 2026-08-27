<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Employee Dashboard - ClaimSense AI</title>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive.css">

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>

<body>

<div class="dashboard">

    <jsp:include page="../components/sidebar.jsp"/>

    <main class="main">

        <jsp:include page="../components/navbar.jsp"/>

        <div class="content">

            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 28px; flex-wrap: wrap; gap: 16px;">
                <div>
                    <h2 style="font-size: 24px; font-weight: 700; margin-bottom: 4px;">Good Evening, Prem 👋</h2>
                    <p style="color: var(--text-muted); font-size: 14px; margin: 0;">
                        Welcome back! Track your submissions and AI expense metrics below.
                    </p>
                </div>
                <a href="${pageContext.request.contextPath}/employee/submitExpense.jsp" class="btn-primary-custom">
                    <i class="fa-solid fa-plus"></i> Submit Expense
                </a>
            </div>

            <!-- Stats Grid -->
            <div class="cards-grid">
                <div class="card-stat">
                    <div class="stat-icon total">
                        <i class="fa-solid fa-wallet"></i>
                    </div>
                    <div class="stat-info">
                        <span>Total Expenses</span>
                        <h2>₹28,500</h2>
                    </div>
                </div>

                <div class="card-stat">
                    <div class="stat-icon pending">
                        <i class="fa-solid fa-hourglass-half"></i>
                    </div>
                    <div class="stat-info">
                        <span>Pending</span>
                        <h2>08</h2>
                    </div>
                </div>

                <div class="card-stat">
                    <div class="stat-icon approved">
                        <i class="fa-solid fa-circle-check"></i>
                    </div>
                    <div class="stat-info">
                        <span>Approved</span>
                        <h2>16</h2>
                    </div>
                </div>

                <div class="card-stat">
                    <div class="stat-icon rejected">
                        <i class="fa-solid fa-circle-xmark"></i>
                    </div>
                    <div class="stat-info">
                        <span>Rejected</span>
                        <h2>03</h2>
                    </div>
                </div>
            </div>

            <!-- AI Insights Card -->
            <div class="ai-card">
                <div class="ai-card-header">
                    <div class="ai-card-title">
                        <i class="fa-solid fa-wand-magic-sparkles" style="font-size: 20px;"></i>
                        <h4 style="margin: 0; font-size: 16px;">AI Expense Insights & Engine</h4>
                    </div>
                    <span class="ai-badge">
                        <i class="fa-solid fa-circle-dot fa-spin"></i> Engine Operational
                    </span>
                </div>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-top: 16px;">
                    <div style="background: white; padding: 14px; border-radius: 10px; border: 1px solid rgba(124,58,237,0.15);">
                        <span style="font-size: 12px; color: var(--text-muted); font-weight: 500;">OCR Receipt Scanner</span>
                        <div style="font-weight: 600; font-size: 14px; margin-top: 4px; color: var(--success-text);">
                            <i class="fa-solid fa-check-circle"></i> Ready & Active
                        </div>
                    </div>

                    <div style="background: white; padding: 14px; border-radius: 10px; border: 1px solid rgba(124,58,237,0.15);">
                        <span style="font-size: 12px; color: var(--text-muted); font-weight: 500;">Category Auto-Suggest</span>
                        <div style="font-weight: 600; font-size: 14px; margin-top: 4px; color: var(--success-text);">
                            <i class="fa-solid fa-check-circle"></i> Model Loaded
                        </div>
                    </div>

                    <div style="background: white; padding: 14px; border-radius: 10px; border: 1px solid rgba(124,58,237,0.15);">
                        <span style="font-size: 12px; color: var(--text-muted); font-weight: 500;">Anomaly Detection</span>
                        <div style="font-weight: 600; font-size: 14px; margin-top: 4px; color: var(--text-muted);">
                            <span class="ai-badge" style="background: #F1F5F9; color: #475569; border-color: #CBD5E1;">AI analysis pending</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Main Dashboard Grid -->
            <div class="dashboard-grid">

                <div class="table-box">
                    <div class="box-header">
                        <h4>Recent Expenses</h4>
                        <a href="${pageContext.request.contextPath}/employee/myExpense.jsp" style="font-size: 13px; color: var(--primary); text-decoration: none; font-weight: 600;">View All</a>
                    </div>
                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Expense Title</th>
                                    <th>Category</th>
                                    <th>Amount</th>
                                    <th>Date</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/employee/expenseDetails.jsp" style="text-decoration: none; font-weight: 600; color: var(--primary);">Uber Ride to Office</a>
                                    </td>
                                    <td>Travel</td>
                                    <td><strong>₹450</strong></td>
                                    <td>24 Aug 2026</td>
                                    <td><span class="badge-status approved"><i class="fa-solid fa-check"></i> Approved</span></td>
                                </tr>
                                <tr>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/employee/expenseDetails.jsp" style="text-decoration: none; font-weight: 600; color: var(--primary);">Starbucks Client Coffee</a>
                                    </td>
                                    <td>Food</td>
                                    <td><strong>₹320</strong></td>
                                    <td>23 Aug 2026</td>
                                    <td><span class="badge-status pending"><i class="fa-solid fa-clock"></i> Pending</span></td>
                                </tr>
                                <tr>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/employee/expenseDetails.jsp" style="text-decoration: none; font-weight: 600; color: var(--primary);">Amazon Stationeries</a>
                                    </td>
                                    <td>Office Supplies</td>
                                    <td><strong>₹1,250</strong></td>
                                    <td>20 Aug 2026</td>
                                    <td><span class="badge-status approved"><i class="fa-solid fa-check"></i> Approved</span></td>
                                </tr>
                                <tr>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/employee/expenseDetails.jsp" style="text-decoration: none; font-weight: 600; color: var(--primary);">Team Dinner</a>
                                    </td>
                                    <td>Food</td>
                                    <td><strong>₹4,800</strong></td>
                                    <td>18 Aug 2026</td>
                                    <td><span class="badge-status rejected"><i class="fa-solid fa-xmark"></i> Rejected</span></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="table-box">
                    <div class="box-header">
                        <h4>Expense Breakdown</h4>
                    </div>
                    <div style="position: relative; height: 220px; display: flex; justify-content: center;">
                        <canvas id="expenseChart"></canvas>
                    </div>
                </div>

            </div>

        </div>

        <jsp:include page="../components/footer.jsp"/>

    </main>

</div>

<script src="${pageContext.request.contextPath}/assets/js/script.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const ctx = document.getElementById("expenseChart");
        if (ctx) {
            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: ["Travel", "Food", "Office Supplies", "Accommodation"],
                    datasets: [{
                        data: [55, 20, 15, 10],
                        backgroundColor: [
                            "#2563EB",
                            "#10B981",
                            "#F59E0B",
                            "#7C3AED"
                        ],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                boxWidth: 12,
                                padding: 15,
                                font: {
                                    family: 'Inter',
                                    size: 12
                                }
                            }
                        }
                    }
                }
            });
        }
    });
</script>

</body>

</html>