/**
 * EVERTEC CRM - Hide Extensions Section
 * This script removes all references to Official Extensions
 */

(function() {
    'use strict';

    function hideExtensions() {
        // Find and hide any element containing extension-related text
        const extensionTexts = [
            'Official Extensions',
            'Advanced Pack',
            'Sales Pack',
            'Products',
            'Quotes',
            'Sales Orders',
            'Purchase Orders',
            'Project Management',
            'Google Integration',
            'Outlook Integration',
            'VoIP Integration',
            'MailChimp Integration',
            'Real Estate'
        ];

        extensionTexts.forEach(text => {
            // Find all elements containing this text
            const elements = document.evaluate(
                `//*[contains(text(), '${text}')]`,
                document,
                null,
                XPathResult.ORDERED_NODE_SNAPSHOT_TYPE,
                null
            );

            for (let i = 0; i < elements.snapshotLength; i++) {
                const element = elements.snapshotItem(i);
                
                // Find the panel or container parent
                let parent = element;
                while (parent && parent !== document.body) {
                    if (parent.classList.contains('panel') || 
                        parent.classList.contains('col-sm-4') ||
                        parent.classList.contains('col-md-4') ||
                        parent.classList.contains('extensions-container')) {
                        parent.style.display = 'none';
                        break;
                    }
                    parent = parent.parentElement;
                }
            }
        });

        // Also hide by specific selectors
        const selectors = [
            '.extensions-panel',
            '[data-name="extensions"]',
            '.admin-extensions',
            '#admin .col-sm-4:last-child',
            '.panel:has(.panel-heading:contains("Official"))'
        ];

        selectors.forEach(selector => {
            try {
                const elements = document.querySelectorAll(selector);
                elements.forEach(el => {
                    el.style.display = 'none';
                });
            } catch(e) {
                // Some selectors might not be supported in all browsers
            }
        });
    }

    // Run on DOM ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', hideExtensions);
    } else {
        hideExtensions();
    }

    // Run after hash changes (navigation)
    window.addEventListener('hashchange', function() {
        setTimeout(hideExtensions, 100);
    });

    // Observer for dynamic content
    const observer = new MutationObserver(function(mutations) {
        hideExtensions();
    });

    // Start observing
    if (document.body) {
        observer.observe(document.body, {
            childList: true,
            subtree: true
        });
    }

    // Run periodically to catch any late-loading content
    setInterval(hideExtensions, 2000);

})();