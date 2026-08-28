<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="user" value="${sessionScope.user}" />

<nav class="topbar">
    <div class="topbar-left">
        <button class="menu-toggle" id="menuToggle" type="button" aria-label="Toggle Navigation">
            <i class="fa-solid fa-bars"></i>
        </button>
        <div class="topbar-title">
            <h3>ClaimSense AI</h3>
        </div>
    </div>

    <div class="topbar-right">
        <!-- Theme Toggle Button -->
        <button type="button" class="theme-toggle-btn" onclick="if(window.ClaimSenseTheme) window.ClaimSenseTheme.toggleTheme();" aria-label="Switch to dark mode" title="Switch to dark mode">
            <span class="toggle-track">
                <span class="toggle-thumb">
                    <i class="fa-solid fa-sun icon-sun"></i>
                    <i class="fa-solid fa-moon icon-moon"></i>
                </span>
            </span>
        </button>

        <div class="user-badge">
            <div class="user-avatar">
                <c:out value="${user.initials}" default="?" />
            </div>
            <div style="display: flex; flex-direction: column;">
                <span class="user-name"><c:out value="${user.name}" default="Guest" /></span>
                <span style="font-size: 11px; color: var(--text-muted); font-weight: 500;">
                    ${user.manager ? 'Manager Access' : 'Employee Portal'}
                </span>
            </div>
        </div>
    </div>
</nav>
