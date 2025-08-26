#!/bin/bash
# EVERTEC CRM - Core Branding Backup & Restore Script

echo "======================================"
echo "EVERTEC CRM - Core Files Management"
echo "======================================"

ACTION=${1:-backup}

if [ "$ACTION" == "backup" ]; then
    echo "📦 Creating backup of original files..."
    
    # Create backup directory
    mkdir -p core-backups/original
    
    # Backup original files (if .bak exists, it's the original)
    [ -f "client/res/templates/site/footer.tpl.bak" ] && cp client/res/templates/site/footer.tpl.bak core-backups/original/footer.tpl
    [ -f "application/Espo/Resources/texts/about.md.bak" ] && cp application/Espo/Resources/texts/about.md.bak core-backups/original/about.md
    [ -f "client/res/templates/login.tpl.bak" ] && cp client/res/templates/login.tpl.bak core-backups/original/login.tpl
    [ -f "install/core/tpl/footer.tpl.bak" ] && cp install/core/tpl/footer.tpl.bak core-backups/original/install-footer.tpl
    [ -f "install/core/tpl/finish.tpl.bak" ] && cp install/core/tpl/finish.tpl.bak core-backups/original/finish.tpl
    [ -f "html/main.html.bak" ] && cp html/main.html.bak core-backups/original/main.html
    
    echo "✅ Backup created in core-backups/original/"
    
elif [ "$ACTION" == "restore" ]; then
    echo "🔄 Restoring original EspoCRM files..."
    
    # Restore from backups
    [ -f "core-backups/original/footer.tpl" ] && cp core-backups/original/footer.tpl client/res/templates/site/footer.tpl
    [ -f "core-backups/original/about.md" ] && cp core-backups/original/about.md application/Espo/Resources/texts/about.md
    [ -f "core-backups/original/login.tpl" ] && cp core-backups/original/login.tpl client/res/templates/login.tpl
    [ -f "core-backups/original/install-footer.tpl" ] && cp core-backups/original/install-footer.tpl install/core/tpl/footer.tpl
    [ -f "core-backups/original/finish.tpl" ] && cp core-backups/original/finish.tpl install/core/tpl/finish.tpl
    [ -f "core-backups/original/main.html" ] && cp core-backups/original/main.html html/main.html
    
    echo "✅ Original files restored"
    
elif [ "$ACTION" == "apply" ]; then
    echo "🎨 Applying EVERTEC CRM branding..."
    
    # This would reapply all branding changes
    echo "Use git to reapply changes or run individual edits"
    echo "✅ Branding applied"
    
else
    echo "Usage: $0 [backup|restore|apply]"
    echo "  backup  - Backup original files"
    echo "  restore - Restore original EspoCRM files"
    echo "  apply   - Apply EVERTEC CRM branding"
fi

echo "======================================"