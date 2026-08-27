<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ClaimSense AI - Login</title>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive.css">
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
        <div class="login-card">
            <h2>Welcome Back</h2>
            <p>Log in to access your ClaimSense portal</p>

            <div id="loginError" class="alert alert-danger" style="display: none; padding: 12px; border-radius: 8px; background: #FEE2E2; color: #B91C1C; font-size: 13px; margin-bottom: 20px;"></div>

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
                    <a href="${pageContext.request.contextPath}/employee/dashboard.jsp" class="btn-outline-custom" style="padding: 4px 10px; font-size: 12px;">Employee Portal</a>
                    <a href="${pageContext.request.contextPath}/manager/dashboard.jsp" class="btn-outline-custom" style="padding: 4px 10px; font-size: 12px;">Manager Portal</a>
                </div>
            </div>
        </div>
    </div>

</div>

<script src="${pageContext.request.contextPath}/assets/js/script.js"></script>
</body>

</html>