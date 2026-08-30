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
    <title>AI Insights - ClaimSense AI</title>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/assets/css/style.css">
    <link rel="stylesheet" href="${ctx}/assets/css/responsive.css">

    <script src="${ctx}/assets/js/theme.js"></script>
</head>

<body>

<div class="dashboard">

    <jsp:include page="../components/sidebar.jsp"/>

    <main class="main">

        <jsp:include page="../components/navbar.jsp"/>

        <div class="content">

            <!-- HEADER -->
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 16px;">
                <div>
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 4px;">
                        <h2 style="font-size: 22px; font-weight: 800; margin: 0; letter-spacing: -0.4px;">AI Expense Insights</h2>
                        <span class="ai-badge" style="font-size: 11px; padding: 3px 10px;">
                            <i class="fa-solid fa-brain"></i> Machine Learning Intelligence
                        </span>
                    </div>
                    <p style="color: var(--text-muted); font-size: 13px; margin: 0;">
                        Automated OCR receipt extraction, ML category prediction, and Isolation Forest statistical evaluation.
                    </p>
                </div>
            </div>

            <!-- SUMMARY STATS -->
            <div class="cards-grid" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); margin-bottom: 24px; gap: 16px;">
                <div class="card-stat" style="border-left: 3px solid var(--success-dot);">
                    <div class="stat-icon approved"><i class="fa-solid fa-shield-check"></i></div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase;">Low Risk Claims</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: var(--text-main); margin-top: 2px;">${normalCount}</h2>
                    </div>
                </div>

                <div class="card-stat" style="border-left: 3px solid #D97706;">
                    <div class="stat-icon" style="background: rgba(245, 158, 11, 0.15); color: #D97706;"><i class="fa-solid fa-triangle-exclamation"></i></div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase;">Potential Anomalies</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: #D97706; margin-top: 2px;">${anomalyCount}</h2>
                    </div>
                </div>

                <div class="card-stat" style="border-left: 3px solid var(--primary);">
                    <div class="stat-icon" style="background: var(--primary-light); color: var(--primary);"><i class="fa-solid fa-circle-info"></i></div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase;">Insufficient Data</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: var(--text-main); margin-top: 2px;">${insufficientCount}</h2>
                    </div>
                </div>
            </div>

            <!-- EXPLANATION BANNER -->
            <div style="padding: 14px 16px; background: var(--pending-bg); border: 1px solid var(--pending-border); border-radius: 10px; font-size: 13px; color: var(--pending-text); margin-bottom: 24px; line-height: 1.5; display: flex; align-items: flex-start; gap: 12px;">
                <i class="fa-solid fa-circle-info" style="font-size: 16px; margin-top: 2px;"></i>
                <div>
                    <strong>Understanding AI Evaluations:</strong> ClaimSense AI calculates statistical baselines based on prior expense history. Expenses flagged as <em>Potential Anomaly</em> represent statistical deviations from standard employee limits and are highlighted for manager review.
                </div>
            </div>

            <!-- CLAIMS AI ANALYSIS TABLE -->
            <div class="table-box" style="margin-bottom: 32px;">
                <div class="box-header" style="margin-bottom: 16px;">
                    <h4 style="font-size: 15px; font-weight: 800;">Your Claim AI Analysis Records</h4>
                </div>

                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Claim ID</th>
                                <th>Expense Title</th>
                                <th>Category</th>
                                <th>Amount</th>
                                <th>ML Category Prediction</th>
                                <th>AI Risk Signal</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="e" items="${expenses}">
                                <c:set var="a" value="${analysisMap[e.expenseId]}" />
                                <tr>
                                    <td><strong style="color: var(--primary); font-size: 12px;">${e.claimCode}</strong></td>
                                    <td><span style="font-weight: 600; color: var(--text-main); font-size: 13px;">${fn:escapeXml(e.title)}</span></td>
                                    <td><span style="font-size: 13px; color: var(--text-main); font-weight: 500;">${fn:escapeXml(e.categoryName)}</span></td>
                                    <td><strong style="font-size: 13px; color: var(--text-main);">₹${e.amountDisplay}</strong></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty a and a.hasPrediction}">
                                                <span style="font-size: 12px; font-weight: 600; color: var(--ai-purple);">
                                                    <i class="fa-solid fa-brain"></i> ${fn:escapeXml(a.predictedCategory)} (${a.confidencePercent})
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="font-size: 12px; color: var(--text-muted);">Standard Category</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty a and a.anomaly}">
                                                <span class="badge-anomaly"><i class="fa-solid fa-triangle-exclamation"></i> Potential Anomaly</span>
                                            </c:when>
                                            <c:when test="${not empty a and a.anomalyStatus eq 'NORMAL'}">
                                                <span class="badge-low-risk"><i class="fa-solid fa-shield-check"></i> Low Risk</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-pending-scan"><i class="fa-solid fa-circle-info"></i> Insufficient Data</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <a href="${ctx}/expense-details?id=${e.expenseId}" class="btn-outline-custom" style="padding: 4px 10px; font-size: 12px; font-weight: 600; text-decoration: none;">
                                            Details
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty expenses}">
                                <tr>
                                    <td colspan="7" style="text-align: center; color: var(--text-muted); padding: 36px 16px;">
                                        No expense records found.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>

        <jsp:include page="../components/footer.jsp"/>

    </main>

</div>

<script src="${ctx}/assets/js/script.js"></script>

</body>

</html>
