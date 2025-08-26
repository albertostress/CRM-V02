// EVERTEC CRM - Core Override JavaScript
// Remove About e links EspoCRM
document.addEventListener('DOMContentLoaded', function () {
    // Substitui rodapé
    const footerElements = document.querySelectorAll('.footer, .credit, .copyright, p.credit');
    footerElements.forEach(function(el) {
        if (el) {
            el.innerHTML = '© 2025 EVERTEC CRM — Todos os direitos reservados';
            el.style.textAlign = 'center';
        }
    });

    // Remove About do menu
    const aboutLinks = document.querySelectorAll('a[href*="#About"], [data-name="about"], li[data-name="about"]');
    aboutLinks.forEach(function(el) {
        if (el && el.parentNode) {
            el.parentNode.removeChild(el);
        }
    });

    // Remove links espocrm.com
    const espocrmLinks = document.querySelectorAll('a[href*="espocrm.com"]');
    espocrmLinks.forEach(function(el) {
        if (el && el.parentNode) {
            el.parentNode.removeChild(el);
        }
    });
    
    // Substitui texto EspoCRM em todo o DOM
    function replaceInText(element, pattern, replacement) {
        for (let node of element.childNodes) {
            switch (node.nodeType) {
                case Node.ELEMENT_NODE:
                    replaceInText(node, pattern, replacement);
                    break;
                case Node.TEXT_NODE:
                    node.textContent = node.textContent.replace(pattern, replacement);
                    break;
            }
        }
    }
    
    // Aplica substituições
    setTimeout(function() {
        replaceInText(document.body, /EspoCRM/g, 'EVERTEC CRM');
        document.title = document.title.replace(/EspoCRM/g, 'EVERTEC CRM');
    }, 1000);
});