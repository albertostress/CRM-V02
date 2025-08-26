/**
 * EVERTEC CRM Footer Override
 * This script ensures the footer is always replaced with custom branding
 * Works at multiple levels to guarantee persistence
 */

(function() {
    'use strict';

    // Custom footer HTML
    const CUSTOM_FOOTER = '© 2025 EVERTEC CRM — Todos os direitos reservados';

    // Override the footer view if it exists
    if (window.Espo && window.Espo.define) {
        // Override the Site Footer view
        Espo.define('custom:views/site/footer', 'views/site/footer', function (Dep) {
            return Dep.extend({
                templateContent: '<p class="credit small">' + CUSTOM_FOOTER + '</p>',
                
                setup: function () {
                    Dep.prototype.setup.call(this);
                },
                
                afterRender: function () {
                    Dep.prototype.afterRender.call(this);
                    this.replaceFooterContent();
                },
                
                replaceFooterContent: function() {
                    const footerEl = this.$el.find('.credit, .copyright');
                    if (footerEl.length) {
                        footerEl.html(CUSTOM_FOOTER);
                    }
                }
            });
        });
    }

    // Function to replace footer content
    function replaceFooter() {
        // All possible footer selectors
        const selectors = [
            '.footer',
            '.credit',
            '.copyright',
            '[data-name="footer"]',
            '#footer',
            '.site-footer',
            'footer'
        ];

        selectors.forEach(selector => {
            const elements = document.querySelectorAll(selector);
            elements.forEach(el => {
                // Check if contains EspoCRM text
                if (el.textContent && (
                    el.textContent.includes('EspoCRM') || 
                    el.textContent.includes('© 20') ||
                    el.textContent.includes('Espo')
                )) {
                    // Replace with custom footer
                    if (el.tagName === 'P' || el.tagName === 'SPAN' || el.tagName === 'DIV') {
                        el.innerHTML = CUSTOM_FOOTER;
                    } else if (el.querySelector('.credit, .copyright')) {
                        el.querySelector('.credit, .copyright').innerHTML = CUSTOM_FOOTER;
                    }
                }
            });
        });
    }

    // Replace on DOM ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', replaceFooter);
    } else {
        replaceFooter();
    }

    // Replace after any dynamic content loads
    const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            if (mutation.addedNodes.length) {
                replaceFooter();
            }
        });
    });

    // Start observing
    observer.observe(document.body, {
        childList: true,
        subtree: true
    });

    // Replace on hash change (navigation in SPA)
    window.addEventListener('hashchange', function() {
        setTimeout(replaceFooter, 100);
    });

    // Replace periodically to catch any dynamic updates
    setInterval(replaceFooter, 2000);

})();