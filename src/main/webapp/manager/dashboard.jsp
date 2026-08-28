<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Manager Review & Approvals - ClaimSense AI</title>

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

            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 28px; flex-wrap: wrap; gap: 16px;">
                <div>
                    <h2 style="font-size: 24px; font-weight: 800; margin-bottom: 4px; letter-spacing: -0.4px;">Manager Review & Approvals</h2>
                    <p style="color: var(--text-muted); font-size: 14px; margin: 0;">
                        Review submitted employee claims, evaluate Isolation Forest AI risk signals, and approve or reject submissions.
                    </p>
                </div>
                <div class="ai-badge" style="font-size: 12px; padding: 8px 14px; font-weight: 600;">
                    <i class="fa-solid fa-shield-halved"></i> AI Fraud & Anomaly Engine Active
                </div>
            </div>

            <c:if test="${not empty param.ok}">
                <div class="alert" style="padding: 12px 16px; border-radius: 10px; background: var(--success-bg); color: var(--success-text); border: 1px solid var(--success-border); font-size: 13px; margin-bottom: 24px;"><i class="fa-solid fa-circle-check"></i> ${fn:escapeXml(param.ok)}</div>
            </c:if>
            <c:if test="${not empty param.err}">
                <div class="alert alert-danger" style="padding: 12px 16px; border-radius: 10px; background: var(--danger-bg); color: var(--danger-text); border: 1px solid var(--danger-border); font-size: 13px; margin-bottom: 24px;"><i class="fa-solid fa-triangle-exclamation"></i> ${fn:escapeXml(param.err)}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger" style="padding: 12px 16px; border-radius: 10px; background: var(--danger-bg); color: var(--danger-text); border: 1px solid var(--danger-border); font-size: 13px; margin-bottom: 24px;">${fn:escapeXml(error)}</div>
            </c:if>

            <!-- Stats Grid -->
            <div class="cards-grid">
                <div class="card-stat">
                    <div class="stat-icon total"><i class="fa-solid fa-file-invoice-dollar"></i></div>
                    <div class="stat-info"><span>Total Submissions</span><h2>${stats.totalCount}</h2></div>
                </div>
                <div class="card-stat">
                    <div class="stat-icon pending"><i class="fa-solid fa-clock-rotate-left"></i></div>
                    <div class="stat-info"><span>Action Required</span><h2>${stats.pendingCount}</h2></div>
                </div>
                <div class="card-stat">
                    <div class="stat-icon approved"><i class="fa-solid fa-circle-check"></i></div>
                    <div class="stat-info"><span>Approved Claims</span><h2>${stats.approvedCount}</h2></div>
                </div>
                <div class="card-stat">
                    <div class="stat-icon rejected"><i class="fa-solid fa-circle-xmark"></i></div>
                    <div class="stat-info"><span>Rejected Claims</span><h2>${stats.rejectedCount}</h2></div>
                </div>
            </div>

            <!-- Pending Approvals Table -->
            <div class="table-box">
                <div class="box-header">
                    <h4 style="font-size: 16px; font-weight: 700;">Submitted Claims Requiring Review</h4>
                </div>

                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Employee</th>
                                <th>Claim ID</th>
                                <th>Expense Title</th>
                                <th>Category</th>
                                <th>Amount</th>
                                <th>AI Risk Assessment</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="e" items="${pending}">
                                <c:set var="a" value="${analysisMap[e.expenseId]}" />
                                <tr>
                                    <td>
                                        <div style="display: flex; align-items: center; gap: 10px;">
                                            <div class="user-avatar" style="width: 30px; height: 30px; font-size: 12px; font-weight: 700;">${fn:toUpperCase(fn:substring(e.employeeName, 0, 1))}</div>
                                            <span style="font-weight: 600; color: var(--text-main);">${fn:escapeXml(e.employeeName)}</span>
                                        </div>
                                    </td>
                                    <td><strong style="color: var(--primary);">${e.claimCode}</strong></td>
                                    <td><span style="font-weight: 500;">${fn:escapeXml(e.title)}</span></td>
                                    <td>${fn:escapeXml(e.categoryName)}</td>
                                    <td><strong>₹${e.amountDisplay}</strong></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty a and a.anomaly}">
                                                <span class="badge-status pending" style="font-size: 11px; background: var(--pending-bg); color: var(--pending-text); border: 1px solid var(--pending-border);">
                                                    <i class="fa-solid fa-triangle-exclamation"></i> Potential Anomaly
                                                </span>
                                            </c:when>
                                            <c:when test="${not empty a and fn:contains(a.anomalyStatus, 'INSUFFICIENT')}">
                                                <span class="badge-status pending" style="font-size: 11px;">
                                                    <i class="fa-solid fa-circle-info"></i> Insufficient Data
                                                </span>
                                            </c:when>
                                            <c:when test="${not empty a and a.anomalyStatus eq 'NORMAL'}">
                                                <span class="badge-status approved" style="font-size: 11px;">
                                                    <i class="fa-solid fa-shield-check"></i> Low Risk
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-status pending" style="font-size: 11px;">
                                                    <i class="fa-solid fa-hourglass-half"></i> Pending AI Scan
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                        <c:if test="${not empty a and a.hasPrediction}">
                                            <div style="font-size: 11px; color: var(--text-muted); margin-top: 4px; font-weight: 500;">
                                                <i class="fa-solid fa-brain" style="color: var(--ai-purple);"></i> Suggested: ${fn:escapeXml(a.predictedCategory)} (${a.confidencePercent})
                                            </div>
                                        </c:if>
                                    </td>
                                    <td>
                                        <div style="display: flex; gap: 6px;">
                                            <a href="${ctx}/expense-details?id=${e.expenseId}" class="btn-outline-custom" style="padding: 4px 10px; font-size: 12px;" title="View Claim Details">
                                                <i class="fa-solid fa-eye"></i>
                                            </a>
                                            <form action="${ctx}/ApproveRejectServlet" method="POST" style="display: inline;" onsubmit="return confirm('Approve claim ${e.claimCode}?');">
                                                <input type="hidden" name="action" value="APPROVE">
                                                <input type="hidden" name="expenseId" value="${e.expenseId}">
                                                <button class="btn-success-custom" type="submit" style="padding: 4px 12px; font-size: 12px;">Approve <i class="fa-solid fa-check"></i></button>
                                            </form>
                                            <button class="btn-danger-custom" type="button" onclick="openRejectModal(${e.expenseId}, '${e.claimCode}', '${fn:escapeXml(e.employeeName)}')" style="padding: 4px 12px; font-size: 12px;">
                                                Reject <i class="fa-solid fa-xmark"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty pending}">
                                <tr>
                                    <td colspan="7" style="text-align: center; color: var(--text-muted); padding: 36px;">
                                        <i class="fa-solid fa-circle-check" style="font-size: 32px; color: var(--success-text); margin-bottom: 10px; display: block;"></i>
                                        <span style="font-weight: 600;">No pending claims requiring approval</span>
                                        <p style="font-size: 12px; margin-top: 4px;">All submitted employee expenses have been reviewed.</p>
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

<!-- Rejection Remarks Modal -->
<div id="rejectModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.65); z-index: 1000; align-items: center; justify-content: center; backdrop-filter: blur(4px);">
    <div style="background: var(--card-bg); border: 1px solid var(--border-color); padding: 30px; border-radius: 16px; width: 100%; max-width: 480px; box-shadow: var(--shadow-lg);">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px;">
            <h4 style="margin: 0; font-weight: 800; color: var(--danger-text); font-size: 18px;"><i class="fa-solid fa-circle-xmark"></i> Reject Expense Claim</h4>
            <button type="button" onclick="closeRejectModal()" style="background: none; border: none; font-size: 20px; cursor: pointer; color: var(--text-muted);">&times;</button>
        </div>

        <form action="${ctx}/ApproveRejectServlet" method="POST">
            <input type="hidden" name="action" value="REJECT">
            <input type="hidden" name="expenseId" id="modalExpenseId">

            <p style="font-size: 14px; color: var(--text-muted); margin-bottom: 18px; line-height: 1.5;">
                Rejecting claim <strong id="displayClaimId" style="color: var(--text-main);"></strong> submitted by <strong id="displayEmployee" style="color: var(--text-main);"></strong>. State rejection remarks below:
            </p>

            <div class="form-group">
                <label for="rejectionRemarks">Rejection Remarks <span style="color: var(--danger-text);">*</span></label>
                <textarea class="form-control" id="rejectionRemarks" name="remarks" rows="4" placeholder="Provide clear rejection rationale for employee record..." required></textarea>
            </div>

            <div style="display: flex; gap: 10px; justify-content: flex-end; margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color);">
                <button type="button" class="btn-outline-custom" onclick="closeRejectModal()">Cancel</button>
                <button type="submit" class="btn-danger-custom" style="padding: 10px 20px; font-size: 14px;">Confirm Rejection</button>
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
