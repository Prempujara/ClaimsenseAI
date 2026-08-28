<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ClaimSense AI - Login</title>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive.css">
    <script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>
</head>

<body>

<div class="login-page">

    <div class="left-side">
        <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 30px;">
            <div style="width: 48px; height: 48px; background: rgba(255,255,255,0.2); border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 24px;">
                <i class="fa-solid fa-brain"></i>
            </div>
            <h2 style="font-size: 24px; font-weight: 700; margin: 0;">ClaimSense AI</h2>
        </div>

        <h1>Smart Expense & Claim Management</h1>
        <h3>Enterprise AI Platform</h3>

        <p>
            Streamline employee expenses, automated receipt OCR extraction, fraud detection, and instant manager approvals powered by AI.
        </p>

        <div style="margin-top: 40px; display: flex; gap: 24px;">
            <div>
                <h4 style="font-size: 22px; font-weight: 700; margin-bottom: 4px;">99.4%</h4>
                <span style="font-size: 13px; opacity: 0.8;">OCR Precision</span>
            </div>
            <div>
                <h4 style="font-size: 22px; font-weight: 700; margin-bottom: 4px;">< 2s</h4>
                <span style="font-size: 13px; opacity: 0.8;">Claim Processing</span>
            </div>
        </div>
    </div>

    <div class="login-right">
        <div style="position: absolute; top: 20px; right: 24px; z-index: 10;">
            <button type="button" class="theme-toggle-btn" onclick="if(window.ClaimSenseTheme) window.ClaimSenseTheme.toggleTheme();" aria-label="Switch to dark mode" title="Switch to dark mode">
                <span class="toggle-track">
                    <span class="toggle-thumb">
                        <i class="fa-solid fa-sun icon-sun"></i>
                        <i class="fa-solid fa-moon icon-moon"></i>
                    </span>
                </span>
            </button>
        </div>
        <div class="login-card">
            <h2>Welcome Back</h2>
            <p>Log in to access your ClaimSense portal</p>

            <c:set var="loginMsg" value="" />
            <c:choose>
                <c:when test="${param.error eq 'system'}"><c:set var="loginMsg" value="A system error occurred. Please try again shortly." /></c:when>
                <c:when test="${not empty param.error}"><c:set var="loginMsg" value="Invalid email or password. Please try again." /></c:when>
                <c:when test="${not empty param.timeout}"><c:set var="loginMsg" value="Please sign in to continue." /></c:when>
            </c:choose>

            <div id="loginError" class="alert alert-danger" style="${empty loginMsg ? 'display: none;' : ''} padding: 12px; border-radius: 8px; background: #FEE2E2; color: #B91C1C; font-size: 13px; margin-bottom: 20px;"><c:out value="${loginMsg}" /></div>

            <c:if test="${not empty param.loggedout}">
                <div class="alert" style="padding: 12px; border-radius: 8px; background: #DCFCE7; color: #166534; font-size: 13px; margin-bottom: 20px;">You have been signed out.</div>
            </c:if>

            <form action="${pageContext.request.contextPath}/LoginServlet" method="POST" onsubmit="return handleLoginSubmit(event)">

                <div class="form-group">
                    <label for="loginEmail">Email Address</label>
                    <input class="input" type="email" id="loginEmail" name="email" placeholder="name@company.com" required>
                </div>

                <div class="form-group">
                    <label for="loginPassword">Password</label>
                    <input class="input" type="password" id="loginPassword" name="password" placeholder="Enter your password" required>
                </div>

                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; font-size: 13px;">
                    <label style="display: flex; align-items: center; gap: 6px; cursor: pointer; color: var(--text-muted);">
                        <input type="checkbox" name="rememberMe" style="width: auto; height: auto;"> Remember me
                    </label>
                    <a href="#" style="color: var(--primary); text-decoration: none; font-weight: 500;">Forgot password?</a>
                </div>

                <button type="submit" class="login-btn" id="loginSubmitBtn">
                    <span>Sign In</span>
                    <i class="fa-solid fa-arrow-right"></i>
                </button>

            </form>

            <div style="margin-top: 24px; text-align: center; font-size: 13px; color: var(--text-muted);">
                Quick Demo Access:
                <div style="margin-top: 8px; display: flex; gap: 8px; justify-content: center;">
                    <button type="button" onclick="quickLogin('prem@claimsense.com')" class="btn-outline-custom" style="padding: 4px 10px; font-size: 12px;">Employee Portal</button>
                    <button type="button" onclick="quickLogin('manager@claimsense.com')" class="btn-outline-custom" style="padding: 4px 10px; font-size: 12px;">Manager Portal</button>
                </div>
            </div>
        </div>
    </div>

</div>

<script src="${pageContext.request.contextPath}/assets/js/script.js"></script>
<script>
    // Demo shortcut: fill the documented demo credentials and submit through
    // the real LoginServlet (no bypass of authentication).
    function quickLogin(email) {
        document.getElementById('loginEmail').value = email;
        document.getElementById('loginPassword').value = '123456';
        document.getElementById('loginSubmitBtn').closest('form').submit();
    }
</script>
</body>

</html>