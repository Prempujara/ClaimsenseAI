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
    <title>All Claims - ClaimSense AI</title>

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
                    <h2 style="font-size: 22px; font-weight: 800; margin: 0 0 2px; letter-spacing: -0.4px;">All Organization Claim Records</h2>
                    <p style="color: var(--text-muted); font-size: 13px; margin: 0;">
                        Complete organizational expense management workspace with multi-attribute filtering.
                    </p>
                </div>
                <span style="font-size: 12px; font-weight: 700; color: var(--primary); background: var(--primary-light); padding: 4px 12px; border-radius: 20px;">
                    Total: ${fn:length(all)} Claims
                </span>
            </div>

            <!-- FILTER TOOLBAR -->
            <div class="filter-bar" style="margin-bottom: 20px;">
                <div class="filter-input">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" id="allClaimsSearch" placeholder="Search claims by employee, title, category..." onkeyup="filterClaimsTable()">
                </div>
                <select id="allClaimsStatus" class="filter-select" onchange="filterClaimsTable()">
                    <option value="ALL">All Statuses</option>
                    <option value="PENDING">Pending Only</option>
                    <option value="APPROVED">Approved Only</option>
                    <option value="REJECTED">Rejected Only</option>
                </select>
                <select id="allClaimsRisk" class="filter-select" onchange="filterClaimsTable()">
                    <option value="ALL">All Risk Levels</option>
                    <option value="ANOMALY">Potential Anomalies</option>
                    <option value="NORMAL">Low Risk</option>
                </select>
            </div>

            <!-- ALL CLAIMS TABLE -->
            <div class="table-box" style="margin-bottom: 32px;">
                <div class="table-responsive">
                    <table class="custom-table" id="allClaimsDataTable">
                        <thead>
                            <tr>
                                <th>Claim ID</th>
                                <th>Employee</th>
                                <th>Expense Title</th>
                                <th>Category</th>
                                <th>Amount</th>
                                <th>Date</th>
                                <th>Status</th>
                                <th>AI Risk</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="e" items="${all}">
                                <c:set var="a" value="${analysisMap[e.expenseId]}" />
                                <c:set var="isAnomaly" value="${not empty a and a.anomaly}" />
                                <tr class="all-claim-row" data-status="${e.status}" data-risk="${isAnomaly ? 'ANOMALY' : 'NORMAL'}" data-text="${fn:toLowerCase(e.employeeName)} ${fn:toLowerCase(e.title)} ${fn:toLowerCase(e.categoryName)} ${e.claimCode}">
                                    <td><strong style="color: var(--primary); font-size: 12px;">${e.claimCode}</strong></td>
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
                                    <td>
                                        <c:choose>
                                            <c:when test="${isAnomaly}">
                                                <span class="badge-anomaly"><i class="fa-solid fa-triangle-exclamation"></i> Anomaly</span>
                                            </c:when>
                                            <c:when test="${not empty a and a.anomalyStatus eq 'NORMAL'}">
                                                <span class="badge-low-risk"><i class="fa-solid fa-shield-check"></i> Low Risk</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-pending-scan"><i class="fa-solid fa-circle-info"></i> Scanning</span>
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

                            <c:if test="${empty all}">
                                <tr>
                                    <td colspan="9" style="text-align: center; color: var(--text-muted); padding: 40px 16px;">
                                        No claim records found in system database.
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

<script>
    function filterClaimsTable() {
        const query = (document.getElementById("allClaimsSearch").value || "").toLowerCase().trim();
        const statusFilter = document.getElementById("allClaimsStatus").value;
        const riskFilter = document.getElementById("allClaimsRisk").value;

        const rows = document.querySelectorAll("#allClaimsDataTable tbody tr.all-claim-row");
        rows.forEach(row => {
            const rowText = row.getAttribute("data-text") || "";
            const rowStatus = row.getAttribute("data-status") || "";
            const rowRisk = row.getAttribute("data-risk") || "";

            const matchesText = !query || rowText.includes(query);
            const matchesStatus = statusFilter === "ALL" || rowStatus === statusFilter;
            const matchesRisk = riskFilter === "ALL" || rowRisk === riskFilter;

            row.style.display = (matchesText && matchesStatus && matchesRisk) ? "" : "none";
        });
    }
</script>

</body>

</html>
