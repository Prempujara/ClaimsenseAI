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

            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 28px; flex-wrap: wrap; gap: 16px;">
                <div>
                    <h2 style="font-size: 24px; font-weight: 800; margin-bottom: 4px; letter-spacing: -0.4px;">Good day, ${fn:escapeXml(fn:split(user.name, ' ')[0])} 👋</h2>
                    <p style="color: var(--text-muted); font-size: 14px; margin: 0;">
                        Track your submitted expenses, AI OCR predictions, and manager approvals.
                    </p>
                </div>
                <a href="${ctx}/SubmitExpenseServlet" class="btn-primary-custom" style="padding: 10px 20px; font-size: 14px;">
                    <i class="fa-solid fa-plus"></i> Submit New Expense
                </a>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger" style="padding: 12px 16px; border-radius: 10px; background: var(--danger-bg); color: var(--danger-text); border: 1px solid var(--danger-border); font-size: 13px; margin-bottom: 24px;"><i class="fa-solid fa-circle-exclamation"></i> ${fn:escapeXml(error)}</div>
            </c:if>

            <!-- KPI Cards Grid -->
            <div class="cards-grid">
                <div class="card-stat">
                    <div class="stat-icon total">
                        <i class="fa-solid fa-wallet"></i>
                    </div>
                    <div class="stat-info">
                        <span>Total Claim Value</span>
                        <h2>₹${stats.totalAmountDisplay}</h2>
                    </div>
                </div>

                <div class="card-stat">
                    <div class="stat-icon pending">
                        <i class="fa-solid fa-hourglass-half"></i>
                    </div>
                    <div class="stat-info">
                        <span>Pending Approval</span>
                        <h2>${stats.pendingCount}</h2>
                    </div>
                </div>

                <div class="card-stat">
                    <div class="stat-icon approved">
                        <i class="fa-solid fa-circle-check"></i>
                    </div>
                    <div class="stat-info">
                        <span>Approved Claims</span>
                        <h2>${stats.approvedCount}</h2>
                    </div>
                </div>

                <div class="card-stat">
                    <div class="stat-icon rejected">
                        <i class="fa-solid fa-circle-xmark"></i>
                    </div>
                    <div class="stat-info">
                        <span>Rejected Claims</span>
                        <h2>${stats.rejectedCount}</h2>
                    </div>
                </div>
            </div>

            <!-- AI Engine Insights Card -->
            <div class="ai-card">
                <div class="ai-card-header">
                    <div class="ai-card-title">
                        <i class="fa-solid fa-wand-magic-sparkles" style="font-size: 20px;"></i>
                        <h4 style="margin: 0; font-size: 16px; font-weight: 700;">AI Expense Processing Engine</h4>
                    </div>
                    <span class="ai-badge">
                        <i class="fa-solid fa-circle-dot"></i> Tesseract OCR + Isolation Forest
                    </span>
                </div>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-top: 16px;">
                    <div style="background: var(--card-bg); padding: 16px; border-radius: 12px; border: 1px solid var(--border-color);">
                        <span style="font-size: 12px; color: var(--text-muted); font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;">OCR Scanner</span>
                        <div style="font-weight: 700; font-size: 14px; margin-top: 6px; color: var(--text-main);">
                            <i class="fa-solid fa-file-lines" style="color: var(--primary);"></i> Tesseract OCR Engine
                        </div>
                    </div>

                    <div style="background: var(--card-bg); padding: 16px; border-radius: 12px; border: 1px solid var(--border-color);">
                        <span style="font-size: 12px; color: var(--text-muted); font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;">Category Prediction</span>
                        <div style="font-weight: 700; font-size: 14px; margin-top: 6px; color: var(--text-main);">
                            <i class="fa-solid fa-brain" style="color: var(--ai-purple);"></i> TF-IDF + Logistic Regression
                        </div>
                    </div>

                    <div style="background: var(--card-bg); padding: 16px; border-radius: 12px; border: 1px solid var(--border-color);">
                        <span style="font-size: 12px; color: var(--text-muted); font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;">Anomaly Detection</span>
                        <div style="font-weight: 700; font-size: 14px; margin-top: 6px; color: var(--text-main);">
                            <i class="fa-solid fa-shield-halved" style="color: #059669;"></i> Isolation Forest Model
                        </div>
                    </div>
                </div>
            </div>

            <!-- Main Dashboard Content Grid -->
            <div class="dashboard-grid">

                <div class="table-box">
                    <div class="box-header">
                        <h4 style="font-size: 16px; font-weight: 700;">Recent Submissions</h4>
                        <a href="${ctx}/employee/expenses" style="font-size: 13px; color: var(--primary); text-decoration: none; font-weight: 600;">View All <i class="fa-solid fa-arrow-right" style="font-size: 11px;"></i></a>
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
                                <c:forEach var="e" items="${recent}">
                                    <tr>
                                        <td>
                                            <a href="${ctx}/expense-details?id=${e.expenseId}" style="text-decoration: none; font-weight: 600; color: var(--primary);">${fn:escapeXml(e.title)}</a>
                                        </td>
                                        <td>${fn:escapeXml(e.categoryName)}</td>
                                        <td><strong>₹${e.amountDisplay}</strong></td>
                                        <td>${e.expenseDateDisplay}</td>
                                        <td>
                                            <jsp:include page="../components/_statusBadge.jsp">
                                                <jsp:param name="status" value="${e.status}" />
                                            </jsp:include>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty recent}">
                                    <tr>
                                        <td colspan="5" style="text-align: center; color: var(--text-muted); padding: 36px;">
                                            <i class="fa-solid fa-receipt" style="font-size: 32px; color: var(--border-color); margin-bottom: 10px; display: block;"></i>
                                            <span style="font-weight: 600;">No expenses submitted yet</span>
                                            <p style="font-size: 12px; margin-top: 4px;">Click “Submit New Expense” above to log your first claim.</p>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="table-box">
                    <div class="box-header">
                        <h4 style="font-size: 16px; font-weight: 700;">Category Breakdown</h4>
                    </div>
                    <div style="position: relative; height: 220px; display: flex; justify-content: center; align-items: center;">
                        <c:choose>
                            <c:when test="${chartHasData}">
                                <canvas id="expenseChart"></canvas>
                            </c:when>
                            <c:otherwise>
                                <span style="color: var(--text-muted); font-size: 13px;">No approved claims available for chart display.</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

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
                                boxWidth: 12,
                                padding: 15,
                                font: { family: 'Inter', size: 12 },
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
