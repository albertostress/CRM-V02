# EVERTEC CRM - Custom Docker Image
FROM espocrm/espocrm:latest

# Copiar ficheiros de branding
COPY client/res/templates/site/footer.tpl /var/www/html/client/res/templates/site/footer.tpl
COPY client/res/templates/login.tpl /var/www/html/client/res/templates/login.tpl
COPY application/Espo/Resources/texts/about.md /var/www/html/application/Espo/Resources/texts/about.md
COPY install/core/tpl/footer.tpl /var/www/html/install/core/tpl/footer.tpl
COPY install/core/tpl/finish.tpl /var/www/html/install/core/tpl/finish.tpl
COPY html/main.html /var/www/html/html/main.html

# Copiar diretórios customizados
COPY client/custom/ /var/www/html/client/custom/
COPY custom/ /var/www/html/custom/

# Garantir permissões corretas
RUN chown -R www-data:www-data /var/www/html

# Limpar cache (ignorar se não existir)
RUN rm -rf /var/www/html/data/cache/* || true

LABEL maintainer="EVERTEC CRM"
LABEL version="1.0"
LABEL description="EspoCRM with EVERTEC branding"
