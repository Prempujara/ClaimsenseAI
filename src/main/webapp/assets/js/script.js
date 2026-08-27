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
