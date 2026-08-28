<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="user" value="${sessionScope.user}" />
<c:set var="backUrl" value="${user.manager ? ctx.concat('/manager/dashboard') : ctx.concat('/employee/expenses')}" />
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Expense Details - ClaimSense AI</title>

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

            <c:if test="${empty expense}">
                <div class="alert alert-danger" style="padding: 16px; border-radius: 8px; background: #FEE2E2; color: #B91C1C;">
                    ${not empty error ? fn:escapeXml(error) : 'This claim could not be found.'}
                    <a href="${backUrl}">Go back</a>.
                </div>
            </c:if>

            <c:if test="${not empty expense}">

            <c:if test="${not empty param.submitted}">
                <div class="alert" style="padding: 12px; border-radius: 8px; background: #DCFCE7; color: #166534; font-size: 13px; margin-bottom: 20px;">
                    <i class="fa-solid fa-circle-check"></i> Claim submitted successfully and sent for manager approval. AI analysis is shown below.
                </div>
            </c:if>

            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 28px; flex-wrap: wrap; gap: 16px;">
                <div>
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 4px;">
                        <a href="${backUrl}" style="color: var(--text-muted); font-size: 14px; text-decoration: none;"><i class="fa-solid fa-arrow-left"></i> Back</a>
                        <span style="color: var(--border-color);">|</span>
                        <span style="font-size: 13px; font-weight: 600; color: var(--text-muted);">${expense.claimCode}</span>
                    </div>
                    <h2 style="font-size: 24px; font-weight: 700; margin: 0;">${fn:escapeXml(expense.title)}</h2>
                </div>
                <div>
                    <c:choose>
                        <c:when test="${expense.status eq 'APPROVED'}"><span class="badge-status approved" style="font-size: 14px; padding: 8px 16px;"><i class="fa-solid fa-check"></i> APPROVED</span></c:when>
                        <c:when test="${expense.status eq 'REJECTED'}"><span class="badge-status rejected" style="font-size: 14px; padding: 8px 16px;"><i class="fa-solid fa-xmark"></i> REJECTED</span></c:when>
                        <c:otherwise><span class="badge-status pending" style="font-size: 14px; padding: 8px 16px;"><i class="fa-solid fa-clock"></i> PENDING APPROVAL</span></c:otherwise>
                    </c:choose>
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
                                <span style="font-size: 24px; font-weight: 700; color: var(--primary);">₹${expense.amountDisplay}</span>
                            </div>
                            <div>
                                <span style="font-size: 12px; color: var(--text-muted); display: block; margin-bottom: 4px;">Category</span>
                                <span style="font-size: 15px; font-weight: 600;">${fn:escapeXml(expense.categoryName)}</span>
                            </div>
                            <div>
                                <span style="font-size: 12px; color: var(--text-muted); display: block; margin-bottom: 4px;">Date of Expense</span>
                                <span style="font-size: 15px; font-weight: 500;">${expense.expenseDateDisplay}</span>
                            </div>
                            <div>
                                <span style="font-size: 12px; color: var(--text-muted); display: block; margin-bottom: 4px;">Submitted On</span>
                                <span style="font-size: 15px; font-weight: 500;">${expense.createdAtDisplay}</span>
                            </div>
                        </div>

                        <div style="margin-top: 20px; border-top: 1px solid var(--border-color); padding-top: 16px;">
                            <span style="font-size: 12px; color: var(--text-muted); display: block; margin-bottom: 6px;">Description</span>
                            <p style="font-size: 14px; color: var(--text-main); line-height: 1.6; margin: 0;">
                                <c:out value="${expense.description}" default="—" />
                                <c:if test="${empty expense.description}">—</c:if>
                            </p>
                        </div>

                        <!-- Manager action bar (only for a pending claim viewed by a manager) -->
                        <c:if test="${canDecide}">
                            <div style="margin-top: 20px; border-top: 1px solid var(--border-color); padding-top: 16px; display: flex; gap: 10px; flex-wrap: wrap; align-items: flex-start;">
                                <form action="${ctx}/ApproveRejectServlet" method="POST" onsubmit="return confirm('Approve ${expense.claimCode}?');">
                                    <input type="hidden" name="action" value="APPROVE">
                                    <input type="hidden" name="expenseId" value="${expense.expenseId}">
                                    <button type="submit" class="btn-success-custom"><i class="fa-solid fa-check"></i> Approve</button>
                                </form>
                                <form action="${ctx}/ApproveRejectServlet" method="POST" style="flex: 1; min-width: 260px;">
                                    <input type="hidden" name="action" value="REJECT">
                                    <input type="hidden" name="expenseId" value="${expense.expenseId}">
                                    <div style="display: flex; gap: 8px;">
                                        <input class="input" name="remarks" placeholder="Rejection remarks (required)" required style="margin: 0; height: 40px;">
                                        <button type="submit" class="btn-danger-custom"><i class="fa-solid fa-xmark"></i> Reject</button>
                                    </div>
                                </form>
                            </div>
                        </c:if>
                    </div>

                    <!-- AI Analysis Card -->
                    <div class="ai-card">
                        <div class="ai-card-header">
                            <div class="ai-card-title">
                                <i class="fa-solid fa-microchip"></i>
                                <h4 style="margin: 0; font-size: 16px;">AI Verification & OCR Breakdown</h4>
                            </div>
                            <span class="ai-badge">Tesseract OCR + ML</span>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-top: 16px;">
                            <!-- OCR extraction -->
                            <div style="background: var(--card-bg); padding: 14px; border-radius: 10px; border: 1px solid rgba(124,58,237,0.15);">
                                <span style="font-size: 12px; color: var(--text-muted);">OCR Extracted Amount</span>
                                <div style="font-size: 14px; font-weight: 600; margin-top: 4px;">
                                    <c:choose>
                                        <c:when test="${not empty analysis and not empty analysis.ocrAmountDisplay}">
                                            <i class="fa-solid fa-receipt"></i> ₹${analysis.ocrAmountDisplay}
                                        </c:when>
                                        <c:otherwise><span style="color: var(--text-muted);">Not detected</span></c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div style="background: var(--card-bg); padding: 14px; border-radius: 10px; border: 1px solid rgba(124,58,237,0.15);">
                                <span style="font-size: 12px; color: var(--text-muted);">OCR Merchant</span>
                                <div style="font-size: 14px; font-weight: 600; margin-top: 4px;">
                                    <c:choose>
                                        <c:when test="${not empty analysis and not empty analysis.ocrMerchant}">
                                            ${fn:escapeXml(analysis.ocrMerchant)}
                                        </c:when>
                                        <c:otherwise><span style="color: var(--text-muted);">Not detected</span></c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- ML category prediction -->
                            <div style="background: var(--card-bg); padding: 14px; border-radius: 10px; border: 1px solid rgba(124,58,237,0.15);">
                                <span style="font-size: 12px; color: var(--text-muted);">AI Category Suggestion</span>
                                <div style="font-size: 14px; font-weight: 600; margin-top: 4px;">
                                    <c:choose>
                                        <c:when test="${not empty analysis and analysis.hasPrediction}">
                                            <i class="fa-solid fa-brain"></i> ${fn:escapeXml(analysis.predictedCategory)}
                                            <span style="color: var(--text-muted); font-weight: 500;">(${analysis.confidencePercent} confidence)</span>
                                        </c:when>
                                        <c:otherwise><span style="color: var(--text-muted);">AI category suggestion unavailable</span></c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- Anomaly detection -->
                            <div style="background: var(--card-bg); padding: 14px; border-radius: 10px; border: 1px solid rgba(124,58,237,0.15);">
                                <span style="font-size: 12px; color: var(--text-muted);">Anomaly Detection</span>
                                <div style="font-size: 14px; font-weight: 600; margin-top: 4px;">
                                    <c:choose>
                                        <c:when test="${not empty analysis and analysis.anomaly}">
                                            <span style="color: #B45309;"><i class="fa-solid fa-triangle-exclamation"></i> Potential anomaly detected</span>
                                        </c:when>
                                        <c:when test="${not empty analysis and fn:contains(analysis.anomalyStatus, 'INSUFFICIENT')}">
                                            <span style="color: var(--text-muted);"><i class="fa-solid fa-circle-info"></i> Insufficient data for anomaly analysis</span>
                                        </c:when>
                                        <c:when test="${not empty analysis and analysis.anomalyStatus eq 'NORMAL'}">
                                            <span style="color: var(--success-text);"><i class="fa-solid fa-shield-check"></i> No anomaly detected</span>
                                        </c:when>
                                        <c:otherwise><span style="color: var(--text-muted);">Anomaly analysis unavailable</span></c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <!-- Raw OCR text -->
                        <c:if test="${not empty receipt and receipt.hasOcr}">
                            <div style="margin-top: 16px;">
                                <span style="font-size: 12px; color: var(--text-muted); display: block; margin-bottom: 6px;">Raw OCR Text</span>
                                <pre style="max-height: 160px; overflow: auto; background: #0f172a; color: #e2e8f0; padding: 12px; border-radius: 8px; font-size: 12px; white-space: pre-wrap; margin: 0;">${fn:escapeXml(receipt.ocrText)}</pre>
                            </div>
                        </c:if>
                    </div>
                </div>

                <div>
                    <!-- Receipt Preview -->
                    <div class="table-box">
                        <h4 style="margin-bottom: 16px;">Attached Receipt</h4>
                        <c:choose>
                            <c:when test="${not empty receipt}">
                                <c:set var="ext" value="${receipt.extension}" />
                                <div style="border: 1px dashed var(--border-color); border-radius: 12px; padding: 16px; text-align: center; background: var(--table-header-bg);">
                                    <c:choose>
                                        <c:when test="${ext eq 'png' or ext eq 'jpg' or ext eq 'jpeg'}">
                                            <img src="${ctx}/receipt?expenseId=${expense.expenseId}" alt="Receipt" style="max-width: 100%; max-height: 320px; border-radius: 8px; border: 1px solid var(--border-color);">
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fa-solid fa-file-pdf" style="font-size: 48px; color: #EF4444; margin-bottom: 12px;"></i>
                                            <h5 style="font-size: 14px; font-weight: 600; margin-bottom: 4px;">${fn:escapeXml(receipt.fileName)}</h5>
                                            <span style="font-size: 12px; color: var(--text-muted);">PDF Document</span>
                                        </c:otherwise>
                                    </c:choose>
                                    <div style="margin-top: 16px; display: flex; gap: 8px; justify-content: center;">
                                        <a class="btn-outline-custom" style="font-size: 12px; padding: 6px 12px;" href="${ctx}/receipt?expenseId=${expense.expenseId}" target="_blank">
                                            <i class="fa-solid fa-eye"></i> View
                                        </a>
                                        <a class="btn-outline-custom" style="font-size: 12px; padding: 6px 12px;" href="${ctx}/receipt?expenseId=${expense.expenseId}" download="${fn:escapeXml(receipt.fileName)}">
                                            <i class="fa-solid fa-download"></i> Download
                                        </a>
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div style="border: 1px dashed var(--border-color); border-radius: 12px; padding: 20px; text-align: center; background: var(--table-header-bg); color: var(--text-muted); font-size: 13px;">
                                    No receipt attached.
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Approval History -->
                    <div class="table-box">
                        <h4 style="margin-bottom: 16px;">Approval History</h4>
                        <div style="display: flex; flex-direction: column; gap: 16px;">
                            <!-- Submitted node -->
                            <div style="display: flex; gap: 12px; align-items: flex-start;">
                                <div style="width: 28px; height: 28px; border-radius: 50%; background: var(--success-bg); color: var(--success-text); display: flex; align-items: center; justify-content: center; font-size: 12px; margin-top: 2px;">
                                    <i class="fa-solid fa-paper-plane"></i>
                                </div>
                                <div>
                                    <h5 style="font-size: 13px; font-weight: 600; margin: 0;">Claim Submitted</h5>
                                    <span style="font-size: 11px; color: var(--text-muted);">${expense.createdAtDisplay}</span>
                                </div>
                            </div>

                            <!-- Decision nodes -->
                            <c:forEach var="h" items="${history}">
                                <div style="display: flex; gap: 12px; align-items: flex-start;">
                                    <c:choose>
                                        <c:when test="${h.approved}">
                                            <div style="width: 28px; height: 28px; border-radius: 50%; background: var(--success-bg); color: var(--success-text); display: flex; align-items: center; justify-content: center; font-size: 12px; margin-top: 2px;"><i class="fa-solid fa-check"></i></div>
                                        </c:when>
                                        <c:otherwise>
                                            <div style="width: 28px; height: 28px; border-radius: 50%; background: var(--rejected-bg, #FEE2E2); color: var(--rejected-text, #B91C1C); display: flex; align-items: center; justify-content: center; font-size: 12px; margin-top: 2px;"><i class="fa-solid fa-xmark"></i></div>
                                        </c:otherwise>
                                    </c:choose>
                                    <div>
                                        <h5 style="font-size: 13px; font-weight: 600; margin: 0;">Claim ${fn:toLowerCase(h.action)} by ${fn:escapeXml(h.managerName)}</h5>
                                        <span style="font-size: 11px; color: var(--text-muted);">${h.actionDateDisplay}</span>
                                        <c:if test="${not empty h.remarks}">
                                            <p style="font-size: 12px; color: var(--text-main); margin: 6px 0 0;">“${fn:escapeXml(h.remarks)}”</p>
                                        </c:if>
                                    </div>
                                </div>
                            </c:forEach>

                            <!-- Pending node -->
                            <c:if test="${expense.status eq 'PENDING'}">
                                <div style="display: flex; gap: 12px; align-items: flex-start;">
                                    <div style="width: 28px; height: 28px; border-radius: 50%; background: var(--pending-bg); color: var(--pending-text); display: flex; align-items: center; justify-content: center; font-size: 12px; margin-top: 2px;"><i class="fa-solid fa-clock"></i></div>
                                    <div>
                                        <h5 style="font-size: 13px; font-weight: 600; margin: 0;">Awaiting Manager Approval</h5>
                                        <span style="font-size: 11px; color: var(--text-muted);">Pending review</span>
                                    </div>
                                </div>
                            </c:if>
                        </div>

                        <!-- Manager Remarks -->
                        <div style="margin-top: 20px; padding-top: 16px; border-top: 1px solid var(--border-color);">
                            <span style="font-size: 12px; color: var(--text-muted); display: block; margin-bottom: 6px;">Manager Remarks</span>
                            <c:choose>
                                <c:when test="${expense.status eq 'REJECTED' and not empty expense.rejectionReason}">
                                    <div style="padding: 10px; background: var(--danger-bg); border-radius: 8px; font-size: 13px; color: var(--danger-text);">${fn:escapeXml(expense.rejectionReason)}</div>
                                </c:when>
                                <c:otherwise>
                                    <div style="padding: 10px; background: var(--table-header-bg); border-radius: 8px; font-size: 13px; color: var(--text-muted); font-style: italic;">
                                        No remarks added yet.
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                </div>

            </div>

            </c:if>

        </div>

        <jsp:include page="../components/footer.jsp"/>

    </main>

</div>

<script src="${ctx}/assets/js/script.js"></script>
</body>

</html>
