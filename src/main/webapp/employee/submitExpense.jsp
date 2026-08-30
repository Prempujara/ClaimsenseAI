<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Submit Expense - ClaimSense AI</title>

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
            <div style="margin-bottom: 24px;">
                <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 4px;">
                    <a href="${ctx}/employee/dashboard" style="color: var(--text-muted); font-size: 12px; text-decoration: none; font-weight: 500;">
                        <i class="fa-solid fa-arrow-left"></i> Dashboard
                    </a>
                    <span style="color: var(--border-color);">/</span>
                    <span style="font-size: 12px; font-weight: 600; color: var(--primary);">Submit Expense</span>
                </div>
                <h2 style="font-size: 22px; font-weight: 800; margin: 0; letter-spacing: -0.4px;">Submit New Expense Claim</h2>
            </div>

            <div class="table-box" style="max-width: 800px; margin-bottom: 32px;">
                
                <div id="formError" class="alert alert-danger" style="${empty error ? 'display: none;' : ''} padding: 10px 14px; border-radius: 8px; background: var(--danger-bg); color: var(--danger-text); border: 1px solid var(--danger-border); font-size: 13px; margin-bottom: 20px;">
                    <i class="fa-solid fa-circle-exclamation"></i> <c:out value="${error}" />
                </div>

                <form action="${ctx}/SubmitExpenseServlet" method="POST" enctype="multipart/form-data" id="expenseSubmitForm" onsubmit="return handleExpenseFormSubmit(event)">

                    <!-- 1. CLAIM DETAILS -->
                    <div style="margin-bottom: 16px; font-size: 13px; font-weight: 700; color: var(--text-main); display: flex; align-items: center; gap: 8px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                        <i class="fa-solid fa-file-lines" style="color: var(--primary);"></i> 1. Expense Details
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                        
                        <div class="form-group" style="margin-bottom: 0;">
                            <label for="expenseTitle">Expense Title <span style="color: #DC2626;">*</span></label>
                            <input class="input" id="expenseTitle" name="title" placeholder="e.g. Client Dinner at Marriott" required>
                        </div>

                        <div class="form-group" style="margin-bottom: 0;">
                            <label for="expenseCategory">Category <span style="color: #DC2626;">*</span></label>
                            <select class="form-select" id="expenseCategory" name="category" required>
                                <option value="" disabled selected>Select Category</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.categoryId}">${fn:escapeXml(cat.categoryName)}</option>
                                </c:forEach>
                            </select>
                        </div>

                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                        
                        <div class="form-group" style="margin-bottom: 0;">
                            <label for="expenseAmount">Amount (₹) <span style="color: #DC2626;">*</span></label>
                            <input type="number" step="0.01" min="0.01" class="input" id="expenseAmount" name="amount" placeholder="0.00" required>
                        </div>

                        <div class="form-group" style="margin-bottom: 0;">
                            <label for="expenseDate">Expense Date <span style="color: #DC2626;">*</span></label>
                            <input type="date" class="input" id="expenseDate" name="expenseDate" required>
                        </div>

                    </div>

                    <div class="form-group" style="margin-bottom: 24px;">
                        <label for="expenseDescription">Description / Business Purpose</label>
                        <textarea class="form-control" id="expenseDescription" name="description" rows="2" placeholder="Brief context or business purpose for this claim..."></textarea>
                    </div>

                    <!-- 2. RECEIPT UPLOAD -->
                    <div style="margin-bottom: 16px; font-size: 13px; font-weight: 700; color: var(--text-main); display: flex; align-items: center; gap: 8px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                        <i class="fa-solid fa-paperclip" style="color: var(--primary);"></i> 2. Receipt Attachment
                    </div>

                    <div class="form-group" style="margin-bottom: 24px;">
                        <div class="dropzone" id="receiptDropzone" style="padding: 24px; text-align: center; cursor: pointer; transition: all 0.2s ease;">
                            <i class="fa-solid fa-cloud-arrow-up" style="font-size: 24px; color: var(--primary); margin-bottom: 8px; display: block;"></i>
                            <h5 style="margin-bottom: 4px; font-weight: 700; font-size: 14px; color: var(--text-main);">Drop receipt here or click to browse</h5>
                            <p style="font-size: 12px; color: var(--text-muted); margin: 0;">
                                Accepts <strong>PDF, JPG, JPEG, PNG</strong> (Max 5MB)
                            </p>
                            <div id="fileNameDisplay" style="margin-top: 10px; font-size: 12px; font-weight: 700; color: var(--primary);"></div>
                            <div id="fileErrorDisplay" style="margin-top: 6px; font-size: 12px; color: var(--danger-text); display: none;"></div>
                        </div>

                        <input type="file" id="receiptFile" name="receipt" accept=".jpg,.jpeg,.png,.pdf" style="display: none;" required>
                    </div>

                    <div style="display: flex; gap: 10px; justify-content: flex-end; padding-top: 16px; border-top: 1px solid var(--border-color);">
                        <a href="${ctx}/employee/dashboard" class="btn-outline-custom" style="padding: 9px 18px; font-size: 13px;">Cancel</a>
                        <button type="submit" class="btn-primary-custom" id="submitBtn" style="padding: 9px 22px; font-size: 13px; font-weight: 700;">
                            <i class="fa-solid fa-paper-plane" style="margin-right: 6px;"></i> Submit Claim
                        </button>
                    </div>

                </form>

            </div>

        </div>

        <jsp:include page="../components/footer.jsp"/>

    </main>

</div>

<!-- OCR LOADING OVERLAY -->
<div id="ocrLoadingOverlay" class="ocr-analyzing-overlay" style="display: none;">
    <div class="ocr-spinner"></div>
    <h3 style="font-size: 18px; font-weight: 800; margin-bottom: 6px; color: #FFFFFF;">Analyzing Receipt...</h3>
    <p style="font-size: 13px; color: #94A3B8; margin: 0; text-align: center; max-width: 320px;">
        Extracting receipt details and running risk scoring...
    </p>
</div>

<script src="${ctx}/assets/js/script.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const dateInput = document.getElementById("expenseDate");
        if (dateInput) {
            const today = new Date().toISOString().split('T')[0];
            dateInput.setAttribute('max', today);
            dateInput.value = today;
        }
    });

    function handleExpenseFormSubmit(event) {
        if (!validateExpenseForm(event)) {
            return false;
        }
        const overlay = document.getElementById('ocrLoadingOverlay');
        if (overlay) {
            overlay.style.display = 'flex';
        }
        return true;
    }
</script>

</body>

</html>