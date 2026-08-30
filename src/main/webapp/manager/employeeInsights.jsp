<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="user" value="${sessionScope.user}" />
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Employee Insights - ClaimSense AI</title>

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
                    <h2 style="font-size: 22px; font-weight: 800; margin: 0 0 2px; letter-spacing: -0.4px;">Employee Expense Insights</h2>
                    <p style="color: var(--text-muted); font-size: 13px; margin: 0;">
                        Manager analytical view of expense activity, claim volume, and status distributions per employee.
                    </p>
                </div>
            </div>

            <!-- EMPLOYEE INSIGHTS TABLE -->
            <div class="table-box" style="margin-bottom: 32px;">
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Employee</th>
                                <th>Total Claims Submitted</th>
                                <th>Total Expense Value</th>
                                <th>Pending</th>
                                <th>Approved</th>
                                <th>Rejected</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="m" items="${employeeMetrics}">
                                <tr>
                                    <td>
                                        <div style="display: flex; align-items: center; gap: 10px;">
                                            <div class="user-avatar" style="width: 32px; height: 32px; font-size: 12px; font-weight: 700;">
                                                ${fn:toUpperCase(fn:substring(m.name, 0, 1))}
                                            </div>
                                            <span style="font-weight: 600; color: var(--text-main); font-size: 13px;">${fn:escapeXml(m.name)}</span>
                                        </div>
                                    </td>
                                    <td><strong style="font-size: 13px; color: var(--text-main);">${m.totalClaims}</strong></td>
                                    <td><strong style="font-size: 13px; color: var(--primary);">₹${m.totalAmount}</strong></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${m.pendingCount > 0}">
                                                <span style="color: #D97706; font-weight: 700;">${m.pendingCount}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: var(--text-muted);">0</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><span style="color: var(--success-text); font-weight: 700;">${m.approvedCount}</span></td>
                                    <td><span style="color: var(--danger-text); font-weight: 700;">${m.rejectedCount}</span></td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty employeeMetrics}">
                                <tr>
                                    <td colspan="6" style="text-align: center; color: var(--text-muted); padding: 36px 16px;">
                                        No employee expense activity recorded in database.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>

        <jsp:include page="../components/footer.jsp"/>

    </main>

</div>

<script src="${ctx}/assets/js/script.js"></script>

</body>

</html>
