/**
 * ClaimSense AI - Main Interactive Frontend Logic
 */

document.addEventListener('DOMContentLoaded', () => {
    // Mobile Sidebar Toggle
    const menuToggle = document.getElementById('menuToggle');
    const sidebar = document.getElementById('sidebar');

    if (menuToggle && sidebar) {
        menuToggle.addEventListener('click', () => {
            sidebar.classList.toggle('active');
        });
    }

    // Receipt File Upload & Drag and Drop Preview Validation
    const fileInput = document.getElementById('receiptFile');
    const dropzone = document.getElementById('receiptDropzone');
    const fileNameDisplay = document.getElementById('fileNameDisplay');
    const fileErrorDisplay = document.getElementById('fileErrorDisplay');

    if (dropzone && fileInput) {
        ['dragenter', 'dragover'].forEach(eventName => {
            dropzone.addEventListener(eventName, (e) => {
                e.preventDefault();
                e.stopPropagation();
                dropzone.classList.add('dragover');
            });
        });

        ['dragleave', 'drop'].forEach(eventName => {
            dropzone.addEventListener(eventName, (e) => {
                e.preventDefault();
                e.stopPropagation();
                dropzone.classList.remove('dragover');
            });
        });

        dropzone.addEventListener('drop', (e) => {
            const files = e.dataTransfer.files;
            if (files.length > 0) {
                fileInput.files = files;
                validateAndDisplayFile(files[0]);
            }
        });

        dropzone.addEventListener('click', () => {
            fileInput.click();
        });

        fileInput.addEventListener('change', (e) => {
            if (e.target.files.length > 0) {
                validateAndDisplayFile(e.target.files[0]);
            }
        });
    }

    function validateAndDisplayFile(file) {
        const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf'];
        const allowedExtensions = ['.jpg', '.jpeg', '.png', '.pdf'];
        const ext = file.name.substring(file.name.lastIndexOf('.')).toLowerCase();

        if (!allowedTypes.includes(file.type) && !allowedExtensions.includes(ext)) {
            showFileError('Invalid file type! Please upload JPG, JPEG, PNG, or PDF.');
            fileInput.value = '';
            if (fileNameDisplay) fileNameDisplay.innerText = '';
            return false;
        }

        const maxSize = 5 * 1024 * 1024; // 5MB
        if (file.size > maxSize) {
            showFileError('File size exceeds 5MB limit.');
            fileInput.value = '';
            if (fileNameDisplay) fileNameDisplay.innerText = '';
            return false;
        }

        if (fileErrorDisplay) fileErrorDisplay.style.display = 'none';
        if (fileNameDisplay) {
            fileNameDisplay.innerHTML = `<i class="fa-solid fa-file-circle-check text-success"></i> <strong>Selected:</strong> ${file.name} (${(file.size / 1024).toFixed(1)} KB)`;
        }
        triggerReceiptAnalysis(file);
        return true;
    }

    function showFileError(msg) {
        if (fileErrorDisplay) {
            fileErrorDisplay.innerText = msg;
            fileErrorDisplay.style.display = 'block';
        } else {
            alert(msg);
        }
    }
});

// Expense Submit Form Client Validation
function validateExpenseForm(e) {
    const amount = document.getElementById('expenseAmount')?.value;
    const date = document.getElementById('expenseDate')?.value;
    const title = document.getElementById('expenseTitle')?.value;
    const formError = document.getElementById('formError');

    if (formError) formError.style.display = 'none';

    if (!title || !title.trim()) {
        showFormError('Expense title is required.');
        e.preventDefault();
        return false;
    }

    if (!amount || parseFloat(amount) <= 0) {
        showFormError('Please enter a valid positive amount.');
        e.preventDefault();
        return false;
    }

    if (!date) {
        showFormError('Please select a valid expense date.');
        e.preventDefault();
        return false;
    }

    const selectedDate = new Date(date);
    const today = new Date();
    today.setHours(23, 59, 59, 999);

    if (selectedDate > today) {
        showFormError('Expense date cannot be in the future.');
        e.preventDefault();
        return false;
    }

    return true;
}

function showFormError(msg) {
    const formError = document.getElementById('formError');
    if (formError) {
        formError.innerText = msg;
        formError.style.display = 'block';
    } else {
        alert(msg);
    }
}

// Login Form Validation & Loading State
function handleLoginSubmit(event) {
    const email = document.getElementById('loginEmail')?.value;
    const password = document.getElementById('loginPassword')?.value;
    const errorBox = document.getElementById('loginError');
    const loginBtn = document.getElementById('loginSubmitBtn');

    if (errorBox) errorBox.style.display = 'none';

    if (!email || !email.includes('@')) {
        event.preventDefault();
        if (errorBox) {
            errorBox.innerText = 'Please enter a valid email address.';
            errorBox.style.display = 'block';
        }
        return false;
    }

    if (!password || password.length < 4) {
        event.preventDefault();
        if (errorBox) {
            errorBox.innerText = 'Password must be at least 4 characters long.';
            errorBox.style.display = 'block';
        }
        return false;
    }

    if (loginBtn) {
        loginBtn.disabled = true;
        loginBtn.innerHTML = `<i class="fa-solid fa-spinner fa-spin"></i> Logging in...`;
    }

    return true;
}


// AI-Powered Receipt Autofill Handler
function triggerReceiptAnalysis(file) {
    const banner = document.getElementById('aiAutofillBanner');
    const merchantInput = document.getElementById('expenseTitle');
    const amountInput = document.getElementById('expenseAmount');
    const dateInput = document.getElementById('expenseDate');
    const categorySelect = document.getElementById('expenseCategory');

    if (banner) {
        banner.style.display = 'block';
        banner.className = 'alert alert-info';
        banner.style.background = 'rgba(59, 130, 246, 0.1)';
        banner.style.border = '1px solid rgba(59, 130, 246, 0.2)';
        banner.innerHTML = `<i class="fa-solid fa-wand-magic-sparkles fa-spin" style="color: var(--primary); margin-right: 6px;"></i> <strong>Analyzing receipt with AI...</strong> Extracting details and predicting expense category.`;
    }

    const formData = new FormData();
    formData.append('receipt', file);

    const ctx = (window.location.pathname.startsWith('/claimsense') ? '/claimsense' : '');

    fetch(ctx + '/AnalyzeReceiptServlet', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (!data || !data.success) {
            if (banner) {
                banner.className = 'alert alert-warning';
                banner.style.background = 'rgba(245, 158, 11, 0.1)';
                banner.style.border = '1px solid rgba(245, 158, 11, 0.2)';
                banner.innerHTML = `<i class="fa-solid fa-circle-info" style="color: #F59E0B; margin-right: 6px;"></i> ${data.message || 'AI autofill unavailable — please enter details manually.'}`;
            }
            return;
        }

        // Apply extracted merchant
        if (data.merchant && merchantInput) {
            merchantInput.value = data.merchant;
        }

        // Apply extracted amount
        if (data.amount && amountInput) {
            amountInput.value = parseFloat(data.amount).toFixed(2);
        }

        // Apply extracted date
        if (data.date && dateInput) {
            dateInput.value = data.date;
        }

        // Apply predicted categoryId
        if (data.categoryId && categorySelect) {
            categorySelect.value = data.categoryId;
        }

        const confidencePct = Math.round((data.confidence || 0.85) * 100);

        if (banner) {
            banner.className = 'alert alert-success';
            banner.style.background = 'rgba(16, 185, 129, 0.1)';
            banner.style.border = '1px solid rgba(16, 185, 129, 0.2)';
            banner.innerHTML = `
                <div style="display: flex; align-items: center; justify-content: space-between; width: 100%;">
                    <div>
                        <i class="fa-solid fa-wand-magic-sparkles" style="color: #10B981; margin-right: 6px;"></i>
                        <strong>AI Autofill Applied:</strong> Extracted merchant, date, amount & suggested category <strong>"${data.category || ''}"</strong>
                        <span style="background: #10B981; color: #FFFFFF; padding: 2px 8px; border-radius: 12px; font-size: 11px; margin-left: 6px; font-weight: 700;">${confidencePct}% confidence</span>
                    </div>
                    <span style="font-size: 11px; color: var(--text-muted);">(All fields remain editable)</span>
                </div>
            `;
        }
    })
    .catch(err => {
        console.warn('AI Receipt Autofill error:', err);
        if (banner) {
            banner.className = 'alert alert-warning';
            banner.style.background = 'rgba(245, 158, 11, 0.1)';
            banner.style.border = '1px solid rgba(245, 158, 11, 0.2)';
            banner.innerHTML = `<i class="fa-solid fa-circle-info" style="color: #F59E0B; margin-right: 6px;"></i> AI receipt autofill unavailable — please enter expense details manually.`;
        }
    });
}
