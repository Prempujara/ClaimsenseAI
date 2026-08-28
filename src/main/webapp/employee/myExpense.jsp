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

            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 28px; flex-wrap: wrap; gap: 16px;">
                <div>
                    <h2 style="font-size: 24px; font-weight: 700; margin-bottom: 4px;">My Expense Claims</h2>
                    <p style="color: var(--text-muted); font-size: 14px; margin: 0;">
                        View and track all submitted claims and approval statuses.
                    </p>
                </div>
                <a href="${ctx}/SubmitExpenseServlet" class="btn-primary-custom">
                    <i class="fa-solid fa-plus"></i> Submit New Expense
                </a>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger" style="padding: 12px; border-radius: 8px; background: #FEE2E2; color: #B91C1C; font-size: 13px; margin-bottom: 20px;">${fn:escapeXml(error)}</div>
            </c:if>

            <div class="table-box">
                <div class="box-header" style="flex-wrap: wrap; gap: 16px;">
                    <div style="display: flex; gap: 8px;" id="filterChips">
                        <button class="btn-primary-custom filter-chip" data-filter="ALL" style="padding: 6px 14px; font-size: 13px;">All (${stats.totalCount})</button>
                        <button class="btn-outline-custom filter-chip" data-filter="PENDING" style="padding: 6px 14px; font-size: 13px;">Pending (${stats.pendingCount})</button>
                        <button class="btn-outline-custom filter-chip" data-filter="APPROVED" style="padding: 6px 14px; font-size: 13px;">Approved (${stats.approvedCount})</button>
                        <button class="btn-outline-custom filter-chip" data-filter="REJECTED" style="padding: 6px 14px; font-size: 13px;">Rejected (${stats.rejectedCount})</button>
                    </div>

                    <div style="position: relative; width: 240px;">
                        <input type="text" id="claimSearch" class="input" placeholder="Search claims..." style="height: 38px; padding-left: 36px; font-size: 13px; margin: 0;">
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
                        <tbody id="claimsBody">
                            <c:forEach var="e" items="${expenses}">
                                <tr class="claim-row" data-status="${e.status}" data-text="${fn:toLowerCase(fn:escapeXml(e.title))} ${fn:toLowerCase(fn:escapeXml(e.categoryName))} ${e.claimCode}">
                                    <td><strong>${e.claimCode}</strong></td>
                                    <td>${fn:escapeXml(e.title)}</td>
                                    <td>${fn:escapeXml(e.categoryName)}</td>
                                    <td><strong>₹${e.amountDisplay}</strong></td>
                                    <td>${e.expenseDateDisplay}</td>
                                    <td>
                                        <jsp:include page="../components/_statusBadge.jsp">
                                            <jsp:param name="status" value="${e.status}" />
                                        </jsp:include>
                                    </td>
                                    <td>
                                        <a href="${ctx}/expense-details?id=${e.expenseId}" class="btn-outline-custom" style="padding: 4px 10px; font-size: 12px;">View Details</a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty expenses}">
                                <tr><td colspan="7" style="text-align: center; color: var(--text-muted); padding: 24px;">You haven’t submitted any expense claims yet.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                    <div id="noMatch" style="display: none; text-align: center; color: var(--text-muted); padding: 24px;">No claims match your filter.</div>
                </div>

            </div>

        </div>

        <jsp:include page="../components/footer.jsp"/>

    </main>

</div>

<script src="${ctx}/assets/js/script.js"></script>
<script>
    // Client-side filter + search over the already-rendered claim rows.
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
            chips.forEach(c => { c.classList.remove('btn-primary-custom'); c.classList.add('btn-outline-custom'); });
            chip.classList.remove('btn-outline-custom'); chip.classList.add('btn-primary-custom');
            apply();
        }));
        if (search) search.addEventListener('input', apply);
    })();
</script>
</body>

</html>
