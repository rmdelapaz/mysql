/* Apply the saved or system theme before CSS paints. */
(function () {
    let saved = null;
    try { saved = localStorage.getItem('theme'); } catch (_) { /* storage unavailable */ }
    const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    document.documentElement.setAttribute('data-theme', saved || (prefersDark ? 'dark' : 'light'));
})();
