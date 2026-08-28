<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Manager Dashboard - ClaimSense AI</title>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/assets/css/style.css">
    <link rel="stylesheet" href="${ctx}/assets/css/responsive.css">
</head>

<body>

<div class="dashboard">

    <jsp:include page="../components/sidebar.jsp"/>

    <main class="main">

        <jsp:include page="../components/navbar.jsp"/>

        <div class="content">

            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 28px; flex-wrap: wrap; gap: 16px;">
                <div>
                    <h2 style="font-size: 24px; font-weight: 700; margin-bottom: 4px;">Manager Review & Approvals</h2>
                    <p style="color: var(--text-muted); font-size: 14px; margin: 0;">
                        Review submitted employee claims, examine AI anomaly signals, and manage approvals.
                    </p>
                </div>
                <div class="ai-badge" style="font-size: 13px; padding: 8px 14px;">
                    <i class="fa-solid fa-shield-halved"></i> AI Anomaly Detector (Isolation Forest)
                </div>
            </div>

            <c:if test="${not empty param.ok}">
                <div class="alert" style="padding: 12px; border-radius: 8px; background: #DCFCE7; color: #166534; font-size: 13px; margin-bottom: 20px;"><i class="fa-solid fa-circle-check"></i> ${fn:escapeXml(param.ok)}</div>
            </c:if>
            <c:if test="${not empty param.err}">
                <div class="alert alert-danger" style="padding: 12px; border-radius: 8px; background: #FEE2E2; color: #B91C1C; font-size: 13px; margin-bottom: 20px;"><i class="fa-solid fa-triangle-exclamation"></i> ${fn:escapeXml(param.err)}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger" style="padding: 12px; border-radius: 8px; background: #FEE2E2; color: #B91C1C; font-size: 13px; margin-bottom: 20px;">${fn:escapeXml(error)}</div>
            </c:if>

            <!-- Stats Grid -->
            <div class="cards-grid">
                <div class="card-stat">
                    <div class="stat-icon total"><i class="fa-solid fa-file-invoice-dollar"></i></div>
                    <div class="stat-info"><span>Total Claims</span><h2>${stats.totalCount}</h2></div>
                </div>
                <div class="card-stat">
                    <div class="stat-icon pending"><i class="fa-solid fa-clock-rotate-left"></i></div>
                    <div class="stat-info"><span>Pending Review</span><h2>${stats.pendingCount}</h2></div>
                </div>
                <div class="card-stat">
                    <div class="stat-icon approved"><i class="fa-solid fa-circle-check"></i></div>
                    <div class="stat-info"><span>Approved</span><h2>${stats.approvedCount}</h2></div>
                </div>
                <div class="card-stat">
                    <div class="stat-icon rejected"><i class="fa-solid fa-circle-xmark"></i></div>
                    <div class="stat-info"><span>Rejected</span><h2>${stats.rejectedCount}</h2></div>
                </div>
            </div>

            <!-- Pending Approvals Table -->
            <div class="table-box">
                <div class="box-header">
                    <h4>Submitted Claims Requiring Action</h4>
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
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="e" items="${pending}">
                                <c:set var="a" value="${analysisMap[e.expenseId]}" />
                                <tr>
                                    <td>
                                        <div style="display: flex; align-items: center; gap: 10px;">
                                            <div class="user-avatar" style="width: 28px; height: 28px; font-size: 11px;">${fn:toUpperCase(fn:substring(e.employeeName, 0, 1))}</div>
                                            <span style="font-weight: 600;">${fn:escapeXml(e.employeeName)}</span>
                                        </div>
                                    </td>
                                    <td><strong>${e.claimCode}</strong></td>
                                    <td>${fn:escapeXml(e.title)}</td>
                                    <td>${fn:escapeXml(e.categoryName)}</td>
                                    <td><strong>₹${e.amountDisplay}</strong></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty a and a.anomaly}">
                                                <span class="badge-status pending" style="font-size: 11px; background: #FEF3C7; color: #B45309;">
                                                    <i class="fa-solid fa-triangle-exclamation"></i> Potential anomaly detected
                                                </span>
                                            </c:when>
                                            <c:when test="${not empty a and fn:contains(a.anomalyStatus, 'INSUFFICIENT')}">
                                                <span class="badge-status pending" style="font-size: 11px;">
                                                    <i class="fa-solid fa-circle-info"></i> Insufficient data for anomaly analysis
                                                </span>
                                            </c:when>
                                            <c:when test="${not empty a and a.anomalyStatus eq 'NORMAL'}">
                                                <span class="badge-status approved" style="font-size: 11px;">
                                                    <i class="fa-solid fa-shield-check"></i> Low risk
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-status pending" style="font-size: 11px; background: #F1F5F9; color: #475569;">
                                                    <i class="fa-solid fa-hourglass-half"></i> AI analysis pending
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                        <c:if test="${not empty a and a.hasPrediction}">
                                            <div style="font-size: 11px; color: var(--text-muted); margin-top: 4px;">
                                                <i class="fa-solid fa-brain"></i> Suggested: ${fn:escapeXml(a.predictedCategory)} (${a.confidencePercent})
                                            </div>
                                        </c:if>
                                    </td>
                                    <td>
                                        <div style="display: flex; gap: 6px;">
                                            <a href="${ctx}/expense-details?id=${e.expenseId}" class="btn-outline-custom" style="padding: 4px 8px; font-size: 12px;" title="View Details">
                                                <i class="fa-solid fa-eye"></i>
                                            </a>
                                            <form action="${ctx}/ApproveRejectServlet" method="POST" style="display: inline;" onsubmit="return confirm('Approve claim ${e.claimCode}?');">
                                                <input type="hidden" name="action" value="APPROVE">
                                                <input type="hidden" name="expenseId" value="${e.expenseId}">
                                                <button class="btn-success-custom" type="submit">Approve <i class="fa-solid fa-check"></i></button>
                                            </form>
                                            <button class="btn-danger-custom" type="button" onclick="openRejectModal(${e.expenseId}, '${e.claimCode}', '${fn:escapeXml(e.employeeName)}')">
                                                Reject <i class="fa-solid fa-xmark"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty pending}">
                                <tr><td colspan="7" style="text-align: center; color: var(--text-muted); padding: 24px;">No pending claims. All caught up! 🎉</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>

        <jsp:include page="../components/footer.jsp"/>

    </main>

</div>

<!-- Rejection Modal -->
<div id="rejectModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center;">
    <div style="background: white; padding: 28px; border-radius: 16px; width: 100%; max-width: 480px; box-shadow: var(--shadow-lg);">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <h4 style="margin: 0; font-weight: 700; color: #B91C1C;"><i class="fa-solid fa-circle-xmark"></i> Reject Expense Claim</h4>
            <button type="button" onclick="closeRejectModal()" style="background: none; border: none; font-size: 18px; cursor: pointer; color: var(--text-muted);">&times;</button>
        </div>

        <form action="${ctx}/ApproveRejectServlet" method="POST">
            <input type="hidden" name="action" value="REJECT">
            <input type="hidden" name="expenseId" id="modalExpenseId">

            <p style="font-size: 14px; color: var(--text-muted); margin-bottom: 16px;">
                You are rejecting claim <strong id="displayClaimId"></strong> submitted by <strong id="displayEmployee"></strong>. Please state the rejection remarks below:
            </p>

            <div class="form-group">
                <label for="rejectionRemarks">Rejection Remarks <span style="color: red;">*</span></label>
                <textarea class="form-control" id="rejectionRemarks" name="remarks" rows="4" placeholder="e.g. Receipt is missing itemized details or exceeds limit..." required></textarea>
            </div>

            <div style="display: flex; gap: 10px; justify-content: flex-end; margin-top: 20px;">
                <button type="button" class="btn-outline-custom" onclick="closeRejectModal()">Cancel</button>
                <button type="submit" class="btn-danger-custom" style="padding: 10px 18px;">Confirm Rejection</button>
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
