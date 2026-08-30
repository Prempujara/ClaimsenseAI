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
    <title>Profile & Settings - ClaimSense AI</title>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/assets/css/style.css">
    <link rel="stylesheet" href="${ctx}/assets/css/responsive.css">
    <script src="${ctx}/assets/js/theme.js"></script>
</head>

<body>

<div class="dashboard">

    <jsp:include page="components/sidebar.jsp"/>

    <main class="main">

        <jsp:include page="components/navbar.jsp"/>

        <div class="content">

            <!-- HEADER -->
            <div style="margin-bottom: 24px;">
                <h2 style="font-size: 22px; font-weight: 800; margin: 0 0 4px; letter-spacing: -0.4px;">Profile & Settings</h2>
                <p style="color: var(--text-muted); font-size: 13px; margin: 0;">
                    Manage your personal account details, profile photo, and preferences.
                </p>
            </div>

            <!-- ALERTS -->
            <c:if test="${not empty param.ok}">
                <div class="alert" style="padding: 12px 16px; border-radius: 10px; background: var(--success-bg); color: var(--success-text); border: 1px solid var(--success-border); font-size: 13px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px;">
                    <i class="fa-solid fa-circle-check" style="font-size: 16px;"></i>
                    <span>${fn:escapeXml(param.ok)}</span>
                </div>
            </c:if>

            <c:if test="${not empty param.err}">
                <div class="alert alert-danger" style="padding: 12px 16px; border-radius: 10px; background: var(--danger-bg); color: var(--danger-text); border: 1px solid var(--danger-border); font-size: 13px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px;">
                    <i class="fa-solid fa-triangle-exclamation" style="font-size: 16px;"></i>
                    <span>${fn:escapeXml(param.err)}</span>
                </div>
            </c:if>

            <c:if test="${not empty error}">
                <div class="alert alert-danger" style="padding: 12px 16px; border-radius: 10px; background: var(--danger-bg); color: var(--danger-text); border: 1px solid var(--danger-border); font-size: 13px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px;">
                    <i class="fa-solid fa-triangle-exclamation" style="font-size: 16px;"></i>
                    <span>${fn:escapeXml(error)}</span>
                </div>
            </c:if>

            <!-- 2-COLUMN PREMIUM PROFILE LAYOUT -->
            <div class="dashboard-grid" style="grid-template-columns: 280px 1fr; gap: 24px; align-items: start;">
                
                <!-- LEFT COLUMN: PROFILE PHOTO & SUMMARY -->
                <div class="table-box" style="padding: 24px; text-align: center; margin: 0;">
                    <!-- PROFILE PHOTO DISPLAY -->
                    <div style="position: relative; width: 108px; height: 108px; margin: 0 auto 16px;">
                        <c:choose>
                            <c:when test="${user.hasAvatar()}">
                                <img id="avatarPreviewImg" src="${user.avatarPath}" alt="${fn:escapeXml(user.name)}" style="width: 108px; height: 108px; border-radius: 50%; object-fit: cover; border: 3px solid var(--primary-light); box-shadow: var(--shadow-sm);">
                            </c:when>
                            <c:otherwise>
                                <div id="avatarInitialsDiv" class="user-avatar" style="width: 108px; height: 108px; border-radius: 50%; font-size: 38px; font-weight: 800; display: flex; align-items: center; justify-content: center; background: var(--primary-light); color: var(--primary); border: 3px solid var(--primary-ring);">
                                    <c:out value="${user.initials}" default="U" />
                                </div>
                                <img id="avatarPreviewImg" src="" alt="Preview" style="display: none; width: 108px; height: 108px; border-radius: 50%; object-fit: cover; border: 3px solid var(--primary-light);">
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- USER IDENTITY SUMMARY -->
                    <h3 style="font-size: 18px; font-weight: 800; margin: 0 0 4px; color: var(--text-main);">${fn:escapeXml(user.name)}</h3>
                    <span style="font-size: 11px; font-weight: 700; color: var(--primary); background: var(--primary-light); padding: 3px 12px; border-radius: 20px; border: 1px solid var(--primary-ring); display: inline-block; margin-bottom: 8px;">
                        ${user.manager ? 'MANAGER ACCESS' : 'EMPLOYEE PORTAL'}
                    </span>
                    <p style="font-size: 12px; color: var(--text-muted); margin: 0 0 16px; word-break: break-all;">${fn:escapeXml(user.email)}</p>

                    <!-- REMOVE PHOTO ACTION -->
                    <c:if test="${user.hasAvatar()}">
                        <form action="${ctx}/profile" method="POST" style="margin-top: 12px;" onsubmit="return confirm('Remove your profile photo?');">
                            <input type="hidden" name="action" value="removeAvatar">
                            <button type="submit" class="btn-outline-custom" style="width: 100%; padding: 6px 12px; font-size: 12px; color: var(--danger-text); border-color: var(--danger-border);">
                                <i class="fa-solid fa-trash-can"></i> Remove Photo
                            </button>
                        </form>
                    </c:if>
                </div>

                <!-- RIGHT COLUMN: PERSONAL INFORMATION FORM & SETTINGS -->
                <div style="display: flex; flex-direction: column; gap: 24px;">
                    
                    <!-- PERSONAL INFORMATION CARD -->
                    <div class="table-box" style="padding: 24px; margin: 0;">
                        <h4 style="font-size: 16px; font-weight: 800; margin: 0 0 18px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px; color: var(--text-main);">
                            <i class="fa-solid fa-id-card" style="color: var(--primary); margin-right: 8px;"></i> Personal Information
                        </h4>

                        <form action="${ctx}/profile" method="POST" enctype="multipart/form-data">
                            
                            <!-- PHOTO UPLOAD CONTROL -->
                            <div class="form-group" style="margin-bottom: 20px;">
                                <label style="font-size: 12px; font-weight: 700; color: var(--text-main); margin-bottom: 6px; display: block;">Profile Photo</label>
                                <div style="display: flex; align-items: center; gap: 12px;">
                                    <label for="avatarFileInput" class="btn-outline-custom" style="padding: 8px 16px; font-size: 13px; font-weight: 600; cursor: pointer; margin: 0;">
                                        <i class="fa-solid fa-camera" style="margin-right: 6px;"></i> Change Photo
                                    </label>
                                    <input type="file" id="avatarFileInput" name="avatarFile" accept="image/jpeg,image/png,image/webp,image/gif" style="display: none;" onchange="previewAvatarImage(this)">
                                    <span id="fileNameSpan" style="font-size: 12px; color: var(--text-muted);">PNG, JPG, WEBP or GIF (Max 10MB)</span>
                                </div>
                            </div>

                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 20px;">
                                <!-- Full Name -->
                                <div class="form-group" style="margin: 0;">
                                    <label for="profileName" style="font-size: 12px; font-weight: 700;">Full Name <span style="color: var(--danger-text);">*</span></label>
                                    <input type="text" class="input" id="profileName" name="name" value="${fn:escapeXml(user.name)}" required placeholder="Enter full name">
                                </div>

                                <!-- Email Address (Read-Only) -->
                                <div class="form-group" style="margin: 0;">
                                    <label for="profileEmail" style="font-size: 12px; font-weight: 700;">Email Address <span style="font-size: 10px; color: var(--text-muted); font-weight: 500;">(Read-only)</span></label>
                                    <input type="email" class="input" id="profileEmail" name="email" value="${fn:escapeXml(user.email)}" readonly style="opacity: 0.75; cursor: not-allowed; background: var(--table-header-bg);">
                                </div>

                                <!-- Phone Number -->
                                <div class="form-group" style="margin: 0;">
                                    <label for="profilePhone" style="font-size: 12px; font-weight: 700;">Phone Number</label>
                                    <input type="tel" class="input" id="profilePhone" name="phone" value="${fn:escapeXml(user.phone)}" placeholder="+91 98765 43210">
                                </div>

                                <!-- Department -->
                                <div class="form-group" style="margin: 0;">
                                    <label for="profileDept" style="font-size: 12px; font-weight: 700;">Department</label>
                                    <input type="text" class="input" id="profileDept" name="department" value="${fn:escapeXml(user.department)}" placeholder="e.g. Finance, Engineering, Operations">
                                </div>

                                <!-- Job Title -->
                                <div class="form-group" style="margin: 0; grid-column: span 2;">
                                    <label for="profileJob" style="font-size: 12px; font-weight: 700;">Job Title</label>
                                    <input type="text" class="input" id="profileJob" name="jobTitle" value="${fn:escapeXml(user.jobTitle)}" placeholder="e.g. Senior Financial Analyst, Lead Engineer">
                                </div>
                            </div>

                            <div style="display: flex; gap: 12px; justify-content: flex-end; padding-top: 16px; border-top: 1px solid var(--border-color);">
                                <a href="${ctx}/profile" class="btn-outline-custom" style="padding: 9px 20px; font-size: 13px; font-weight: 600; text-decoration: none;">Cancel</a>
                                <button type="submit" class="btn-primary-custom" style="padding: 9px 24px; font-size: 13px; font-weight: 700;">
                                    <i class="fa-solid fa-floppy-disk" style="margin-right: 6px;"></i> Save Changes
                                </button>
                            </div>
                        </form>
                    </div>

                    <!-- PREFERENCES & SETTINGS CARD -->
                    <div class="table-box" style="padding: 24px; margin: 0;">
                        <h4 style="font-size: 16px; font-weight: 800; margin: 0 0 18px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px; color: var(--text-main);">
                            <i class="fa-solid fa-sliders" style="color: var(--primary); margin-right: 8px;"></i> Display & Theme Preferences
                        </h4>

                        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
                            <div>
                                <strong style="font-size: 14px; color: var(--text-main); display: block;">Appearance Mode</strong>
                                <span style="font-size: 12px; color: var(--text-muted);">Switch between Day Light Mode and Dark Night Mode. Preference persists automatically.</span>
                            </div>

                            <button type="button" class="btn-outline-custom" onclick="if(window.ClaimSenseTheme) window.ClaimSenseTheme.toggleTheme();" style="padding: 8px 16px; font-size: 13px; font-weight: 600;">
                                <i class="fa-solid fa-circle-half-stroke" style="margin-right: 6px; color: var(--primary);"></i> Toggle Day / Night Mode
                            </button>
                        </div>
                    </div>

                </div>

            </div>

        </div>

        <jsp:include page="components/footer.jsp"/>

    </main>

</div>

<script src="${ctx}/assets/js/script.js"></script>

<script>
    function previewAvatarImage(input) {
        if (input.files && input.files[0]) {
            const file = input.files[0];
            document.getElementById('fileNameSpan').textContent = file.name + " (" + (file.size / 1024).toFixed(1) + " KB)";

            const reader = new FileReader();
            reader.onload = function(e) {
                const previewImg = document.getElementById('avatarPreviewImg');
                const initialsDiv = document.getElementById('avatarInitialsDiv');

                if (previewImg) {
                    previewImg.src = e.target.result;
                    previewImg.style.display = 'block';
                }
                if (initialsDiv) {
                    initialsDiv.style.display = 'none';
                }
            };
            reader.readAsDataURL(file);
        }
    }
</script>

</body>

</html>
