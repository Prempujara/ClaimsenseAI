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
    <title>Manager Approval History - ClaimSense AI</title>

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
                    <h2 style="font-size: 22px; font-weight: 800; margin: 0 0 2px; letter-spacing: -0.4px;">Manager Approval & Rejection History</h2>
                    <p style="color: var(--text-muted); font-size: 13px; margin: 0;">
                        Complete organizational audit trail of all processed employee claim decisions.
                    </p>
                </div>
            </div>

            <!-- APPROVAL HISTORY TABLE -->
            <div class="table-box" style="margin-bottom: 32px;">
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Claim ID</th>
                                <th>Employee</th>
                                <th>Expense Title</th>
                                <th>Category</th>
                                <th>Amount</th>
                                <th>Submission Date</th>
                                <th>Decision Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="e" items="${processed}">
                                <tr>
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
                                        <a href="${ctx}/expense-details?id=${e.expenseId}" class="btn-outline-custom" style="padding: 4px 10px; font-size: 12px; font-weight: 600; text-decoration: none;">
                                            Audit Details
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty processed}">
                                <tr>
                                    <td colspan="8" style="text-align: center; color: var(--text-muted); padding: 36px 16px;">
                                        <i class="fa-solid fa-clock-rotate-left" style="font-size: 24px; color: var(--border-color); margin-bottom: 8px; display: block;"></i>
                                        <span style="font-size: 14px; font-weight: 700; color: var(--text-main); display: block; margin-bottom: 2px;">No Processed History Records</span>
                                        <span style="font-size: 12px; color: var(--text-muted);">Decided claims (Approved / Rejected) will list here.</span>
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
