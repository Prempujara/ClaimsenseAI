<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="user" value="${sessionScope.user}" />
<c:set var="reqUri" value="${pageContext.request.requestURI}" />

<aside class="sidebar" id="sidebar">

    <div class="sidebar-header">
        <div class="logo-icon">
            <i class="fa-solid fa-microchip"></i>
        </div>
        <div class="sidebar-brand">
            <h3>ClaimSense AI</h3>
            <p>Enterprise Expenses</p>
        </div>
    </div>

    <ul class="sidebar-nav">

        <c:if test="${user.employee}">
            <div style="margin: 12px 0 6px 14px; font-size: 10px; text-transform: uppercase; color: var(--sidebar-text); letter-spacing: 1px; font-weight: 700; opacity: 0.6;">
                EMPLOYEE
            </div>

            <li class="${fn:contains(reqUri, '/employee/dashboard') ? 'active' : ''}">
                <a href="${ctx}/employee/dashboard">
                    <i class="fa-solid fa-chart-pie"></i>
                    <span>Dashboard</span>
                </a>
            </li>

            <li class="${fn:contains(reqUri, '/SubmitExpenseServlet') || fn:contains(reqUri, 'submitExpense') ? 'active' : ''}">
                <a href="${ctx}/SubmitExpenseServlet">
                    <i class="fa-solid fa-file-circle-plus"></i>
                    <span>Submit Expense</span>
                </a>
            </li>

            <li class="${fn:contains(reqUri, '/employee/expenses') || fn:contains(reqUri, 'myExpense') ? 'active' : ''}">
                <a href="${ctx}/employee/expenses">
                    <i class="fa-solid fa-receipt"></i>
                    <span>My Expenses</span>
                </a>
            </li>

            <li class="${fn:contains(reqUri, '/employee/analytics') ? 'active' : ''}">
                <a href="${ctx}/employee/analytics">
                    <i class="fa-solid fa-chart-line"></i>
                    <span>Spending Analytics</span>
                </a>
            </li>

            <li class="${fn:contains(reqUri, '/employee/ai-insights') ? 'active' : ''}">
                <a href="${ctx}/employee/ai-insights">
                    <i class="fa-solid fa-brain"></i>
                    <span>AI Insights</span>
                </a>
            </li>
        </c:if>

        <c:if test="${user.manager}">
            <div style="margin: 12px 0 6px 14px; font-size: 10px; text-transform: uppercase; color: var(--sidebar-text); letter-spacing: 1px; font-weight: 700; opacity: 0.6;">
                MANAGEMENT
            </div>

            <li class="${fn:endsWith(reqUri, '/manager/dashboard') || fn:endsWith(reqUri, '/manager/dashboard.jsp') ? 'active' : ''}">
                <a href="${ctx}/manager/dashboard">
                    <i class="fa-solid fa-gauge-high"></i>
                    <span>Overview</span>
                </a>
            </li>

            <li class="${fn:contains(reqUri, '/manager/approvals') ? 'active' : ''}">
                <a href="${ctx}/manager/approvals">
                    <i class="fa-solid fa-circle-check"></i>
                    <span>Review & Approvals</span>
                </a>
            </li>

            <li class="${fn:contains(reqUri, '/manager/all-claims') ? 'active' : ''}">
                <a href="${ctx}/manager/all-claims">
                    <i class="fa-solid fa-list-check"></i>
                    <span>All Claims</span>
                </a>
            </li>

            <li class="${fn:contains(reqUri, '/manager/ai-risk') ? 'active' : ''}">
                <a href="${ctx}/manager/ai-risk">
                    <i class="fa-solid fa-shield-cat"></i>
                    <span>AI Risk Center</span>
                </a>
            </li>

            <li class="${fn:contains(reqUri, '/manager/analytics') ? 'active' : ''}">
                <a href="${ctx}/manager/analytics">
                    <i class="fa-solid fa-chart-column"></i>
                    <span>Spending Analytics</span>
                </a>
            </li>

            <li class="${fn:contains(reqUri, '/manager/employee-insights') ? 'active' : ''}">
                <a href="${ctx}/manager/employee-insights">
                    <i class="fa-solid fa-users"></i>
                    <span>Employee Insights</span>
                </a>
            </li>

            <li class="${fn:contains(reqUri, '/manager/history') ? 'active' : ''}">
                <a href="${ctx}/manager/history">
                    <i class="fa-solid fa-clock-rotate-left"></i>
                    <span>Approval History</span>
                </a>
            </li>
        </c:if>

        <div style="margin: 14px 0 6px 14px; font-size: 10px; text-transform: uppercase; color: var(--sidebar-text); letter-spacing: 1px; font-weight: 700; opacity: 0.6;">
            ACCOUNT
        </div>

        <li class="${fn:contains(reqUri, '/profile') ? 'active' : ''}">
            <a href="${ctx}/profile">
                <i class="fa-solid fa-user-gear"></i>
                <span>Profile & Settings</span>
            </a>
        </li>

    </ul>

    <div style="margin-top: auto; padding-top: 14px; border-top: 1px solid rgba(255,255,255,0.08);">
        <a href="${ctx}/LogoutServlet" style="display: flex; align-items: center; gap: 12px; padding: 9px 14px; color: var(--sidebar-text); text-decoration: none; border-radius: 8px; font-size: 13px; font-weight: 500; transition: all 0.2s ease;">
            <i class="fa-solid fa-arrow-right-from-bracket"></i>
            <span>Sign Out</span>
        </a>
    </div>

</aside>
