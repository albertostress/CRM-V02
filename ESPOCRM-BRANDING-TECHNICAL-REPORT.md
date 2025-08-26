# 📊 RELATÓRIO TÉCNICO: BRANDING COMPLETO DO ESPOCRM

**Versão:** EspoCRM 9.x  
**Data:** 26/08/2025  
**Objetivo:** Remover todas as referências "EspoCRM" e substituir por "EVERTEC CRM"

---

## 📋 TABELA DE ELEMENTOS DE BRANDING

| **Elemento** | **Ficheiro(s) Core** | **Path Completo** | **Override Possível** | **Path do Override** | **Notas** |
|-------------|---------------------|------------------|---------------------|---------------------|----------|
| **Footer Principal** | `footer.tpl` | `/client/res/templates/site/footer.tpl` | ✅ SIM | `/client/custom/res/templates/site/footer.tpl` | Template Handlebars |
| **Footer View JS** | `footer.js` | `/client/src/views/site/footer.js` | ✅ SIM | `/client/custom/src/views/site/footer.js` | Define view do footer |
| **Main HTML** | `main.html` | `/html/main.html` | ❌ NÃO | N/A | Core file - edição direta |
| **Página About - Conteúdo** | `about.md` | `/application/Espo/Resources/texts/about.md` | ✅ SIM | `/custom/Espo/Custom/Resources/texts/about.md` | Markdown com texto About |
| **About API** | `GetAbout.php` | `/application/Espo/Tools/App/Api/GetAbout.php` | ❌ NÃO | N/A | API endpoint |
| **About View JS** | `about.js` | `/client/src/views/about.js` | ✅ SIM | `/client/custom/src/views/about.js` | View JavaScript |
| **About Controller** | `about.js` | `/client/src/controllers/about.js` | ✅ SIM | `/client/custom/src/controllers/about.js` | Controller JavaScript |
| **About Template** | `about.tpl` | `/client/res/templates/about.tpl` | ✅ SIM | `/client/custom/res/templates/about.tpl` | Template HTML |
| **Application Name** | `Settings.json` | `/application/Espo/Resources/i18n/{lang}/Settings.json` | ✅ SIM | `/custom/Espo/Custom/Resources/i18n/{lang}/Settings.json` | Traduções |
| **Global Labels** | `Global.json` | `/application/Espo/Resources/i18n/{lang}/Global.json` | ✅ SIM | `/custom/Espo/Custom/Resources/i18n/{lang}/Global.json` | Labels globais |
| **Email Templates** | `*.tpl` | `/application/Espo/Resources/templates/**/*.tpl` | ✅ SIM | `/custom/Espo/Custom/Resources/templates/**/*.tpl` | Templates de email |
| **Login Page** | `login.tpl` | `/client/res/templates/login.tpl` | ✅ SIM | `/client/custom/res/templates/login.tpl` | Página de login |
| **CSS Global** | `espo.css` | `/client/css/espo.css` | ✅ SIM | `/client/custom/res/css/custom.css` | Via metadata |
| **JavaScript Global** | N/A | N/A | ✅ SIM | `/client/custom/lib/*.js` | Via metadata |
| **Metadata Config** | `config.json` | `/application/Espo/Resources/metadata/app/config.json` | ✅ SIM | `/custom/Espo/Custom/Resources/metadata/app/config.json` | Configurações app |
| **Client Metadata** | `client.json` | `/application/Espo/Resources/metadata/app/client.json` | ✅ SIM | `/custom/Espo/Custom/Resources/metadata/app/client.json` | Assets cliente |

---

## 🔄 PRIORIDADE DE CARREGAMENTO

### **Hierarquia de Override (do maior para menor prioridade):**

```
1. custom/Espo/Custom/           [MÁXIMA PRIORIDADE]
2. custom/Espo/Modules/*/
3. application/Espo/Modules/*/
4. application/Espo/              [MÍNIMA PRIORIDADE]
```

### **Exemplos Práticos:**

1. **Metadata Override:**
   - Core: `/application/Espo/Resources/metadata/app/config.json`
   - Override: `/custom/Espo/Custom/Resources/metadata/app/config.json`
   - ✅ O ficheiro em `custom/` sobrepõe completamente o core

2. **Template Override:**
   - Core: `/client/res/templates/site/footer.tpl`
   - Override: `/client/custom/res/templates/site/footer.tpl`
   - ✅ Template customizado tem prioridade

3. **View JavaScript Override:**
   - Core: `/client/src/views/site/footer.js`
   - Override: `/client/custom/src/views/site/footer.js`
   - ✅ View customizada substitui a original

4. **Traduções Override:**
   - Core: `/application/Espo/Resources/i18n/pt_PT/Global.json`
   - Override: `/custom/Espo/Custom/Resources/i18n/pt_PT/Global.json`
   - ✅ Traduções customizadas têm prioridade

---

## 📁 ESTRUTURA DETALHADA DE FICHEIROS

### **1. FOOTER DO SISTEMA**

#### **Ficheiro Core:**
```
/client/res/templates/site/footer.tpl
```
```html
<p class="credit small">&copy; 2014-2025
<a href="https://www.espocrm.com" title="Powered by EspoCRM">EspoCRM</a></p>
```

#### **Override Recomendado:**
```
/client/custom/res/templates/site/footer.tpl
```
```html
<p class="credit small">© 2025 EVERTEC CRM — Todos os direitos reservados</p>
```

### **2. PÁGINA ABOUT**

#### **Conteúdo (Markdown):**
- Core: `/application/Espo/Resources/texts/about.md`
- Override: `/custom/Espo/Custom/Resources/texts/about.md`

#### **API Endpoint:**
```php
// /application/Espo/Tools/App/Api/GetAbout.php
$text = $this->fileReader->read('texts/about.md', FileReader\Params::create());
```
O sistema procura primeiro em `custom/`, depois em `application/`

### **3. NOME DA APLICAÇÃO**

#### **Metadata Config:**
```json
// /custom/Espo/Custom/Resources/metadata/app/config.json
{
    "applicationName": "EVERTEC CRM",
    "companyName": "Evertec Corporation"
}
```

### **4. ASSETS (CSS/JS)**

#### **Registrar via Metadata:**
```json
// /custom/Espo/Custom/Resources/metadata/app/client.json
{
    "cssList": [
        "__APPEND__",
        "client/custom/res/css/custom.css"
    ],
    "scriptList": [
        "__APPEND__",
        "client/custom/lib/custom-footer.js",
        "client/custom/lib/custom-branding.js"
    ]
}
```

---

## ⚠️ AVISOS LEGAIS IMPORTANTES

### **Licença AGPL v3 - Section 7(b):**
```
"In accordance with Section 7(b) of the GNU Affero General Public License version 3,
these Appropriate Legal Notices must retain the display of the 'EspoCRM' word."
```

**⚠️ ATENÇÃO:** Muitos ficheiros PHP/JS contêm este aviso no header. Tecnicamente, a remoção completa de "EspoCRM" pode violar a licença AGPL.

---

## ✅ RECOMENDAÇÕES

### **1. ESTRATÉGIA MAIS SEGURA (Upgrade-Safe):**

```bash
custom/
├── Espo/
│   └── Custom/
│       ├── Resources/
│       │   ├── metadata/
│       │   │   └── app/
│       │   │       ├── config.json      # Nome da aplicação
│       │   │       └── client.json      # CSS/JS customizado
│       │   ├── i18n/
│       │   │   ├── en_US/
│       │   │   │   └── Global.json      # Labels inglês
│       │   │   └── pt_PT/
│       │   │       └── Global.json      # Labels português
│       │   ├── templates/               # Templates email
│       │   └── texts/
│       │       └── about.md            # Conteúdo About
│       └── Views/
│           └── Site/
│               └── Footer.php           # View PHP (opcional)
└── client/
    └── custom/
        ├── src/
        │   └── views/
        │       ├── site/
        │       │   └── footer.js       # Override view JS
        │       └── about.js             # Override About view
        ├── res/
        │   ├── templates/
        │   │   ├── site/
        │   │   │   └── footer.tpl      # Template footer
        │   │   ├── about.tpl            # Template About
        │   │   └── login.tpl            # Template login
        │   └── css/
        │       └── custom.css           # CSS customizado
        └── lib/
            ├── custom-footer.js         # JS footer
            └── custom-branding.js       # JS branding global
```

### **2. FICHEIROS CRÍTICOS A MONITORIZAR:**

| **Ficheiro** | **Motivo** |
|-------------|-----------|
| `/html/main.html` | HTML principal - sem override |
| `/application/Espo/Core/Application.php` | Bootstrap da aplicação |
| `/application/Espo/Tools/App/Api/GetAbout.php` | API About |
| `/client/src/app.js` | JavaScript principal |
| `/install/core/tpl/finish.tpl` | Template instalação |

### **3. COMANDOS APÓS ALTERAÇÕES:**

```bash
# Limpar cache
docker exec [container] rm -rf /var/www/html/data/cache/*

# Rebuild
docker exec [container] php /var/www/html/rebuild.php

# Clear cache PHP
docker exec [container] php /var/www/html/clear_cache.php

# Restart container
docker restart [container]
```

### **4. ESTRATÉGIA DE IMPLEMENTAÇÃO:**

#### **A. Override Completo (RECOMENDADO):**
- ✅ Use apenas diretório `custom/`
- ✅ Sobrevive a upgrades
- ✅ Fácil manutenção
- ⚠️ Alguns elementos não têm override (ex: main.html)

#### **B. Core Edit (NÃO RECOMENDADO):**
- ❌ Editar ficheiros core diretamente
- ❌ Perdido em upgrades
- ❌ Difícil manutenção
- ✅ Controle total

#### **C. Híbrido (PRAGMÁTICO):**
- ✅ Override onde possível
- ⚠️ Core edit apenas onde necessário (main.html)
- 📝 Documentar todas as alterações core
- 🔄 Script de reaplicação pós-upgrade

---

## 🔧 SCRIPT DE APLICAÇÃO COMPLETA

```bash
#!/bin/bash
# apply-branding.sh

echo "=== EVERTEC CRM Branding ==="

# 1. Criar estrutura
mkdir -p custom/Espo/Custom/Resources/{metadata/app,i18n/en_US,i18n/pt_PT,texts,templates}
mkdir -p client/custom/{src/views/site,res/templates/site,res/css,lib}

# 2. Aplicar overrides
echo "Aplicando overrides..."

# 3. Editar core (se necessário)
if [ -f "html/main.html" ]; then
    cp html/main.html html/main.html.bak
    sed -i 's/{{applicationName}}/EVERTEC CRM/g' html/main.html
    echo "✅ main.html editado"
fi

# 4. Limpar cache
rm -rf data/cache/*
php rebuild.php
php clear_cache.php

echo "✅ Branding aplicado!"
```

---

## 📊 RESUMO EXECUTIVO

### **Para implementar branding EVERTEC CRM:**

1. **80% via Override** (diretório `custom/`)
   - Templates, views, traduções, CSS/JS

2. **20% Core Edit** (ficheiros sem override)
   - `/html/main.html` (título e meta)
   - Headers com avisos legais (opcional)

3. **Manutenção:**
   - Documentar todas as alterações core
   - Criar script de reaplicação
   - Testar após cada upgrade

### **Tempo estimado:** 2-4 horas
### **Complexidade:** Média
### **Risco de upgrade:** Baixo (com overrides)

---

**© 2025 - Relatório Técnico EspoCRM Branding**