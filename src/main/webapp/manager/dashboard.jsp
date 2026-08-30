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
    <title>Expense Overview & Approvals - ClaimSense AI</title>

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

            <!-- EXECUTIVE COMMAND CENTER HEADER -->
            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; flex-wrap: wrap; gap: 16px;">
                <div>
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 4px;">
                        <h2 style="font-size: 24px; font-weight: 800; margin: 0; letter-spacing: -0.4px;">Expense Overview</h2>
                        <span class="ai-badge" style="font-size: 11px; padding: 3px 10px;">
                            <i class="fa-solid fa-microchip"></i> ClaimSense AI
                        </span>
                    </div>
                    <p style="color: var(--text-muted); font-size: 13px; margin: 0;">
                        Monitor claims, spending and AI-detected risks.
                    </p>
                </div>
                <div>
                    <a href="#attentionSection" class="btn-primary-custom" style="padding: 9px 20px; font-size: 13px; font-weight: 700; text-decoration: none; border-radius: 9px;">
                        <i class="fa-solid fa-bell" style="margin-right: 6px;"></i> Review Pending Claims (${stats.pendingCount})
                    </a>
                </div>
            </div>

            <c:if test="${not empty param.ok}">
                <div class="alert" style="padding: 10px 14px; border-radius: 8px; background: var(--success-bg); color: var(--success-text); border: 1px solid var(--success-border); font-size: 13px; margin-bottom: 20px;">
                    <i class="fa-solid fa-circle-check"></i> ${fn:escapeXml(param.ok)}
                </div>
            </c:if>
            <c:if test="${not empty param.err}">
                <div class="alert alert-danger" style="padding: 10px 14px; border-radius: 8px; background: var(--danger-bg); color: var(--danger-text); border: 1px solid var(--danger-border); font-size: 13px; margin-bottom: 20px;">
                    <i class="fa-solid fa-triangle-exclamation"></i> ${fn:escapeXml(param.err)}
                </div>
            </c:if>

            <!-- SECTION 1 — KPI ROW (PRIORITIZED HIERARCHY) -->
            <div class="cards-grid" style="grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); margin-bottom: 24px; gap: 16px;">
                <!-- Total Value (Primary Hero Metric) -->
                <div class="card-stat" style="border-left: 3px solid var(--primary);">
                    <div class="stat-icon total"><i class="fa-solid fa-indian-rupee-sign"></i></div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase;">Total Value</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: var(--primary); margin-top: 2px;">₹${stats.totalAmountDisplay}</h2>
                    </div>
                </div>

                <!-- Pending Review -->
                <div class="card-stat" style="border-left: 3px solid #F59E0B;">
                    <div class="stat-icon pending"><i class="fa-solid fa-hourglass-half"></i></div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase;">Pending Review</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: #D97706; margin-top: 2px;">${stats.pendingCount}</h2>
                    </div>
                </div>

                <!-- Potential Anomalies -->
                <div class="card-stat" style="border-left: 3px solid #D97706;">
                    <div class="stat-icon" style="background: rgba(245, 158, 11, 0.15); color: #D97706;"><i class="fa-solid fa-shield-cat"></i></div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase;">Potential Anomalies</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: #D97706; margin-top: 2px;">${anomalyCount}</h2>
                    </div>
                </div>

                <!-- Total Claims -->
                <div class="card-stat">
                    <div class="stat-icon" style="background: var(--table-header-bg); color: var(--text-main);"><i class="fa-solid fa-file-invoice"></i></div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase;">Total Claims</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: var(--text-main); margin-top: 2px;">${stats.totalCount}</h2>
                    </div>
                </div>

                <!-- Approved -->
                <div class="card-stat" style="border-left: 3px solid var(--success-dot);">
                    <div class="stat-icon approved"><i class="fa-solid fa-circle-check"></i></div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase;">Approved</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: var(--text-main); margin-top: 2px;">${stats.approvedCount}</h2>
                    </div>
                </div>

                <!-- Rejected -->
                <div class="card-stat" style="border-left: 3px solid var(--danger-dot);">
                    <div class="stat-icon rejected"><i class="fa-solid fa-circle-xmark"></i></div>
                    <div class="stat-info">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase;">Rejected</span>
                        <h2 style="font-size: 22px; font-weight: 800; color: var(--text-main); margin-top: 2px;">${stats.rejectedCount}</h2>
                    </div>
                </div>
            </div>

            <!-- SECTION 2 — ATTENTION REQUIRED (ACTIONABLE PRIORITY QUEUE) -->
            <div id="attentionSection" class="table-box" style="margin-bottom: 24px;">
                <div class="box-header" style="margin-bottom: 16px;">
                    <div>
                        <h4 style="font-size: 15px; font-weight: 800; margin: 0;">Attention Required</h4>
                        <span style="font-size: 12px; color: var(--text-muted);">Prioritized claims requiring manager review & action</span>
                    </div>
                    <span style="font-size: 11px; font-weight: 700; color: var(--primary); background: var(--primary-light); padding: 3px 10px; border-radius: 20px;">
                        ${stats.pendingCount} Pending Decision
                    </span>
                </div>

                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Priority</th>
                                <th>Employee</th>
                                <th>Expense Title</th>
                                <th>Category</th>
                                <th>Amount</th>
                                <th>AI Risk Assessment</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="e" items="${pending}">
                                <c:set var="a" value="${analysisMap[e.expenseId]}" />
                                <c:set var="isAnomaly" value="${not empty a and a.anomaly}" />
                                <tr>
                                    <td>
                                        <c:choose>
                                            <c:when test="${isAnomaly}">
                                                <span class="priority-rank-badge priority-rank-1"><i class="fa-solid fa-triangle-exclamation"></i> P1 Anomaly</span>
                                            </c:when>
                                            <c:when test="${e.amount >= 10000}">
                                                <span class="priority-rank-badge priority-rank-2"><i class="fa-solid fa-arrow-up-right-dots"></i> P2 High Value</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="priority-rank-badge priority-rank-3">P3 Standard</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span style="font-weight: 600; color: var(--text-main); font-size: 13px;">${fn:escapeXml(e.employeeName)}</span>
                                    </td>
                                    <td>
                                        <strong style="color: var(--primary); font-size: 12px; display: block;">${e.claimCode}</strong>
                                        <span style="font-weight: 600; color: var(--text-main); font-size: 13px;">${fn:escapeXml(e.title)}</span>
                                    </td>
                                    <td><span style="font-size: 13px; color: var(--text-main); font-weight: 500;">${fn:escapeXml(e.categoryName)}</span></td>
                                    <td><strong style="font-size: 13px; color: var(--text-main);">₹${e.amountDisplay}</strong></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${isAnomaly}">
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
                                        <jsp:include page="../components/_statusBadge.jsp">
                                            <jsp:param name="status" value="${e.status}" />
                                        </jsp:include>
                                    </td>
                                    <td>
                                        <div style="display: flex; gap: 6px; flex-wrap: wrap;">
                                            <a href="${ctx}/expense-details?id=${e.expenseId}" class="btn-outline-custom" style="padding: 4px 10px; font-size: 12px; font-weight: 600; text-decoration: none;">
                                                Review
                                            </a>
                                            <form action="${ctx}/ApproveRejectServlet" method="POST" style="display: inline;" onsubmit="return confirm('Approve claim ${e.claimCode}?');">
                                                <input type="hidden" name="action" value="APPROVE">
                                                <input type="hidden" name="expenseId" value="${e.expenseId}">
                                                <button class="btn-success-custom" type="submit" style="padding: 4px 10px; font-size: 12px; font-weight: 600;">Approve</button>
                                            </form>
                                            <button class="btn-danger-custom" type="button" onclick="openRejectModal(${e.expenseId}, '${e.claimCode}', '${fn:escapeXml(e.employeeName)}')" style="padding: 4px 10px; font-size: 12px; font-weight: 600;">
                                                Reject
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty pending}">
                                <tr>
                                    <td colspan="8" style="text-align: center; color: var(--text-muted); padding: 36px 16px;">
                                        <i class="fa-solid fa-circle-check" style="font-size: 24px; color: var(--success-dot); margin-bottom: 8px; display: block;"></i>
                                        <span style="font-size: 14px; font-weight: 700; color: var(--text-main); display: block; margin-bottom: 2px;">You're all caught up!</span>
                                        <span style="font-size: 12px; color: var(--text-muted);">No pending employee claims require decision right now.</span>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- SECTION 3 & SECTION 4 — SPENDING OVERVIEW & CLAIM STATUS CHARTS -->
            <div id="analyticsSection" class="dashboard-grid" style="margin-bottom: 24px; gap: 20px;">
                
                <!-- SECTION 3: SPENDING OVERVIEW -->
                <div class="table-box" style="margin: 0;">
                    <div class="box-header" style="margin-bottom: 16px;">
                        <h4 style="font-size: 15px; font-weight: 800;">Spending Overview</h4>
                    </div>
                    <div style="position: relative; width: 100%; height: 240px;">
                        <c:choose>
                            <c:when test="${chartHasData}">
                                <canvas id="spendingCategoryChart"></canvas>
                            </c:when>
                            <c:otherwise>
                                <div style="text-align: center; color: var(--text-muted); padding: 36px;">
                                    <i class="fa-solid fa-chart-bar" style="font-size: 28px; color: var(--border-color); margin-bottom: 8px; display: block;"></i>
                                    <span style="font-size: 13px; font-weight: 600; color: var(--text-main); display: block;">No Category Data</span>
                                    <span style="font-size: 11px; color: var(--text-muted);">Expense category totals will render here automatically.</span>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- SECTION 4: CLAIM STATUS DISTRIBUTION -->
                <div class="table-box" style="margin: 0;">
                    <div class="box-header" style="margin-bottom: 16px;">
                        <h4 style="font-size: 15px; font-weight: 800;">Claim Status Distribution</h4>
                    </div>
                    <div style="position: relative; width: 100%; height: 240px;">
                        <c:choose>
                            <c:when test="${stats.totalCount > 0}">
                                <canvas id="statusDistributionChart"></canvas>
                            </c:when>
                            <c:otherwise>
                                <div style="text-align: center; color: var(--text-muted); padding: 36px;">
                                    <i class="fa-solid fa-chart-pie" style="font-size: 28px; color: var(--border-color); margin-bottom: 8px; display: block;"></i>
                                    <span style="font-size: 13px; font-weight: 600; color: var(--text-main); display: block;">No Claims Submitted</span>
                                    <span style="font-size: 11px; color: var(--text-muted);">Status ratio will visualize as claims are submitted.</span>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

            </div>

            <!-- SECTION 5 — AI RISK CENTER -->
            <div id="aiRiskCenter" class="table-box" style="margin-bottom: 24px; border-top: 3px solid #D97706;">
                <div class="box-header" style="margin-bottom: 16px;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-shield-cat" style="color: #D97706; font-size: 18px;"></i>
                        <div>
                            <h4 style="font-size: 15px; font-weight: 800; margin: 0;">AI Risk Center</h4>
                            <span style="font-size: 12px; color: var(--text-muted);">Isolation Forest risk evaluation & statistical anomaly signals</span>
                        </div>
                    </div>
                    <span class="badge-anomaly" style="font-size: 11px;">
                        <i class="fa-solid fa-triangle-exclamation"></i> ${anomalyCount} Potential Anomalies
                    </span>
                </div>

                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Employee</th>
                                <th>Expense Title</th>
                                <th>Category</th>
                                <th>Amount</th>
                                <th>AI Risk Assessment</th>
                                <th>Date</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:set var="hasAnomaly" value="false" />
                            <c:forEach var="e" items="${all}">
                                <c:set var="a" value="${analysisMap[e.expenseId]}" />
                                <c:if test="${not empty a and a.anomaly}">
                                    <c:set var="hasAnomaly" value="true" />
                                    <tr>
                                        <td><span style="font-weight: 600; color: var(--text-main); font-size: 13px;">${fn:escapeXml(e.employeeName)}</span></td>
                                        <td>
                                            <strong style="color: var(--primary); font-size: 11px; display: block;">${e.claimCode}</strong>
                                            <span style="font-weight: 600; color: var(--text-main); font-size: 13px;">${fn:escapeXml(e.title)}</span>
                                        </td>
                                        <td><span style="font-size: 13px; color: var(--text-main); font-weight: 500;">${fn:escapeXml(e.categoryName)}</span></td>
                                        <td><strong style="font-size: 13px; color: var(--text-main);">₹${e.amountDisplay}</strong></td>
                                        <td>
                                            <span class="badge-anomaly"><i class="fa-solid fa-triangle-exclamation"></i> Potential Anomaly</span>
                                        </td>
                                        <td><span style="font-size: 12px; color: var(--text-muted);">${e.expenseDateDisplay}</span></td>
                                        <td>
                                            <a href="${ctx}/expense-details?id=${e.expenseId}" class="btn-outline-custom" style="padding: 4px 10px; font-size: 12px; font-weight: 600; text-decoration: none;">
                                                Review
                                            </a>
                                        </td>
                                    </tr>
                                </c:if>
                            </c:forEach>

                            <c:if test="${not hasAnomaly}">
                                <tr>
                                    <td colspan="7" style="text-align: center; color: var(--text-muted); padding: 36px 16px;">
                                        <i class="fa-solid fa-shield-check" style="font-size: 24px; color: var(--success-dot); margin-bottom: 8px; display: block;"></i>
                                        <span style="font-size: 14px; font-weight: 700; color: var(--text-main); display: block; margin-bottom: 2px;">No Potential Anomalies Flagged</span>
                                        <span style="font-size: 12px; color: var(--text-muted);">All employee claims fall within historical spending baselines.</span>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- SECTION 6 & SECTION 7 — TOP CATEGORIES & EMPLOYEE INSIGHTS -->
            <div class="dashboard-grid" style="margin-bottom: 24px; gap: 20px;">

                <!-- SECTION 6: TOP SPENDING CATEGORIES -->
                <div class="table-box" style="margin: 0;">
                    <div class="box-header" style="margin-bottom: 16px;">
                        <h4 style="font-size: 15px; font-weight: 800;">Top Spending Categories</h4>
                    </div>
                    <div id="dynamicCategoryBars">
                        <!-- Populated by JS -->
                    </div>
                </div>

                <!-- SECTION 7: EMPLOYEE EXPENSE INSIGHTS -->
                <div class="table-box" style="margin: 0;">
                    <div class="box-header" style="margin-bottom: 16px;">
                        <h4 style="font-size: 15px; font-weight: 800;">Employee Expense Insights</h4>
                    </div>
                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Employee</th>
                                    <th>Claims</th>
                                    <th>Total Value</th>
                                    <th>Pending</th>
                                </tr>
                            </thead>
                            <tbody id="employeeInsightsBody">
                                <!-- Populated by JS -->
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>

            <!-- SECTION 8 & SECTION 9 — RECENT ACTIVITY & ALL CLAIM RECORDS -->
            <div class="dashboard-grid" style="grid-template-columns: 1fr 2fr; margin-bottom: 32px; gap: 20px;">

                <!-- SECTION 8: RECENT ACTIVITY -->
                <div class="table-box" style="margin: 0;">
                    <div class="box-header" style="margin-bottom: 16px;">
                        <h4 style="font-size: 15px; font-weight: 800;">Recent Activity</h4>
                    </div>
                    <div class="timeline-list">
                        <c:forEach var="e" items="${all}" end="4">
                            <div class="timeline-row">
                                <c:choose>
                                    <c:when test="${e.status eq 'APPROVED'}">
                                        <div class="timeline-icon-dot approve"><i class="fa-solid fa-check"></i></div>
                                    </c:when>
                                    <c:when test="${e.status eq 'REJECTED'}">
                                        <div class="timeline-icon-dot reject"><i class="fa-solid fa-xmark"></i></div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="timeline-icon-dot submit"><i class="fa-solid fa-paper-plane"></i></div>
                                    </c:otherwise>
                                </c:choose>
                                <div style="flex: 1;">
                                    <div style="display: flex; justify-content: space-between; align-items: center;">
                                        <span style="font-size: 12px; font-weight: 700; color: var(--text-main);">${fn:escapeXml(e.employeeName)}</span>
                                        <span style="font-size: 11px; color: var(--text-muted);">${e.expenseDateDisplay}</span>
                                    </div>
                                    <p style="font-size: 11px; color: var(--text-muted); margin: 2px 0 0;">
                                        ${e.status eq 'APPROVED' ? 'Approved' : (e.status eq 'REJECTED' ? 'Rejected' : 'Submitted')} <strong>${fn:escapeXml(e.title)}</strong> (₹${e.amountDisplay})
                                    </p>
                                </div>
                            </div>
                        </c:forEach>
                        <c:if test="${empty all}">
                            <span style="font-size: 12px; color: var(--text-muted);">No activity recorded yet.</span>
                        </c:if>
                    </div>
                </div>

                <!-- SECTION 9: ALL CLAIM RECORDS -->
                <div id="allClaimsSection" class="table-box" style="margin: 0;">
                    <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; margin-bottom: 16px;">
                        <h4 style="font-size: 15px; font-weight: 800; margin: 0;">All Claim Records</h4>
                        
                        <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                            <input type="text" id="allClaimsSearch" class="input" placeholder="Search claims..." style="height: 36px; padding-left: 12px; font-size: 12px; width: 180px; margin: 0;" onkeyup="filterAllClaims()">
                            <select id="allClaimsStatus" class="filter-select" style="height: 36px; padding: 0 10px; font-size: 12px;" onchange="filterAllClaims()">
                                <option value="ALL">All Statuses</option>
                                <option value="PENDING">Pending</option>
                                <option value="APPROVED">Approved</option>
                                <option value="REJECTED">Rejected</option>
                            </select>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table class="custom-table" id="allClaimsTable">
                            <thead>
                                <tr>
                                    <th>Employee</th>
                                    <th>Claim ID</th>
                                    <th>Title</th>
                                    <th>Category</th>
                                    <th>Amount</th>
                                    <th>Date</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="e" items="${all}">
                                    <tr class="all-claim-row" data-status="${e.status}" data-text="${fn:toLowerCase(fn:escapeXml(e.employeeName))} ${fn:toLowerCase(fn:escapeXml(e.title))} ${fn:toLowerCase(fn:escapeXml(e.categoryName))} ${e.claimCode}">
                                        <td><span style="font-weight: 600; color: var(--text-main); font-size: 12px;">${fn:escapeXml(e.employeeName)}</span></td>
                                        <td><strong style="color: var(--primary); font-size: 12px;">${e.claimCode}</strong></td>
                                        <td><span style="font-weight: 600; color: var(--text-main); font-size: 12px;">${fn:escapeXml(e.title)}</span></td>
                                        <td><span style="font-size: 12px; color: var(--text-main); font-weight: 500;">${fn:escapeXml(e.categoryName)}</span></td>
                                        <td><strong style="font-size: 12px; color: var(--text-main);">₹${e.amountDisplay}</strong></td>
                                        <td><span style="font-size: 12px; color: var(--text-muted);">${e.expenseDateDisplay}</span></td>
                                        <td>
                                            <jsp:include page="../components/_statusBadge.jsp">
                                                <jsp:param name="status" value="${e.status}" />
                                            </jsp:include>
                                        </td>
                                        <td>
                                            <a href="${ctx}/expense-details?id=${e.expenseId}" class="btn-outline-custom" style="padding: 4px 10px; font-size: 12px; font-weight: 600; text-decoration: none;">
                                                Details
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty all}">
                                    <tr>
                                        <td colspan="8" style="text-align: center; color: var(--text-muted); padding: 30px 16px;">
                                            No claim records found in database.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>

        </div>

        <jsp:include page="../components/footer.jsp"/>

    </main>

</div>

<!-- REJECTION REMARKS MODAL -->
<div id="rejectModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(15,23,42,0.7); z-index: 1000; align-items: center; justify-content: center; backdrop-filter: blur(4px);">
    <div style="background: var(--card-bg); border: 1px solid var(--border-color); padding: 24px; border-radius: 14px; width: 100%; max-width: 440px; box-shadow: var(--shadow-lg);">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <h4 style="margin: 0; font-weight: 800; color: var(--danger-text); font-size: 16px;"><i class="fa-solid fa-circle-xmark"></i> Reject Expense Claim</h4>
            <button type="button" onclick="closeRejectModal()" style="background: none; border: none; font-size: 18px; cursor: pointer; color: var(--text-muted);">&times;</button>
        </div>

        <form action="${ctx}/ApproveRejectServlet" method="POST">
            <input type="hidden" name="action" value="REJECT">
            <input type="hidden" name="expenseId" id="modalExpenseId">

            <p style="font-size: 13px; color: var(--text-muted); margin-bottom: 16px; line-height: 1.5;">
                Rejecting claim <strong id="displayClaimId" style="color: var(--text-main);"></strong> for <strong id="displayEmployee" style="color: var(--text-main);"></strong>. Please provide rejection remarks:
            </p>

            <div class="form-group" style="margin-bottom: 20px;">
                <label for="rejectionRemarks">Rejection Remarks <span style="color: var(--danger-text);">*</span></label>
                <textarea class="form-control" id="rejectionRemarks" name="remarks" rows="3" placeholder="Provide clear rejection rationale..." required></textarea>
            </div>

            <div style="display: flex; gap: 10px; justify-content: flex-end; padding-top: 14px; border-top: 1px solid var(--border-color);">
                <button type="button" class="btn-outline-custom" onclick="closeRejectModal()" style="padding: 8px 16px; font-size: 13px;">Cancel</button>
                <button type="submit" class="btn-danger-custom" style="padding: 8px 18px; font-size: 13px; font-weight: 700;">Confirm Rejection</button>
            </div>
        </form>
    </div>
</div>

<script src="${ctx}/assets/js/script.js"></script>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        initSpendingChart();
        initStatusChart();
        buildEmployeeInsights();
        buildCategoryProgressBars();
    });

    function getThemeTextColor() {
        return window.ClaimSenseTheme && window.ClaimSenseTheme.getTheme() === 'dark' ? '#94A3B8' : '#64748B';
    }

    let spendingChartInstance = null;
    let statusChartInstance = null;

    // SECTION 3: Spending Overview Chart.js
    function initSpendingChart() {
        const canvas = document.getElementById("spendingCategoryChart");
        if (!canvas) return;

        try {
            const labels = ${chartHasData ? chartLabels : '[]'};
            const dataVals = ${chartHasData ? chartData : '[]'};

            if (!labels || labels.length === 0) return;

            spendingChartInstance = new Chart(canvas, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Total Spend (₹)',
                        data: dataVals,
                        backgroundColor: '#4F46E5',
                        borderRadius: 6
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        x: { ticks: { color: getThemeTextColor(), font: { size: 11 } }, grid: { display: false } },
                        y: { ticks: { color: getThemeTextColor(), font: { size: 11 } }, grid: { color: 'rgba(226,232,240,0.5)' } }
                    }
                }
            });
        } catch(e) {
            console.error("Spending Chart init error:", e);
        }
    }

    // SECTION 4: Claim Status Distribution Donut Chart
    function initStatusChart() {
        const canvas = document.getElementById("statusDistributionChart");
        if (!canvas) return;

        try {
            const pending = ${not empty stats and not empty stats.pendingCount ? stats.pendingCount : 0};
            const approved = ${not empty stats and not empty stats.approvedCount ? stats.approvedCount : 0};
            const rejected = ${not empty stats and not empty stats.rejectedCount ? stats.rejectedCount : 0};

            statusChartInstance = new Chart(canvas, {
                type: 'doughnut',
                data: {
                    labels: ['Pending Review', 'Approved Claims', 'Rejected Claims'],
                    datasets: [{
                        data: [pending, approved, rejected],
                        backgroundColor: ['#F59E0B', '#10B981', '#EF4444'],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'bottom', labels: { color: getThemeTextColor(), font: { size: 11 }, boxWidth: 10 } }
                    }
                }
            });
        } catch(e) {
            console.error("Status Chart init error:", e);
        }
    }

    // Theme Switch Event Listener
    window.addEventListener('claimsense-theme-changed', function(e) {
        if (spendingChartInstance) spendingChartInstance.update();
        if (statusChartInstance) statusChartInstance.update();
    });

    // SECTION 6: Top Spending Category Bars
    function buildCategoryProgressBars() {
        const container = document.getElementById("dynamicCategoryBars");
        if (!container) return;

        try {
            const labels = ${chartHasData ? chartLabels : '[]'};
            const dataVals = ${chartHasData ? chartData : '[]'};
            if (!labels || labels.length === 0) {
                container.innerHTML = '<span style="color: var(--text-muted); font-size: 12px;">No spending category data recorded.</span>';
                return;
            }

            const totalSum = dataVals.reduce(function(a, b) { return a + b; }, 0);
            let html = '';

            for (let i = 0; i < labels.length; i++) {
                const pct = totalSum > 0 ? Math.round((dataVals[i] / totalSum) * 100) : 0;
                const amtStr = dataVals[i].toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                html += '<div style="margin-bottom: 12px;">'
                    + '<div style="display: flex; justify-content: space-between; align-items: center; font-size: 12px; font-weight: 600; margin-bottom: 4px;">'
                    + '<span style="color: var(--text-main);">' + labels[i] + '</span>'
                    + '<span style="color: var(--primary);">₹' + amtStr + ' <span style="font-size: 10px; color: var(--text-muted);">(' + pct + '%)</span></span>'
                    + '</div>'
                    + '<div class="cat-progress-track">'
                    + '<div class="cat-progress-fill" style="width: ' + pct + '%;"></div>'
                    + '</div>'
                    + '</div>';
            }
            container.innerHTML = html;
        } catch(e) {
            console.error("Category bars init error:", e);
        }
    }

    // SECTION 7: Employee Expense Insights Table
    function buildEmployeeInsights() {
        const tbody = document.getElementById("employeeInsightsBody");
        if (!tbody) return;

        try {
            const employeeMap = {};
            <c:forEach var="e" items="${all}">
                (function() {
                    const empName = "<c:out value='${e.employeeName}' />";
                    const amt = ${not empty e.amount ? e.amount : 0};
                    const status = "${e.status}";

                    if (empName) {
                        if (!employeeMap[empName]) {
                            employeeMap[empName] = { name: empName, count: 0, total: 0, pending: 0 };
                        }
                        employeeMap[empName].count++;
                        employeeMap[empName].total += amt;
                        if (status === 'PENDING') employeeMap[empName].pending++;
                    }
                })();
            </c:forEach>

            const employees = Object.values(employeeMap);
            if (employees.length === 0) {
                tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: var(--text-muted); padding: 20px;">No employee data recorded.</td></tr>';
                return;
            }

            employees.sort(function(a, b) { return b.total - a.total; });

            let html = '';
            employees.slice(0, 5).forEach(function(emp) {
                const formattedTotal = emp.total.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                const pendingHtml = emp.pending > 0 
                    ? '<span style="color: #D97706; font-weight: 700;">' + emp.pending + '</span>' 
                    : '<span style="color: var(--text-muted);">0</span>';

                html += '<tr>'
                    + '<td><span style="font-weight: 600; color: var(--text-main); font-size: 12px;">' + emp.name + '</span></td>'
                    + '<td><strong>' + emp.count + '</strong></td>'
                    + '<td><strong style="color: var(--text-main);">₹' + formattedTotal + '</strong></td>'
                    + '<td>' + pendingHtml + '</td>'
                    + '</tr>';
            });
            tbody.innerHTML = html;
        } catch(e) {
            console.error("Employee insights init error:", e);
        }
    }

    // SECTION 9: All Claims Filter & Search
    function filterAllClaims() {
        const query = (document.getElementById("allClaimsSearch").value || "").toLowerCase().trim();
        const statusFilter = document.getElementById("allClaimsStatus").value;

        const rows = document.querySelectorAll("#allClaimsTable tbody tr.all-claim-row");
        rows.forEach(row => {
            const rowText = row.getAttribute("data-text") || "";
            const rowStatus = row.getAttribute("data-status") || "";

            const matchesText = !query || rowText.includes(query);
            const matchesStatus = statusFilter === "ALL" || rowStatus === statusFilter;

            row.style.display = (matchesText && matchesStatus) ? "" : "none";
        });
    }

    // Modal Handlers
    function openRejectModal(expenseId, claimCode, employee) {
        document.getElementById('modalExpenseId').value = expenseId;
        document.getElementById('displayClaimId').innerText = claimCode;
        document.getElementById('displayEmployee').innerText = employee;
        document.getElementById('rejectModal').style.display = 'flex';
    }
    function closeRejectModal() {
        document.getElementById('rejectModal').style.display = 'none';
    }
</script>

</body>

</html>

