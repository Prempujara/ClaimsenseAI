<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="user" value="${sessionScope.user}" />
<c:set var="firstName" value="${not empty user.name ? fn:split(user.name, ' ')[0] : 'Employee'}" />
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Employee Dashboard - ClaimSense AI</title>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/assets/css/style.css">
    <link rel="stylesheet" href="${ctx}/assets/css/responsive.css">

    <script src="${ctx}/assets/js/theme.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>

<body>

<div class="dashboard">

    <jsp:include page="../components/sidebar.jsp"/>

    <main class="main">

        <jsp:include page="../components/navbar.jsp"/>

        <div class="content">

            <!-- HEADER & PRIMARY ACTION -->
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 16px;">
                <div>
                    <h2 style="font-size: 22px; font-weight: 800; margin: 0 0 2px; letter-spacing: -0.4px;">Good day, ${fn:escapeXml(firstName)} 👋</h2>
                    <p style="color: var(--text-muted); font-size: 13px; margin: 0;">
                        Overview of your personal expense claims and spending stats.
                    </p>
                </div>
                <a href="${ctx}/SubmitExpenseServlet" class="btn-primary-custom" style="padding: 9px 20px; font-size: 13px; font-weight: 700; text-decoration: none; border-radius: 9px;">
                    <i class="fa-solid fa-plus" style="margin-right: 6px;"></i> Submit Expense
                </a>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger" style="padding: 12px 16px; border-radius: 10px; background: var(--danger-bg); color: var(--danger-text); border: 1px solid var(--danger-border); font-size: 13px; margin-bottom: 20px;">
                    <i class="fa-solid fa-circle-exclamation"></i> ${fn:escapeXml(error)}
                </div>
            </c:if>

            <!-- 4 CLEAN METRIC CARDS -->
            <div class="cards-grid" style="grid-template-columns: repeat(auto-fit, minmax(210px, 1fr)); margin-bottom: 24px; gap: 16px;">
                <!-- Total Spent -->
                <div class="card-stat" style="border-left: 3px solid var(--primary);">
                    <div class="stat-icon total">
                        <i class="fa-solid fa-wallet"></i>
                    </div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Total Spent</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: var(--text-main); margin-top: 2px;">₹${stats.totalAmountDisplay}</h2>
                    </div>
                </div>

                <!-- Pending Review -->
                <div class="card-stat" style="border-left: 3px solid #F59E0B;">
                    <div class="stat-icon pending">
                        <i class="fa-solid fa-hourglass-half"></i>
                    </div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Pending</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: var(--text-main); margin-top: 2px;">${stats.pendingCount}</h2>
                    </div>
                </div>

                <!-- Approved Claims -->
                <div class="card-stat" style="border-left: 3px solid var(--success-dot);">
                    <div class="stat-icon approved">
                        <i class="fa-solid fa-circle-check"></i>
                    </div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Approved</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: var(--text-main); margin-top: 2px;">${stats.approvedCount}</h2>
                    </div>
                </div>

                <!-- Rejected Claims -->
                <div class="card-stat" style="border-left: 3px solid var(--danger-dot);">
                    <div class="stat-icon rejected">
                        <i class="fa-solid fa-circle-xmark"></i>
                    </div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Rejected</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: var(--text-main); margin-top: 2px;">${stats.rejectedCount}</h2>
                    </div>
                </div>
            </div>

            <!-- MAIN 2-COLUMN GRID -->
            <div class="dashboard-grid" style="margin-bottom: 24px; gap: 20px;">

                <!-- RECENT EXPENSES TABLE -->
                <div class="table-box" style="margin: 0;">
                    <div class="box-header" style="margin-bottom: 16px;">
                        <h4 style="font-size: 15px; font-weight: 800;">Recent Expenses</h4>
                        <a href="${ctx}/employee/expenses" style="font-size: 12px; color: var(--primary); text-decoration: none; font-weight: 600;">
                            View All <i class="fa-solid fa-arrow-right" style="font-size: 10px; margin-left: 2px;"></i>
                        </a>
                    </div>
                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Expense</th>
                                    <th>Category</th>
                                    <th>Date</th>
                                    <th>Amount</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="e" items="${recent}">
                                    <tr>
                                        <td>
                                            <a href="${ctx}/expense-details?id=${e.expenseId}" style="text-decoration: none; font-weight: 700; color: var(--primary); font-size: 13px;">
                                                ${fn:escapeXml(e.title)}
                                            </a>
                                            <span style="display: block; font-size: 11px; color: var(--text-muted); font-weight: 500;">${e.claimCode}</span>
                                        </td>
                                        <td><span style="font-size: 13px; color: var(--text-main); font-weight: 500;">${fn:escapeXml(e.categoryName)}</span></td>
                                        <td><span style="font-size: 12px; color: var(--text-muted);">${e.expenseDateDisplay}</span></td>
                                        <td><strong style="font-size: 13px; color: var(--text-main);">₹${e.amountDisplay}</strong></td>
                                        <td>
                                            <jsp:include page="../components/_statusBadge.jsp">
                                                <jsp:param name="status" value="${e.status}" />
                                            </jsp:include>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty recent}">
                                    <tr>
                                        <td colspan="5" style="text-align: center; color: var(--text-muted); padding: 36px 16px;">
                                            <i class="fa-solid fa-receipt" style="font-size: 24px; color: var(--border-color); margin-bottom: 8px; display: block;"></i>
                                            <span style="font-size: 13px; font-weight: 600; color: var(--text-main); display: block; margin-bottom: 2px;">No expenses submitted yet</span>
                                            <a href="${ctx}/SubmitExpenseServlet" style="font-size: 12px; color: var(--primary); font-weight: 600; text-decoration: none;">Submit your first claim →</a>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- CATEGORY BREAKDOWN -->
                <div class="table-box" style="margin: 0;">
                    <div class="box-header" style="margin-bottom: 16px;">
                        <h4 style="font-size: 15px; font-weight: 800;">Spending by Category</h4>
                    </div>
                    <div style="position: relative; min-height: 220px; display: flex; flex-direction: column; justify-content: center; align-items: center;">
                        <c:choose>
                            <c:when test="${chartHasData}">
                                <div style="width: 100%; height: 200px; position: relative;">
                                    <canvas id="expenseChart"></canvas>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div style="text-align: center; color: var(--text-muted); padding: 24px 10px;">
                                    <i class="fa-solid fa-chart-pie" style="font-size: 28px; color: var(--border-color); margin-bottom: 8px; display: block;"></i>
                                    <span style="font-size: 13px; font-weight: 600; color: var(--text-main); display: block;">No Category Data</span>
                                    <span style="font-size: 11px; color: var(--text-muted);">Visualizes automatically as you log expenses.</span>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

            </div>

            <!-- CLEAN SUBTLE AI FOOTER BAR -->
            <div style="display: flex; align-items: center; justify-content: space-between; padding: 12px 18px; background: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; font-size: 12px; color: var(--text-muted); flex-wrap: wrap; gap: 10px;">
                <div style="display: flex; align-items: center; gap: 10px;">
                    <span class="ai-badge" style="font-size: 11px; padding: 3px 10px;"><i class="fa-solid fa-wand-magic-sparkles"></i> ClaimSense AI</span>
                    <span>Tesseract OCR receipt parsing and Isolation Forest risk scoring run automatically on all submitted claims.</span>
                </div>
                <a href="${ctx}/SubmitExpenseServlet" style="color: var(--primary); font-weight: 600; text-decoration: none;">New Expense Claim →</a>
            </div>

        </div>

        <jsp:include page="../components/footer.jsp"/>

    </main>

</div>

<script src="${ctx}/assets/js/script.js"></script>
<c:if test="${chartHasData}">
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const canvas = document.getElementById("expenseChart");
        if (canvas) {
            function getLegendColor() {
                return window.ClaimSenseTheme && window.ClaimSenseTheme.getTheme() === 'dark' ? '#94A3B8' : '#64748B';
            }

            const chartInstance = new Chart(canvas, {
                type: 'doughnut',
                data: {
                    labels: ${chartLabels},
                    datasets: [{
                        data: ${chartData},
                        backgroundColor: [
                            "#4F46E5", "#10B981", "#F59E0B", "#7C3AED",
                            "#EF4444", "#06B6D4", "#64748B"
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
                                boxWidth: 10,
                                padding: 10,
                                font: { family: 'Plus Jakarta Sans', size: 11, weight: '600' },
                                color: getLegendColor()
                            }
                        }
                    }
                }
            });

            window.addEventListener('claimsense-theme-changed', function(e) {
                if (chartInstance && chartInstance.options.plugins.legend.labels) {
                    chartInstance.options.plugins.legend.labels.color = getLegendColor();
                    chartInstance.update();
                }
            });
        }
    });
</script>
</c:if>

</body>

</html>


