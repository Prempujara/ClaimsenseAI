<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My Expenses - ClaimSense AI</title>

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
                    <h2 style="font-size: 24px; font-weight: 700; margin-bottom: 4px;">My Expense Claims</h2>
                    <p style="color: var(--text-muted); font-size: 14px; margin: 0;">
                        View and track all submitted claims and approval statuses.
                    </p>
                </div>
                <a href="${pageContext.request.contextPath}/employee/submitExpense.jsp" class="btn-primary-custom">
                    <i class="fa-solid fa-plus"></i> Submit New Expense
                </a>
            </div>

            <div class="table-box">
                <div class="box-header" style="flex-wrap: wrap; gap: 16px;">
                    <div style="display: flex; gap: 8px;">
                        <button class="btn-primary-custom" style="padding: 6px 14px; font-size: 13px;">All (25)</button>
                        <button class="btn-outline-custom" style="padding: 6px 14px; font-size: 13px;">Pending (8)</button>
                        <button class="btn-outline-custom" style="padding: 6px 14px; font-size: 13px;">Approved (14)</button>
                        <button class="btn-outline-custom" style="padding: 6px 14px; font-size: 13px;">Rejected (3)</button>
                    </div>

                    <div style="position: relative; width: 240px;">
                        <input type="text" class="input" placeholder="Search claims..." style="height: 38px; padding-left: 36px; font-size: 13px; margin: 0;">
                        <i class="fa-solid fa-magnifying-glass" style="position: absolute; left: 12px; top: 12px; color: var(--text-muted); font-size: 13px;"></i>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Claim ID</th>
                                <th>Expense Title</th>
                                <th>Category</th>
                                <th>Amount</th>
                                <th>Date</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><strong>#EX-1092</strong></td>
                                <td>Uber Ride to Client Office</td>
                                <td>Travel</td>
                                <td><strong>₹450.00</strong></td>
                                <td>24 Aug 2026</td>
                                <td><span class="badge-status approved"><i class="fa-solid fa-check"></i> APPROVED</span></td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/employee/expenseDetails.jsp" class="btn-outline-custom" style="padding: 4px 10px; font-size: 12px;">View Details</a>
                                </td>
                            </tr>
                            <tr>
                                <td><strong>#EX-1091</strong></td>
                                <td>Starbucks Client Meeting</td>
                                <td>Food</td>
                                <td><strong>₹320.00</strong></td>
                                <td>23 Aug 2026</td>
                                <td><span class="badge-status pending"><i class="fa-solid fa-clock"></i> PENDING</span></td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/employee/expenseDetails.jsp" class="btn-outline-custom" style="padding: 4px 10px; font-size: 12px;">View Details</a>
                                </td>
                            </tr>
                            <tr>
                                <td><strong>#EX-1088</strong></td>
                                <td>Amazon Office Supplies</td>
                                <td>Office Supplies</td>
                                <td><strong>₹1,250.00</strong></td>
                                <td>20 Aug 2026</td>
                                <td><span class="badge-status approved"><i class="fa-solid fa-check"></i> APPROVED</span></td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/employee/expenseDetails.jsp" class="btn-outline-custom" style="padding: 4px 10px; font-size: 12px;">View Details</a>
                                </td>
                            </tr>
                            <tr>
                                <td><strong>#EX-1084</strong></td>
                                <td>Team Celebration Dinner</td>
                                <td>Food</td>
                                <td><strong>₹4,800.00</strong></td>
                                <td>18 Aug 2026</td>
                                <td><span class="badge-status rejected"><i class="fa-solid fa-xmark"></i> REJECTED</span></td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/employee/expenseDetails.jsp" class="btn-outline-custom" style="padding: 4px 10px; font-size: 12px;">View Details</a>
                                </td>
                            </tr>
                            <tr>
                                <td><strong>#EX-1079</strong></td>
                                <td>Hotel Stay - Mumbai Conference</td>
                                <td>Accommodation</td>
                                <td><strong>₹8,500.00</strong></td>
                                <td>12 Aug 2026</td>
                                <td><span class="badge-status approved"><i class="fa-solid fa-check"></i> APPROVED</span></td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/employee/expenseDetails.jsp" class="btn-outline-custom" style="padding: 4px 10px; font-size: 12px;">View Details</a>
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

<script src="${pageContext.request.contextPath}/assets/js/script.js"></script>
</body>

</html>