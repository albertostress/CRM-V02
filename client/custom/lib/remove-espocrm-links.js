document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('a[href*="espocrm.com"]').forEach(el => el.remove());
});