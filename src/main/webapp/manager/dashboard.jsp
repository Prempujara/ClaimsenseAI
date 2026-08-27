<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Manager Dashboard - ClaimSense AI</title>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive.css">
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
                        Review submitted employee claims, examine AI risk scores, and manage approvals.
                    </p>
                </div>
                <div class="ai-badge" style="font-size: 13px; padding: 8px 14px;">
                    <i class="fa-solid fa-shield-halved"></i> AI Anomaly Detector Active
                </div>
            </div>

            <!-- Stats Grid -->
            <div class="cards-grid">
                <div class="card-stat">
                    <div class="stat-icon total">
                        <i class="fa-solid fa-file-invoice-dollar"></i>
                    </div>
                    <div class="stat-info">
                        <span>Total Claims</span>
                        <h2>42</h2>
                    </div>
                </div>

                <div class="card-stat">
                    <div class="stat-icon pending">
                        <i class="fa-solid fa-clock-rotate-left"></i>
                    </div>
                    <div class="stat-info">
                        <span>Pending Review</span>
                        <h2>12</h2>
                    </div>
                </div>

                <div class="card-stat">
                    <div class="stat-icon approved">
                        <i class="fa-solid fa-circle-check"></i>
                    </div>
                    <div class="stat-info">
                        <span>Approved This Month</span>
                        <h2>25</h2>
                    </div>
                </div>

                <div class="card-stat">
                    <div class="stat-icon rejected">
                        <i class="fa-solid fa-circle-xmark"></i>
                    </div>
                    <div class="stat-info">
                        <span>Rejected</span>
                        <h2>05</h2>
                    </div>
                </div>
            </div>

            <!-- Pending Approvals Table -->
            <div class="table-box">
                <div class="box-header">
                    <h4>Submitted Claims Requiring Action</h4>
                    <div style="display: flex; gap: 8px;">
                        <button class="btn-outline-custom" style="padding: 6px 12px; font-size: 12px;">Filter Pending</button>
                        <button class="btn-outline-custom" style="padding: 6px 12px; font-size: 12px;">Export Report</button>
                    </div>
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
                            <tr>
                                <td>
                                    <div style="display: flex; align-items: center; gap: 10px;">
                                        <div class="user-avatar" style="width: 28px; height: 28px; font-size: 11px;">PP</div>
                                        <span style="font-weight: 600;">Prem Pujara</span>
                                    </div>
                                </td>
                                <td><strong>#EX-1091</strong></td>
                                <td>Starbucks Client Coffee</td>
                                <td>Food</td>
                                <td><strong>₹320.00</strong></td>
                                <td>
                                    <span class="badge-status approved" style="font-size: 11px;">
                                        <i class="fa-solid fa-shield-check"></i> Low Risk (98% OCR match)
                                    </span>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 6px;">
                                        <a href="${pageContext.request.contextPath}/employee/expenseDetails.jsp" class="btn-outline-custom" style="padding: 4px 8px; font-size: 12px;" title="View Details">
                                            <i class="fa-solid fa-eye"></i>
                                        </a>
                                        <button class="btn-success-custom" type="button" onclick="approveClaim('#EX-1091')">
                                            Approve <i class="fa-solid fa-check"></i>
                                        </button>
                                        <button class="btn-danger-custom" type="button" onclick="openRejectModal('#EX-1091', 'Prem Pujara')">
                                            Reject <i class="fa-solid fa-xmark"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>

                            <tr>
                                <td>
                                    <div style="display: flex; align-items: center; gap: 10px;">
                                        <div class="user-avatar" style="width: 28px; height: 28px; font-size: 11px; background: #7C3AED;">RS</div>
                                        <span style="font-weight: 600;">Rahul Sharma</span>
                                    </div>
                                </td>
                                <td><strong>#EX-1095</strong></td>
                                <td>Flight Ticket - Delhi Seminar</td>
                                <td>Travel</td>
                                <td><strong>₹7,500.00</strong></td>
                                <td>
                                    <span class="badge-status approved" style="font-size: 11px;">
                                        <i class="fa-solid fa-shield-check"></i> Low Risk
                                    </span>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 6px;">
                                        <a href="${pageContext.request.contextPath}/employee/expenseDetails.jsp" class="btn-outline-custom" style="padding: 4px 8px; font-size: 12px;" title="View Details">
                                            <i class="fa-solid fa-eye"></i>
                                        </a>
                                        <button class="btn-success-custom" type="button" onclick="approveClaim('#EX-1095')">
                                            Approve <i class="fa-solid fa-check"></i>
                                        </button>
                                        <button class="btn-danger-custom" type="button" onclick="openRejectModal('#EX-1095', 'Rahul Sharma')">
                                            Reject <i class="fa-solid fa-xmark"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>

                            <tr>
                                <td>
                                    <div style="display: flex; align-items: center; gap: 10px;">
                                        <div class="user-avatar" style="width: 28px; height: 28px; font-size: 11px; background: #F59E0B;">AP</div>
                                        <span style="font-weight: 600;">Ananya Patel</span>
                                    </div>
                                </td>
                                <td><strong>#EX-1098</strong></td>
                                <td>Electronics & Monitors</td>
                                <td>Office Supplies</td>
                                <td><strong>₹18,200.00</strong></td>
                                <td>
                                    <span class="badge-status pending" style="font-size: 11px; background: #FEF3C7; color: #B45309;">
                                        <i class="fa-solid fa-triangle-exclamation"></i> Medium Risk (High Amount)
                                    </span>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 6px;">
                                        <a href="${pageContext.request.contextPath}/employee/expenseDetails.jsp" class="btn-outline-custom" style="padding: 4px 8px; font-size: 12px;" title="View Details">
                                            <i class="fa-solid fa-eye"></i>
                                        </a>
                                        <button class="btn-success-custom" type="button" onclick="approveClaim('#EX-1098')">
                                            Approve <i class="fa-solid fa-check"></i>
                                        </button>
                                        <button class="btn-danger-custom" type="button" onclick="openRejectModal('#EX-1098', 'Ananya Patel')">
                                            Reject <i class="fa-solid fa-xmark"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
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
        
        <form action="${pageContext.request.contextPath}/ApproveRejectServlet" method="POST">
            <input type="hidden" name="action" value="REJECT">
            <input type="hidden" name="claimId" id="modalClaimId">

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

<script src="${pageContext.request.contextPath}/assets/js/script.js"></script>
<script>
    function approveClaim(claimId) {
        if (confirm("Are you sure you want to approve claim " + claimId + "?")) {
            // Form action ready for ApproveRejectServlet
            alert("Claim " + claimId + " has been approved! (Ready for Servlet connection)");
        }
    }

    function openRejectModal(claimId, employee) {
        document.getElementById('modalClaimId').value = claimId;
        document.getElementById('displayClaimId').innerText = claimId;
        document.getElementById('displayEmployee').innerText = employee;
        document.getElementById('rejectModal').style.display = 'flex';
    }

    function closeRejectModal() {
        document.getElementById('rejectModal').style.display = 'none';
    }
</script>

</body>

</html>