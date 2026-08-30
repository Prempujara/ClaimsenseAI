<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="user" value="${sessionScope.user}" />
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Spending Analytics - ClaimSense AI</title>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/assets/css/style.css">
    <link rel="stylesheet" href="${ctx}/assets/css/responsive.css">

    <script src="${ctx}/assets/js/theme.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>

<body>

<div class="dashboard">

    <jsp:include page="components/sidebar.jsp"/>

    <main class="main">

        <jsp:include page="components/navbar.jsp"/>

        <div class="content">

            <!-- HEADER -->
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 16px;">
                <div>
                    <h2 style="font-size: 22px; font-weight: 800; margin: 0 0 2px; letter-spacing: -0.4px;">Spending Analytics</h2>
                    <p style="color: var(--text-muted); font-size: 13px; margin: 0;">
                        Visual breakdown of expense allocation, status ratios, and category metrics.
                    </p>
                </div>
            </div>

            <!-- KPI SUMMARY CARDS -->
            <div class="cards-grid" style="grid-template-columns: repeat(auto-fit, minmax(210px, 1fr)); margin-bottom: 24px; gap: 16px;">
                <div class="card-stat" style="border-left: 3px solid var(--primary);">
                    <div class="stat-icon total"><i class="fa-solid fa-wallet"></i></div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase;">Total Spent</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: var(--text-main); margin-top: 2px;">₹${stats.totalAmountDisplay}</h2>
                    </div>
                </div>

                <div class="card-stat" style="border-left: 3px solid #F59E0B;">
                    <div class="stat-icon pending"><i class="fa-solid fa-hourglass-half"></i></div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase;">Pending</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: var(--text-main); margin-top: 2px;">${stats.pendingCount}</h2>
                    </div>
                </div>

                <div class="card-stat" style="border-left: 3px solid var(--success-dot);">
                    <div class="stat-icon approved"><i class="fa-solid fa-circle-check"></i></div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase;">Approved</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: var(--text-main); margin-top: 2px;">${stats.approvedCount}</h2>
                    </div>
                </div>

                <div class="card-stat" style="border-left: 3px solid var(--danger-dot);">
                    <div class="stat-icon rejected"><i class="fa-solid fa-circle-xmark"></i></div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase;">Rejected</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: var(--text-main); margin-top: 2px;">${stats.rejectedCount}</h2>
                    </div>
                </div>
            </div>

            <!-- CHARTS GRID -->
            <div class="dashboard-grid" style="margin-bottom: 24px; gap: 20px;">
                <!-- Category Bar Chart -->
                <div class="table-box" style="margin: 0;">
                    <div class="box-header" style="margin-bottom: 16px;">
                        <h4 style="font-size: 15px; font-weight: 800;">Spending by Category</h4>
                    </div>
                    <div style="position: relative; width: 100%; height: 240px;">
                        <c:choose>
                            <c:when test="${chartHasData}">
                                <canvas id="analyticsCategoryChart"></canvas>
                            </c:when>
                            <c:otherwise>
                                <div style="text-align: center; color: var(--text-muted); padding: 36px;">No category spending data available.</div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Status Ratio Donut Chart -->
                <div class="table-box" style="margin: 0;">
                    <div class="box-header" style="margin-bottom: 16px;">
                        <h4 style="font-size: 15px; font-weight: 800;">Claim Status Distribution</h4>
                    </div>
                    <div style="position: relative; width: 100%; height: 240px;">
                        <c:choose>
                            <c:when test="${stats.totalCount > 0}">
                                <canvas id="analyticsStatusChart"></canvas>
                            </c:when>
                            <c:otherwise>
                                <div style="text-align: center; color: var(--text-muted); padding: 36px;">No claim submissions available.</div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- CATEGORY SUMMARY TABLE -->
            <div class="table-box" style="margin-bottom: 32px;">
                <div class="box-header" style="margin-bottom: 16px;">
                    <h4 style="font-size: 15px; font-weight: 800;">Category Expense Allocations</h4>
                </div>
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Category</th>
                                <th>Total Expenditure</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="entry" items="${categoryTotals}">
                                <tr>
                                    <td><strong style="color: var(--text-main); font-size: 13px;">${fn:escapeXml(entry.key)}</strong></td>
                                    <td><strong style="color: var(--primary); font-size: 13px;">₹${entry.value}</strong></td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty categoryTotals}">
                                <tr>
                                    <td colspan="2" style="text-align: center; color: var(--text-muted); padding: 24px;">No expense category data recorded.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>

        <jsp:include page="components/footer.jsp"/>

    </main>

</div>

<script src="${ctx}/assets/js/script.js"></script>
<c:if test="${chartHasData}">
<script>
    document.addEventListener("DOMContentLoaded", function() {
        function getLegendColor() {
            return window.ClaimSenseTheme && window.ClaimSenseTheme.getTheme() === 'dark' ? '#94A3B8' : '#64748B';
        }

        const catCanvas = document.getElementById("analyticsCategoryChart");
        if (catCanvas) {
            new Chart(catCanvas, {
                type: 'bar',
                data: {
                    labels: ${chartLabels},
                    datasets: [{
                        label: 'Total Spend (₹)',
                        data: ${chartData},
                        backgroundColor: '#4F46E5',
                        borderRadius: 6
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } }
                }
            });
        }

        const statusCanvas = document.getElementById("analyticsStatusChart");
        if (statusCanvas) {
            new Chart(statusCanvas, {
                type: 'doughnut',
                data: {
                    labels: ['Pending', 'Approved', 'Rejected'],
                    datasets: [{
                        data: [${stats.pendingCount}, ${stats.approvedCount}, ${stats.rejectedCount}],
                        backgroundColor: ['#F59E0B', '#10B981', '#EF4444'],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'bottom', labels: { color: getLegendColor(), font: { size: 11 } } }
                    }
                }
            });
        }
    });
</script>
</c:if>

</body>

</html>
