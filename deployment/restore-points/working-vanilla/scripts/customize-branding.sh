#!/bin/bash

# ===================================
# EspoCRM Branding Customization Script
# ===================================
# This script helps customize the branding of your EspoCRM installation

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}Evertec CRM - Branding Customization${NC}"
echo -e "${BLUE}====================================${NC}"
echo ""

# Configuration
COMPANY_NAME="${COMPANY_NAME:-Evertec}"
COMPANY_URL="${COMPANY_URL:-https://evertec.ao}"
FOOTER_TEXT="${FOOTER_TEXT:-}"
YEAR=$(date +%Y)

# Paths
CUSTOM_DIR="/var/www/html/custom/Espo/Custom"
TEMPLATE_DIR="${CUSTOM_DIR}/Resources/templates/site"
CLIENT_CUSTOM_DIR="/var/www/html/client/custom"

echo -e "${YELLOW}Configurando branding personalizado...${NC}"
echo -e "Empresa: ${COMPANY_NAME}"
echo -e "URL: ${COMPANY_URL}"
echo ""

# Create directories if they don't exist
echo -e "${YELLOW}Criando diretórios customizados...${NC}"
docker exec espocrm mkdir -p ${TEMPLATE_DIR}
docker exec espocrm mkdir -p ${CLIENT_CUSTOM_DIR}/css
docker exec espocrm mkdir -p ${CLIENT_CUSTOM_DIR}/img

# Create custom footer template
echo -e "${YELLOW}Customizando rodapé...${NC}"
docker exec espocrm bash -c "cat > ${TEMPLATE_DIR}/footer.tpl << 'EOF'
<p class=\"credit small\">&copy; ${YEAR}
<a
    href=\"${COMPANY_URL}\"
    title=\"${COMPANY_NAME}\"
    rel=\"noopener\" target=\"_blank\"
    tabindex=\"-1\"
>${COMPANY_NAME}</a></p>
EOF"

# Create custom CSS to hide or modify other branding elements
echo -e "${YELLOW}Aplicando estilos customizados...${NC}"
docker exec espocrm bash -c "cat > ${CLIENT_CUSTOM_DIR}/css/custom.css << 'EOF'
/* Custom Branding CSS */

/* Customizar cores do tema */
:root {
    --primary-color: #2c3e50;
    --secondary-color: #34495e;
    --success-color: #27ae60;
    --warning-color: #f39c12;
    --danger-color: #e74c3c;
}

/* Remover TODAS as referências ao EspoCRM */
.modal-dialog .about-text a[href*=\"espocrm\"] {
    display: none !important;
}

/* Esconder versão e links do EspoCRM */
.about-text {
    visibility: hidden;
    position: relative;
}

.about-text:after {
    content: \"Sistema CRM - Evertec\";
    visibility: visible;
    position: absolute;
    top: 0;
    left: 0;
}

/* Customizar footer */
.credit.small {
    text-align: center;
    opacity: 0.8;
}

.credit.small a {
    color: inherit;
    text-decoration: none;
}

.credit.small a:hover {
    text-decoration: underline;
}

/* Esconder completamente o rodapé original do EspoCRM no login */
.login-view .credit {
    display: none !important;
}

/* Adicionar rodapé customizado no login */
.login-view:after {
    content: \"© 2025 Evertec\";
    display: block;
    text-align: center;
    padding: 10px;
    font-size: 12px;
    opacity: 0.8;
}

/* Customizar logo area */
.logo-container {
    text-align: center;
    padding: 10px 0;
}

/* Adicionar seu próprio logo */
.navbar-logo img {
    max-height: 30px;
}
EOF"

# Create configuration for custom branding
echo -e "${YELLOW}Criando configuração de branding...${NC}"
docker exec espocrm bash -c "cat > ${CUSTOM_DIR}/Resources/metadata/app/client.json << 'EOF'
{
    \"scriptList\": [
        \"client/custom/js/custom.js\"
    ],
    \"developerModeScriptList\": [
        \"client/custom/js/custom.js\"
    ],
    \"cssList\": [
        \"client/custom/css/custom.css\"
    ]
}
EOF"

# Create custom JavaScript for additional branding
echo -e "${YELLOW}Adicionando JavaScript customizado...${NC}"
docker exec espocrm bash -c "mkdir -p ${CLIENT_CUSTOM_DIR}/js && cat > ${CLIENT_CUSTOM_DIR}/js/custom.js << 'EOF'
// Custom Branding JavaScript
Espo.define('custom:views/site/footer', 'views/site/footer', function (Dep) {
    return Dep.extend({
        template: 'custom:site/footer',
        
        data: function () {
            return {
                companyName: '${COMPANY_NAME}',
                companyUrl: '${COMPANY_URL}',
                year: new Date().getFullYear()
            };
        }
    });
});

// Remover completamente referências ao EspoCRM e substituir por Evertec
document.addEventListener('DOMContentLoaded', function() {
    // Função para substituir texto em todo o DOM
    function replaceEspoCRM() {
        // Mudar título da aba do navegador
        if (document.title.includes('EspoCRM')) {
            document.title = document.title.replace(/EspoCRM/g, '${COMPANY_NAME}');
        }
        
        // Substituir texto em todos os elementos
        var elements = document.getElementsByTagName('*');
        for (var i = 0; i < elements.length; i++) {
            var element = elements[i];
            for (var j = 0; j < element.childNodes.length; j++) {
                var node = element.childNodes[j];
                if (node.nodeType === 3) { // Text node
                    var text = node.nodeValue;
                    if (text && text.includes('EspoCRM')) {
                        node.nodeValue = text.replace(/EspoCRM/g, '${COMPANY_NAME}');
                    }
                }
            }
        }
        
        // Remover links para espocrm.com
        var links = document.querySelectorAll('a[href*=\"espocrm\"]');
        links.forEach(function(link) {
            link.href = '${COMPANY_URL}';
            link.textContent = '${COMPANY_NAME}';
        });
    }
    
    // Executar imediatamente
    replaceEspoCRM();
    
    // Observar mudanças no DOM
    var observer = new MutationObserver(function(mutations) {
        replaceEspoCRM();
    });
    
    observer.observe(document.body, {
        childList: true,
        subtree: true,
        characterData: true
    });
    
    // Observar mudanças no título
    var titleObserver = new MutationObserver(function(mutations) {
        if (document.title.includes('EspoCRM')) {
            document.title = document.title.replace(/EspoCRM/g, '${COMPANY_NAME}');
        }
    });
    
    if (document.querySelector('title')) {
        titleObserver.observe(document.querySelector('title'), {
            childList: true,
            characterData: true,
            subtree: true
        });
    }
});
EOF"

# Clear cache
echo -e "${YELLOW}Limpando cache...${NC}"
docker exec espocrm php clear_cache.php 2>/dev/null || true

# Rebuild
echo -e "${YELLOW}Reconstruindo aplicação...${NC}"
docker exec espocrm php rebuild.php 2>/dev/null || true

echo ""
echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}✅ Branding customizado com sucesso!${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""
echo -e "${GREEN}Personalizações aplicadas:${NC}"
echo -e "  • Rodapé: ${COMPANY_NAME}"
echo -e "  • CSS customizado aplicado"
echo -e "  • JavaScript de branding ativo"
echo ""
echo -e "${YELLOW}Nota: Pode ser necessário limpar o cache do navegador${NC}"
echo -e "${YELLOW}para ver todas as mudanças.${NC}"
echo ""
echo -e "${BLUE}Para adicionar um logo customizado:${NC}"
echo -e "1. Faça upload do logo para: client/custom/img/logo.png"
echo -e "2. Configure em Administração > Interface do Usuário"
echo ""

exit 0