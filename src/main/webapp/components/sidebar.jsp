<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%
    String currentURI = request.getRequestURI();
%>

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

        <li class="<%= currentURI.contains("/employee/dashboard.jsp") ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/employee/dashboard.jsp">
                <i class="fa-solid fa-house"></i>
                <span>Employee Dashboard</span>
            </a>
        </li>

        <li class="<%= currentURI.contains("/employee/submitExpense.jsp") ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/employee/submitExpense.jsp">
                <i class="fa-solid fa-plus-circle"></i>
                <span>Submit Expense</span>
            </a>
        </li>

        <li class="<%= currentURI.contains("/employee/myExpense.jsp") ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/employee/myExpense.jsp">
                <i class="fa-solid fa-receipt"></i>
                <span>My Expenses</span>
            </a>
        </li>

        <li class="<%= currentURI.contains("/employee/expenseDetails.jsp") ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/employee/expenseDetails.jsp">
                <i class="fa-solid fa-file-invoice-dollar"></i>
                <span>Expense Details</span>
            </a>
        </li>

        <div style="margin: 20px 0 10px 14px; font-size: 11px; text-transform: uppercase; color: var(--sidebar-text); letter-spacing: 1px; font-weight: 600;">
            Manager Access
        </div>

        <li class="<%= currentURI.contains("/manager/dashboard.jsp") ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/manager/dashboard.jsp">
                <i class="fa-solid fa-user-shield"></i>
                <span>Manager Dashboard</span>
            </a>
        </li>

    </ul>

    <div style="margin-top: auto; padding-top: 20px; border-top: 1px solid rgba(255,255,255,0.08);">
        <a href="${pageContext.request.contextPath}/auth/login.jsp" style="display: flex; align-items: center; gap: 12px; padding: 12px 14px; color: var(--sidebar-text); text-decoration: none; border-radius: 8px; font-size: 14px;">
            <i class="fa-solid fa-right-from-bracket"></i>
            <span>Sign Out</span>
        </a>
    </div>

</aside>