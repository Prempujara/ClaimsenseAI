<%@ page contentType="text/html;charset=UTF-8" language="java"%>

<aside class="sidebar">

    <div style="display:flex;align-items:center;gap:12px;margin-bottom:35px;">

<div style="width:45px;height:45px;background:#2563EB;border-radius:12px;
display:flex;justify-content:center;align-items:center;color:white;font-weight:bold;">

CS

</div>

<div>

<h3 style="margin:0;">ClaimSense AI</h3>

<p style="margin:0;font-size:13px;color:#d1d5db;">

Expense Management

</p>

</div>

</div>

    <ul>

        <li>
            <a href="${pageContext.request.contextPath}/employee/dashboard.jsp">
                <i class="fa-solid fa-house"></i>
                Dashboard
            </a>
        </li>

        <li>
            <a href="${pageContext.request.contextPath}/employee/submitExpense.jsp">
                <i class="fa-solid fa-receipt"></i>
                Submit Expense
            </a>
        </li>

        <li>
            <a href="${pageContext.request.contextPath}/employee/myExpense.jsp">
                <i class="fa-solid fa-wallet"></i>
                My Expenses
            </a>
        </li>

        <li>
            <a href="${pageContext.request.contextPath}/employee/expenseDetails.jsp">
                <i class="fa-solid fa-file"></i>
                Expense Details
            </a>
        </li>

        <li>
            <a href="${pageContext.request.contextPath}/manager/dashboard.jsp">
                <i class="fa-solid fa-user-check"></i>
                Manager Dashboard
            </a>
        </li>

    </ul>

</aside>