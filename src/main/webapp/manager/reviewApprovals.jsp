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
    <title>Review & Approvals - ClaimSense AI</title>

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
                    <h2 style="font-size: 22px; font-weight: 800; margin: 0 0 2px; letter-spacing: -0.4px;">Pending Claims Review Queue</h2>
                    <p style="color: var(--text-muted); font-size: 13px; margin: 0;">
                        Dedicated manager workspace for pending employee expense claim reviews.
                    </p>
                </div>
                <span style="font-size: 12px; font-weight: 700; color: var(--primary); background: var(--primary-light); padding: 4px 12px; border-radius: 20px;">
                    ${fn:length(pending)} Claims Requiring Decision
                </span>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger" style="padding: 10px 14px; border-radius: 8px; background: var(--danger-bg); color: var(--danger-text); border: 1px solid var(--danger-border); font-size: 13px; margin-bottom: 20px;">
                    <i class="fa-solid fa-triangle-exclamation"></i> ${fn:escapeXml(error)}
                </div>
            </c:if>

            <div class="table-box" style="margin-bottom: 32px;">
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
                                    <td><span style="font-weight: 600; color: var(--text-main); font-size: 13px;">${fn:escapeXml(e.employeeName)}</span></td>
                                    <td>
                                        <strong style="color: var(--primary); font-size: 11px; display: block;">${e.claimCode}</strong>
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
                                    <td colspan="8" style="text-align: center; color: var(--text-muted); padding: 40px 16px;">
                                        <i class="fa-solid fa-circle-check" style="font-size: 24px; color: var(--success-dot); margin-bottom: 8px; display: block;"></i>
                                        <span style="font-size: 14px; font-weight: 700; color: var(--text-main); display: block; margin-bottom: 2px;">No Pending Claims Requiring Review</span>
                                        <span style="font-size: 12px; color: var(--text-muted);">All employee submissions have been processed.</span>
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
                Rejecting claim <strong id="displayClaimId" style="color: var(--text-main);"></strong> for <strong id="displayEmployee" style="color: var(--text-main);"></strong>. Please state rejection remarks:
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
