<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

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
        <button type="button" class="theme-toggle-btn" onclick="if(window.ClaimSenseTheme) window.ClaimSenseTheme.toggleTheme();" aria-label="Switch Theme" title="Switch Theme">
            <span class="toggle-track">
                <span class="toggle-thumb">
                    <i class="fa-solid fa-sun icon-sun"></i>
                    <i class="fa-solid fa-moon icon-moon"></i>
                </span>
            </span>
        </button>

        <a href="${pageContext.request.contextPath}/profile" class="user-badge" style="text-decoration: none; cursor: pointer;">
            <c:choose>
                <c:when test="${not empty user and user.hasAvatar()}">
                    <img src="${user.avatarPath}" alt="${fn:escapeXml(user.name)}" class="user-avatar" style="object-fit: cover; border-radius: 50%; width: 34px; height: 34px;">
                </c:when>
                <c:otherwise>
                    <div class="user-avatar">
                        <c:out value="${user.initials}" default="?" />
                    </div>
                </c:otherwise>
            </c:choose>
            <div style="display: flex; flex-direction: column;">
                <span class="user-name"><c:out value="${user.name}" default="Guest" /></span>
                <span style="font-size: 11px; color: var(--text-muted); font-weight: 500;">
                    ${user.manager ? 'Manager Access' : 'Employee Portal'}
                </span>
            </div>
        </a>
    </div>
</nav>
