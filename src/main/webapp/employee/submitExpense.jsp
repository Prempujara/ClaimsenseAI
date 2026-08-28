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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive.css">
    <script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>
</head>

<body>

<div class="dashboard">

    <jsp:include page="../components/sidebar.jsp"/>

    <main class="main">

        <jsp:include page="../components/navbar.jsp"/>

        <div class="content">

            <div style="margin-bottom: 28px;">
                <h2 style="font-size: 24px; font-weight: 800; margin-bottom: 4px; letter-spacing: -0.4px;">Submit New Expense Claim</h2>
                <p style="color: var(--text-muted); font-size: 14px; margin: 0;">
                    Complete the details below or upload your receipt for automated Tesseract OCR extraction.
                </p>
            </div>

            <div class="table-box" style="max-width: 880px;">
                
                <div id="formError" class="alert alert-danger" style="${empty error ? 'display: none;' : ''} padding: 12px 14px; border-radius: 10px; background: var(--danger-bg); color: var(--danger-text); border: 1px solid var(--danger-border); font-size: 13px; margin-bottom: 24px;"><i class="fa-solid fa-circle-exclamation"></i> <c:out value="${error}" /></div>

                <form action="${ctx}/SubmitExpenseServlet" method="POST" enctype="multipart/form-data" onsubmit="return validateExpenseForm(event)">

                    <div style="margin-bottom: 20px; font-size: 12px; font-weight: 700; text-transform: uppercase; color: var(--text-muted); letter-spacing: 0.6px;">
                        1. Expense Details
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
                        
                        <div class="form-group">
                            <label for="expenseTitle">Expense Title <span style="color: #DC2626;">*</span></label>
                            <input class="input" id="expenseTitle" name="title" placeholder="e.g. Client Dinner at Marriott" required>
                        </div>

                        <div class="form-group">
                            <label for="expenseCategory">Category <span style="color: #DC2626;">*</span></label>
                            <select class="form-select" id="expenseCategory" name="category" required>
                                <option value="" disabled selected>Select Category</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.categoryId}">${fn:escapeXml(cat.categoryName)}</option>
                                </c:forEach>
                            </select>
                            <div style="margin-top: 8px;">
                                <span class="ai-badge" style="font-size: 11px;">
                                    <i class="fa-solid fa-wand-magic-sparkles"></i> AI Category Auto-Suggest will evaluate after submit
                                </span>
                            </div>
                        </div>

                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
                        
                        <div class="form-group">
                            <label for="expenseAmount">Amount (₹) <span style="color: #DC2626;">*</span></label>
                            <input type="number" step="0.01" min="0.01" class="input" id="expenseAmount" name="amount" placeholder="0.00" required>
                        </div>

                        <div class="form-group">
                            <label for="expenseDate">Expense Date <span style="color: #DC2626;">*</span></label>
                            <input type="date" class="input" id="expenseDate" name="expenseDate" required>
                        </div>

                    </div>

                    <div class="form-group" style="margin-bottom: 28px;">
                        <label for="expenseDescription">Description / Business Purpose</label>
                        <textarea class="form-control" id="expenseDescription" name="description" rows="3" placeholder="Provide context or purpose for this expense claim..."></textarea>
                    </div>

                    <div style="margin-bottom: 16px; font-size: 12px; font-weight: 700; text-transform: uppercase; color: var(--text-muted); letter-spacing: 0.6px;">
                        2. Receipt & Proof
                    </div>

                    <div class="form-group" style="margin-bottom: 28px;">
                        <label>Upload Receipt Document <span style="color: #DC2626;">*</span></label>

                        <div class="dropzone" id="receiptDropzone">
                            <i class="fa-solid fa-cloud-arrow-up"></i>
                            <h5 style="margin-bottom: 6px; font-weight: 700; font-size: 15px; color: var(--text-main);">Click to select or drop receipt file here</h5>
                            <p style="font-size: 13px; color: var(--text-muted); margin: 0;">
                                Supported file types: <strong>JPG, JPEG, PNG, PDF</strong> (Max size: 5MB)
                            </p>
                            <div id="fileNameDisplay" style="margin-top: 14px; font-size: 13px; font-weight: 600; color: var(--primary);"></div>
                            <div id="fileErrorDisplay" style="margin-top: 10px; font-size: 13px; color: var(--danger-text); display: none;"></div>
                        </div>

                        <input type="file" id="receiptFile" name="receipt" accept=".jpg,.jpeg,.png,.pdf" style="display: none;" required>
                    </div>

                    <div style="display: flex; gap: 12px; justify-content: flex-end; padding-top: 16px; border-top: 1px solid var(--border-color);">
                        <a href="${ctx}/employee/dashboard" class="btn-outline-custom">Cancel</a>
                        <button type="submit" class="btn-primary-custom" style="padding: 10px 22px;">
                            <i class="fa-solid fa-paper-plane"></i> Submit Claim
                        </button>
                    </div>

                </form>

            </div>

        </div>

        <jsp:include page="../components/footer.jsp"/>

    </main>

</div>

<script src="${pageContext.request.contextPath}/assets/js/script.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const dateInput = document.getElementById("expenseDate");
        if (dateInput) {
            const today = new Date().toISOString().split('T')[0];
            dateInput.setAttribute('max', today);
            dateInput.value = today;
        }
    });
</script>

</body>

</html>