<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="uri" value="${pageContext.request.requestURI}" />
<c:set var="user" value="${sessionScope.user}" />

<aside class="sidebar" id="sidebar">

    <div class="sidebar-header">
        <div class="logo-icon">
            <i class="fa-solid fa-brain"></i>
        </div>
        <div class="sidebar-brand">
            <h3>ClaimSense AI</h3>
            <p>Expense Management</p>
        </div>
    </div>

    <ul class="sidebar-nav">

        <c:if test="${user.employee}">
            <li class="${fn:contains(uri, '/employee/dashboard') ? 'active' : ''}">
                <a href="${ctx}/employee/dashboard">
                    <i class="fa-solid fa-house"></i>
                    <span>Dashboard</span>
                </a>
            </li>

            <li class="${fn:contains(uri, '/SubmitExpenseServlet') ? 'active' : ''}">
                <a href="${ctx}/SubmitExpenseServlet">
                    <i class="fa-solid fa-plus-circle"></i>
                    <span>Submit Expense</span>
                </a>
            </li>

            <li class="${fn:contains(uri, '/employee/expenses') ? 'active' : ''}">
                <a href="${ctx}/employee/expenses">
                    <i class="fa-solid fa-receipt"></i>
                    <span>My Expenses</span>
                </a>
            </li>
        </c:if>

        <c:if test="${user.manager}">
            <div style="margin: 4px 0 10px 14px; font-size: 11px; text-transform: uppercase; color: var(--sidebar-text); letter-spacing: 1px; font-weight: 600;">
                Manager Access
            </div>

            <li class="${fn:contains(uri, '/manager/dashboard') ? 'active' : ''}">
                <a href="${ctx}/manager/dashboard">
                    <i class="fa-solid fa-user-shield"></i>
                    <span>Review & Approvals</span>
                </a>
            </li>
        </c:if>

    </ul>

    <div style="margin-top: auto; padding-top: 20px; border-top: 1px solid rgba(255,255,255,0.08);">
        <a href="${ctx}/LogoutServlet" style="display: flex; align-items: center; gap: 12px; padding: 12px 14px; color: var(--sidebar-text); text-decoration: none; border-radius: 8px; font-size: 14px;">
            <i class="fa-solid fa-right-from-bracket"></i>
            <span>Sign Out</span>
        </a>
    </div>

</aside>
