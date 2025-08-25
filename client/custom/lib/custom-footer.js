// Custom Footer Replacement
(function() {
    'use strict';
    
    function replaceFooter() {
        const selectors = [
            '.credit.small',
            '.credit',
            'p.credit',
            '#footer .credit',
            'footer .credit'
        ];
        
        selectors.forEach(selector => {
            const elements = document.querySelectorAll(selector);
            elements.forEach(element => {
                if (element.textContent.includes('EspoCRM') || 
                    element.textContent.includes('Evertec') ||
                    element.innerHTML.includes('espocrm.com')) {
                    element.textContent = '© 2025 EVERTEC CRM — Todos os direitos reservados';
                    element.style.textAlign = 'center';
                }
            });
        });
    }
    
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', replaceFooter);
    } else {
        replaceFooter();
    }
    
    setInterval(replaceFooter, 500);
    
    const observer = new MutationObserver(replaceFooter);
    if (document.body) {
        observer.observe(document.body, {
            childList: true,
            subtree: true
        });
    }
})();