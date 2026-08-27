<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Expense Details - ClaimSense AI</title>

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
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 4px;">
                        <a href="${pageContext.request.contextPath}/employee/myExpense.jsp" style="color: var(--text-muted); font-size: 14px; text-decoration: none;"><i class="fa-solid fa-arrow-left"></i> Back to Expenses</a>
                        <span style="color: var(--border-color);">|</span>
                        <span style="font-size: 13px; font-weight: 600; color: var(--text-muted);">#EX-1091</span>
                    </div>
                    <h2 style="font-size: 24px; font-weight: 700; margin: 0;">Starbucks Client Coffee</h2>
                </div>
                <div>
                    <span class="badge-status pending" style="font-size: 14px; padding: 8px 16px;"><i class="fa-solid fa-clock"></i> PENDING APPROVAL</span>
                </div>
            </div>

            <div class="dashboard-grid">

                <div>
                    <!-- Primary Details Card -->
                    <div class="table-box">
                        <h4 style="margin-bottom: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 12px;">Expense Information</h4>
                        
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
                            <div>
                                <span style="font-size: 12px; color: var(--text-muted); display: block; margin-bottom: 4px;">Amount</span>
                                <span style="font-size: 24px; font-weight: 700; color: var(--primary);">₹320.00</span>
                            </div>
                            <div>
                                <span style="font-size: 12px; color: var(--text-muted); display: block; margin-bottom: 4px;">Category</span>
                                <span style="font-size: 15px; font-weight: 600;">Food & Beverage</span>
                            </div>
                            <div>
                                <span style="font-size: 12px; color: var(--text-muted); display: block; margin-bottom: 4px;">Date of Expense</span>
                                <span style="font-size: 15px; font-weight: 500;">23 August 2026</span>
                            </div>
                            <div>
                                <span style="font-size: 12px; color: var(--text-muted); display: block; margin-bottom: 4px;">Submitted On</span>
                                <span style="font-size: 15px; font-weight: 500;">23 August 2026, 04:15 PM</span>
                            </div>
                        </div>

                        <div style="margin-top: 20px; border-top: 1px solid var(--border-color); padding-top: 16px;">
                            <span style="font-size: 12px; color: var(--text-muted); display: block; margin-bottom: 6px;">Description</span>
                            <p style="font-size: 14px; color: var(--text-main); line-height: 1.6; margin: 0;">
                                Coffee meeting with potential enterprise lead (TechCorp Ltd). Discussed Q3 software expansion requirements.
                            </p>
                        </div>
                    </div>

                    <!-- AI Analysis Card -->
                    <div class="ai-card">
                        <div class="ai-card-header">
                            <div class="ai-card-title">
                                <i class="fa-solid fa-microchip"></i>
                                <h4 style="margin: 0; font-size: 16px;">AI Verification & OCR Breakdown</h4>
                            </div>
                            <span class="ai-badge">AI Verified</span>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-top: 16px;">
                            <div style="background: white; padding: 14px; border-radius: 10px; border: 1px solid rgba(124,58,237,0.15);">
                                <span style="font-size: 12px; color: var(--text-muted);">OCR Amount Match</span>
                                <div style="font-size: 14px; font-weight: 600; color: var(--success-text); margin-top: 4px;">
                                    <i class="fa-solid fa-circle-check"></i> ₹320.00 Confirmed
                                </div>
                            </div>

                            <div style="background: white; padding: 14px; border-radius: 10px; border: 1px solid rgba(124,58,237,0.15);">
                                <span style="font-size: 12px; color: var(--text-muted);">Duplicate Check</span>
                                <div style="font-size: 14px; font-weight: 600; color: var(--success-text); margin-top: 4px;">
                                    <i class="fa-solid fa-shield-check"></i> No Duplicates Found
                                </div>
                            </div>
                        </div>

                        <div style="margin-top: 16px; padding: 12px; background: rgba(124, 58, 237, 0.05); border-radius: 8px; font-size: 13px; color: var(--ai-purple); display: flex; align-items: center; gap: 8px;">
                            <i class="fa-solid fa-circle-info"></i>
                            <span>Status: <strong>AI analysis pending manager final review</strong></span>
                        </div>
                    </div>
                </div>

                <div>
                    <!-- Receipt Preview -->
                    <div class="table-box">
                        <h4 style="margin-bottom: 16px;">Attached Receipt</h4>
                        <div style="border: 1px dashed var(--border-color); border-radius: 12px; padding: 20px; text-align: center; background: #F8FAFC;">
                            <i class="fa-solid fa-file-pdf" style="font-size: 48px; color: #EF4444; margin-bottom: 12px;"></i>
                            <h5 style="font-size: 14px; font-weight: 600; margin-bottom: 4px;">starbucks_receipt_23aug.pdf</h5>
                            <span style="font-size: 12px; color: var(--text-muted);">PDF Document • 420 KB</span>
                            <div style="margin-top: 16px; display: flex; gap: 8px; justify-content: center;">
                                <button class="btn-outline-custom" style="font-size: 12px; padding: 6px 12px;" type="button">
                                    <i class="fa-solid fa-eye"></i> View
                                </button>
                                <button class="btn-outline-custom" style="font-size: 12px; padding: 6px 12px;" type="button">
                                    <i class="fa-solid fa-download"></i> Download
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Approval History -->
                    <div class="table-box">
                        <h4 style="margin-bottom: 16px;">Approval History</h4>
                        <div style="display: flex; flex-direction: column; gap: 16px;">
                            <div style="display: flex; gap: 12px; align-items: flex-start;">
                                <div style="width: 28px; height: 28px; border-radius: 50%; background: var(--success-bg); color: var(--success-text); display: flex; align-items: center; justify-content: center; font-size: 12px; margin-top: 2px;">
                                    <i class="fa-solid fa-check"></i>
                                </div>
                                <div>
                                    <h5 style="font-size: 13px; font-weight: 600; margin: 0;">Claim Submitted</h5>
                                    <span style="font-size: 11px; color: var(--text-muted);">23 Aug 2026, 04:15 PM</span>
                                </div>
                            </div>

                            <div style="display: flex; gap: 12px; align-items: flex-start;">
                                <div style="width: 28px; height: 28px; border-radius: 50%; background: var(--pending-bg); color: var(--pending-text); display: flex; align-items: center; justify-content: center; font-size: 12px; margin-top: 2px;">
                                    <i class="fa-solid fa-clock"></i>
                                </div>
                                <div>
                                    <h5 style="font-size: 13px; font-weight: 600; margin: 0;">Manager Approval Pending</h5>
                                    <span style="font-size: 11px; color: var(--text-muted);">Assigned to Manager (Rajesh Kumar)</span>
                                </div>
                            </div>
                        </div>

                        <!-- Manager Remarks Area -->
                        <div style="margin-top: 20px; padding-top: 16px; border-top: 1px solid var(--border-color);">
                            <span style="font-size: 12px; color: var(--text-muted); display: block; margin-bottom: 6px;">Manager Remarks</span>
                            <div style="padding: 10px; background: #F8FAFC; border-radius: 8px; font-size: 13px; color: var(--text-muted); font-style: italic;">
                                No remarks added yet. Pending review.
                            </div>
                        </div>
                    </div>

                </div>

            </div>

        </div>

        <jsp:include page="../components/footer.jsp"/>

    </main>

</div>

<script src="${pageContext.request.contextPath}/assets/js/script.js"></script>
</body>

</html>