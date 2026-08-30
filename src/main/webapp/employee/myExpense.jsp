<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My Expenses - ClaimSense AI</title>

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
                    <h2 style="font-size: 22px; font-weight: 800; margin: 0 0 2px; letter-spacing: -0.4px;">My Expenses</h2>
                    <p style="color: var(--text-muted); font-size: 13px; margin: 0;">
                        Track and manage all your submitted expense records.
                    </p>
                </div>
                <a href="${ctx}/SubmitExpenseServlet" class="btn-primary-custom" style="padding: 9px 20px; font-size: 13px; font-weight: 700; text-decoration: none; border-radius: 9px;">
                    <i class="fa-solid fa-plus" style="margin-right: 6px;"></i> Submit Expense
                </a>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger" style="padding: 12px 16px; border-radius: 10px; background: var(--danger-bg); color: var(--danger-text); border: 1px solid var(--danger-border); font-size: 13px; margin-bottom: 20px;">
                    <i class="fa-solid fa-circle-exclamation"></i> ${fn:escapeXml(error)}
                </div>
            </c:if>

            <div class="table-box" style="margin-bottom: 32px;">
                <!-- FILTER & SEARCH BAR -->
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px; margin-bottom: 20px;">
                    <div style="display: flex; gap: 6px; flex-wrap: wrap;" id="filterChips">
                        <button class="btn-primary-custom filter-chip" data-filter="ALL" style="padding: 6px 14px; font-size: 12px; font-weight: 700;">All (${stats.totalCount})</button>
                        <button class="btn-outline-custom filter-chip" data-filter="PENDING" style="padding: 6px 14px; font-size: 12px; font-weight: 600;">Pending (${stats.pendingCount})</button>
                        <button class="btn-outline-custom filter-chip" data-filter="APPROVED" style="padding: 6px 14px; font-size: 12px; font-weight: 600;">Approved (${stats.approvedCount})</button>
                        <button class="btn-outline-custom filter-chip" data-filter="REJECTED" style="padding: 6px 14px; font-size: 12px; font-weight: 600;">Rejected (${stats.rejectedCount})</button>
                    </div>

                    <div style="position: relative; width: 260px;">
                        <input type="text" id="claimSearch" class="input" placeholder="Search claims..." style="height: 38px; padding-left: 36px; font-size: 13px; margin: 0;">
                        <i class="fa-solid fa-magnifying-glass" style="position: absolute; left: 12px; top: 12px; color: var(--text-muted); font-size: 13px;"></i>
                    </div>
                </div>

                <!-- EXPENSES TABLE -->
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Claim ID</th>
                                <th>Expense</th>
                                <th>Category</th>
                                <th>Amount</th>
                                <th>Date</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody id="claimsBody">
                            <c:forEach var="e" items="${expenses}">
                                <tr class="claim-row" data-status="${e.status}" data-text="${fn:toLowerCase(fn:escapeXml(e.title))} ${fn:toLowerCase(fn:escapeXml(e.categoryName))} ${e.claimCode}">
                                    <td><strong style="color: var(--primary); font-weight: 700; font-size: 12px;">${e.claimCode}</strong></td>
                                    <td>
                                        <a href="${ctx}/expense-details?id=${e.expenseId}" style="text-decoration: none; font-weight: 700; color: var(--text-main); font-size: 13px;">
                                            ${fn:escapeXml(e.title)}
                                        </a>
                                    </td>
                                    <td><span style="font-size: 13px; color: var(--text-main); font-weight: 500;">${fn:escapeXml(e.categoryName)}</span></td>
                                    <td><strong style="font-size: 13px; color: var(--text-main);">₹${e.amountDisplay}</strong></td>
                                    <td><span style="font-size: 12px; color: var(--text-muted);">${e.expenseDateDisplay}</span></td>
                                    <td>
                                        <jsp:include page="../components/_statusBadge.jsp">
                                            <jsp:param name="status" value="${e.status}" />
                                        </jsp:include>
                                    </td>
                                    <td>
                                        <a href="${ctx}/expense-details?id=${e.expenseId}" class="btn-outline-custom" style="padding: 4px 10px; font-size: 12px; font-weight: 600; text-decoration: none;">
                                            View Details
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            
                            <!-- EMPTY STATE -->
                            <c:if test="${empty expenses}">
                                <tr>
                                    <td colspan="7" style="text-align: center; color: var(--text-muted); padding: 40px 16px;">
                                        <i class="fa-solid fa-folder-open" style="font-size: 24px; color: var(--border-color); margin-bottom: 8px; display: block;"></i>
                                        <span style="font-size: 14px; font-weight: 700; color: var(--text-main); display: block; margin-bottom: 2px;">No expenses submitted yet</span>
                                        <a href="${ctx}/SubmitExpenseServlet" style="font-size: 12px; color: var(--primary); font-weight: 600; text-decoration: none;">Submit your first claim →</a>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                    <div id="noMatch" style="display: none; text-align: center; color: var(--text-muted); padding: 32px 16px;">
                        <i class="fa-solid fa-magnifying-glass-minus" style="font-size: 24px; color: var(--border-color); margin-bottom: 8px; display: block;"></i>
                        <span style="font-weight: 600; font-size: 13px;">No claims match your search</span>
                    </div>
                </div>

            </div>

        </div>

        <jsp:include page="../components/footer.jsp"/>

    </main>

</div>

<script src="${ctx}/assets/js/script.js"></script>
<script>
    (function () {
        const rows = Array.from(document.querySelectorAll('.claim-row'));
        const chips = Array.from(document.querySelectorAll('.filter-chip'));
        const search = document.getElementById('claimSearch');
        const noMatch = document.getElementById('noMatch');
        let activeFilter = 'ALL';

        function apply() {
            const q = (search.value || '').trim().toLowerCase();
            let visible = 0;
            rows.forEach(r => {
                const statusOk = activeFilter === 'ALL' || r.dataset.status === activeFilter;
                const textOk = !q || (r.dataset.text || '').indexOf(q) !== -1;
                const show = statusOk && textOk;
                r.style.display = show ? '' : 'none';
                if (show) visible++;
            });
            if (noMatch) noMatch.style.display = (rows.length && visible === 0) ? 'block' : 'none';
        }

        chips.forEach(chip => chip.addEventListener('click', () => {
            activeFilter = chip.dataset.filter;
            chips.forEach(c => {
                c.classList.remove('btn-primary-custom');
                c.classList.add('btn-outline-custom');
                c.style.fontWeight = '600';
            });
            chip.classList.remove('btn-outline-custom');
            chip.classList.add('btn-primary-custom');
            chip.style.fontWeight = '700';
            apply();
        }));
        if (search) search.addEventListener('input', apply);
    })();
</script>
</body>

</html>


