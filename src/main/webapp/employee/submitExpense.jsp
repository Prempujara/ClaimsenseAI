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
</head>

<body>

<div class="dashboard">

    <jsp:include page="../components/sidebar.jsp"/>

    <main class="main">

        <jsp:include page="../components/navbar.jsp"/>

        <div class="content">

            <div style="margin-bottom: 28px;">
                <h2 style="font-size: 24px; font-weight: 700; margin-bottom: 4px;">Submit New Expense</h2>
                <p style="color: var(--text-muted); font-size: 14px; margin: 0;">
                    Fill out the form below or upload a receipt to trigger automatic OCR processing.
                </p>
            </div>

            <div class="table-box" style="max-width: 900px;">
                
                <div id="formError" class="alert alert-danger" style="${empty error ? 'display: none;' : ''} padding: 12px; border-radius: 8px; background: #FEE2E2; color: #B91C1C; font-size: 13px; margin-bottom: 20px;"><c:out value="${error}" /></div>

                <form action="${ctx}/SubmitExpenseServlet" method="POST" enctype="multipart/form-data" onsubmit="return validateExpenseForm(event)">

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
                        
                        <div class="form-group">
                            <label for="expenseTitle">Expense Title <span style="color: red;">*</span></label>
                            <input class="input" id="expenseTitle" name="title" placeholder="e.g. Business Lunch with Client" required>
                        </div>

                        <div class="form-group">
                            <label for="expenseCategory">Category <span style="color: red;">*</span></label>
                            <select class="form-select" id="expenseCategory" name="category" required>
                                <option value="" disabled selected>Select Category</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.categoryId}">${fn:escapeXml(cat.categoryName)}</option>
                                </c:forEach>
                            </select>
                            <div style="margin-top: 6px;">
                                <span class="ai-badge">
                                    <i class="fa-solid fa-wand-magic-sparkles"></i> AI category suggestion runs automatically after you submit
                                </span>
                            </div>
                        </div>

                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
                        
                        <div class="form-group">
                            <label for="expenseAmount">Amount (₹) <span style="color: red;">*</span></label>
                            <input type="number" step="0.01" min="0.01" class="input" id="expenseAmount" name="amount" placeholder="0.00" required>
                        </div>

                        <div class="form-group">
                            <label for="expenseDate">Expense Date <span style="color: red;">*</span></label>
                            <input type="date" class="input" id="expenseDate" name="expenseDate" required>
                        </div>

                    </div>

                    <div class="form-group" style="margin-bottom: 24px;">
                        <label for="expenseDescription">Description</label>
                        <textarea class="form-control" id="expenseDescription" name="description" rows="4" placeholder="Provide additional details regarding the expense..."></textarea>
                    </div>

                    <div class="form-group" style="margin-bottom: 28px;">
                        <label>Upload Receipt <span style="color: red;">*</span></label>

                        <div class="dropzone" id="receiptDropzone">
                            <i class="fa-solid fa-cloud-arrow-up"></i>
                            <h5 style="margin-bottom: 6px; font-weight: 600; font-size: 15px;">Click to upload or drag & drop receipt</h5>
                            <p style="font-size: 13px; color: var(--text-muted); margin: 0;">
                                Supported Formats: <strong>JPG, JPEG, PNG, PDF</strong> (Max size: 5MB)
                            </p>
                            <div id="fileNameDisplay" style="margin-top: 12px; font-size: 13px; color: var(--primary);"></div>
                            <div id="fileErrorDisplay" style="margin-top: 8px; font-size: 13px; color: #B91C1C; display: none;"></div>
                        </div>

                        <input type="file" id="receiptFile" name="receipt" accept=".jpg,.jpeg,.png,.pdf" style="display: none;" required>
                    </div>

                    <div style="display: flex; gap: 12px; justify-content: flex-end;">
                        <a href="${ctx}/employee/dashboard" class="btn-outline-custom">Cancel</a>
                        <button type="submit" class="btn-primary-custom">
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
    // Set default max date to today
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