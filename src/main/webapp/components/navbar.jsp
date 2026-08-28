<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="user" value="${sessionScope.user}" />

<nav class="topbar">
    <div class="topbar-left">
        <button class="menu-toggle" id="menuToggle" type="button">
            <i class="fa-solid fa-bars"></i>
        </button>
        <div class="topbar-title">
            <h3>ClaimSense AI Workspace</h3>
        </div>
    </div>

    <div class="topbar-right">
        <div class="user-badge">
            <div class="user-avatar">
                <c:out value="${user.initials}" default="?" />
            </div>
            <div style="display: flex; flex-direction: column;">
                <span class="user-name"><c:out value="${user.name}" default="Guest" /></span>
                <span style="font-size: 11px; color: var(--text-muted);">
                    ${user.manager ? 'Manager' : 'Employee'}
                </span>
            </div>
        </div>
    </div>
</nav>
