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
    <title>AI Risk Center - ClaimSense AI</title>

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
                        <h2 style="font-size: 22px; font-weight: 800; margin: 0; letter-spacing: -0.4px;">AI Risk Center</h2>
                        <span class="ai-badge" style="font-size: 11px; padding: 3px 10px;">
                            <i class="fa-solid fa-shield-cat"></i> Isolation Forest Risk Model
                        </span>
                    </div>
                    <p style="color: var(--text-muted); font-size: 13px; margin: 0;">
                        Focused manager view of statistical anomalies, low-risk expenses, and model predictions.
                    </p>
                </div>
            </div>

            <!-- SUMMARY STATS -->
            <div class="cards-grid" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); margin-bottom: 24px; gap: 16px;">
                <div class="card-stat" style="border-left: 3px solid #D97706;">
                    <div class="stat-icon" style="background: rgba(245, 158, 11, 0.15); color: #D97706;"><i class="fa-solid fa-triangle-exclamation"></i></div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase;">Potential Anomalies</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: #D97706; margin-top: 2px;">${fn:length(anomalyClaims)}</h2>
                    </div>
                </div>

                <div class="card-stat" style="border-left: 3px solid var(--success-dot);">
                    <div class="stat-icon approved"><i class="fa-solid fa-shield-check"></i></div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase;">Low Risk Claims</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: var(--text-main); margin-top: 2px;">${fn:length(normalClaims)}</h2>
                    </div>
                </div>

                <div class="card-stat" style="border-left: 3px solid var(--primary);">
                    <div class="stat-icon" style="background: var(--primary-light); color: var(--primary);"><i class="fa-solid fa-circle-info"></i></div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase;">Insufficient Data</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: var(--text-main); margin-top: 2px;">${fn:length(insufficientClaims)}</h2>
                    </div>
                </div>
            </div>

            <!-- POTENTIAL ANOMALIES TABLE SECTION -->
            <div class="table-box" style="margin-bottom: 28px; border-top: 3px solid #D97706;">
                <div class="box-header" style="margin-bottom: 16px;">
                    <h4 style="font-size: 15px; font-weight: 800; color: #D97706;">
                        <i class="fa-solid fa-triangle-exclamation"></i> Potential Anomalies Requiring Attention
                    </h4>
                </div>

                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Employee</th>
                                <th>Expense Title</th>
                                <th>Category</th>
                                <th>Amount</th>
                                <th>Anomaly Score</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="e" items="${anomalyClaims}">
                                <c:set var="a" value="${analysisMap[e.expenseId]}" />
                                <tr>
                                    <td><span style="font-weight: 600; color: var(--text-main); font-size: 13px;">${fn:escapeXml(e.employeeName)}</span></td>
                                    <td>
                                        <strong style="color: var(--primary); font-size: 11px; display: block;">${e.claimCode}</strong>
                                        <span style="font-weight: 600; color: var(--text-main); font-size: 13px;">${fn:escapeXml(e.title)}</span>
                                    </td>
                                    <td><span style="font-size: 13px; color: var(--text-main); font-weight: 500;">${fn:escapeXml(e.categoryName)}</span></td>
                                    <td><strong style="font-size: 13px; color: var(--text-main);">₹${e.amountDisplay}</strong></td>
                                    <td>
                                        <span style="font-size: 12px; font-weight: 700; color: #D97706;">
                                            ${not empty a and not empty a.anomalyScore ? a.anomalyScore : 'Flagged'}
                                        </span>
                                    </td>
                                    <td>
                                        <jsp:include page="../components/_statusBadge.jsp">
                                            <jsp:param name="status" value="${e.status}" />
                                        </jsp:include>
                                    </td>
                                    <td>
                                        <a href="${ctx}/expense-details?id=${e.expenseId}" class="btn-outline-custom" style="padding: 4px 10px; font-size: 12px; font-weight: 600; text-decoration: none;">
                                            Review Claim
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty anomalyClaims}">
                                <tr>
                                    <td colspan="7" style="text-align: center; color: var(--text-muted); padding: 36px 16px;">
                                        <i class="fa-solid fa-shield-check" style="font-size: 24px; color: var(--success-dot); margin-bottom: 8px; display: block;"></i>
                                        <span style="font-size: 14px; font-weight: 700; color: var(--text-main); display: block; margin-bottom: 2px;">No Potential Anomalies Flagged</span>
                                        <span style="font-size: 12px; color: var(--text-muted);">All employee claims fall within standard historical spending baselines.</span>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- LOW RISK & INSUFFICIENT DATA LISTS -->
            <div class="table-box" style="margin-bottom: 32px;">
                <div class="box-header" style="margin-bottom: 16px;">
                    <h4 style="font-size: 15px; font-weight: 800;">Low Risk Verified Claims</h4>
                </div>

                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Employee</th>
                                <th>Expense Title</th>
                                <th>Category</th>
                                <th>Amount</th>
                                <th>Date</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="e" items="${normalClaims}">
                                <tr>
                                    <td><span style="font-weight: 600; color: var(--text-main); font-size: 13px;">${fn:escapeXml(e.employeeName)}</span></td>
                                    <td><span style="font-weight: 600; color: var(--text-main); font-size: 13px;">${fn:escapeXml(e.title)}</span></td>
                                    <td><span style="font-size: 13px; color: var(--text-main); font-weight: 500;">${fn:escapeXml(e.categoryName)}</span></td>
                                    <td><strong style="font-size: 13px; color: var(--text-main);">₹${e.amountDisplay}</strong></td>
                                    <td><span style="font-size: 12px; color: var(--text-muted);">${e.expenseDateDisplay}</span></td>
                                    <td>
                                        <jsp:include page="../components/_statusBadge.jsp">
                                            <jsp:param name="status" value="${e.status}" />
                                        </jsp:include>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty normalClaims}">
                                <tr>
                                    <td colspan="6" style="text-align: center; color: var(--text-muted); padding: 24px;">No claims recorded in low risk group.</td>
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
