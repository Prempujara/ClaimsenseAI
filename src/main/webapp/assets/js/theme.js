/**
 * ClaimSense AI - Enterprise Theme Manager (Day Mode / Night Mode)
 */
(function () {
    const THEME_KEY = 'claimsense-theme';

    function getSavedTheme() {
        try {
            const saved = localStorage.getItem(THEME_KEY);
            if (saved === 'dark' || saved === 'light') {
                return saved;
            }
        } catch (e) {
            console.warn('Unable to access localStorage for theme:', e);
        }
        return (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) ? 'dark' : 'light';
    }

    function applyTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
    }

    // 1. Immediately set saved theme to avoid Flash Of Unstyled Content (FOUC)
    const activeTheme = getSavedTheme();
    applyTheme(activeTheme);

    // 2. Global Theme Controller API
    window.ClaimSenseTheme = {
        getTheme: function () {
            return document.documentElement.getAttribute('data-theme') || 'light';
        },
        setTheme: function (theme) {
            try {
                localStorage.setItem(THEME_KEY, theme);
            } catch (e) {
                console.warn('Unable to save theme to localStorage:', e);
            }
            applyTheme(theme);
            updateToggleButtons(theme);
            window.dispatchEvent(new CustomEvent('claimsense-theme-changed', { detail: { theme: theme } }));
        },
        toggleTheme: function () {
            const current = this.getTheme();
            const nextTheme = current === 'dark' ? 'light' : 'dark';
            this.setTheme(nextTheme);
        }
    };

    function updateToggleButtons(theme) {
        const isDark = theme === 'dark';
        const labelText = isDark ? 'Switch to light mode' : 'Switch to dark mode';
        const toggleBtns = document.querySelectorAll('.theme-toggle-btn');

        toggleBtns.forEach(function (btn) {
            btn.setAttribute('aria-label', labelText);
            btn.setAttribute('title', labelText);

            const sunIcon = btn.querySelector('.icon-sun');
            const moonIcon = btn.querySelector('.icon-moon');

            if (isDark) {
                btn.classList.add('is-dark');
                if (sunIcon) sunIcon.style.display = 'none';
                if (moonIcon) moonIcon.style.display = 'inline-block';
            } else {
                btn.classList.remove('is-dark');
                if (sunIcon) sunIcon.style.display = 'inline-block';
                if (moonIcon) moonIcon.style.display = 'none';
            }
        });
    }

    function setupListeners() {
        updateToggleButtons(window.ClaimSenseTheme.getTheme());

        // Event delegation on document to guarantee clicks work everywhere
        document.addEventListener('click', function (e) {
            const toggleBtn = e.target.closest('.theme-toggle-btn');
            if (toggleBtn) {
                e.preventDefault();
                e.stopPropagation();
                window.ClaimSenseTheme.toggleTheme();
            }
        }, true);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', setupListeners);
    } else {
        setupListeners();
    }
})();
