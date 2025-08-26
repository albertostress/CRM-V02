# 🚀 EVERTEC CRM - Dokploy Branding Setup (Volume-Based)

## ✅ Configuração Atualizada

O `docker-compose.yml` foi configurado para montar todos os ficheiros de branding diretamente do repositório Git para o container, **sem necessidade de criar imagem customizada**.

## 📂 Estrutura de Ficheiros no Repositório

```
espocrm/
├── client/
│   ├── custom/                      # Frontend customizations
│   │   ├── lib/
│   │   │   ├── custom.css          # CSS personalizado
│   │   │   └── custom-footer.js    # JS para substituir footer dinamicamente
│   │   └── autoload.json           # Configuração de autoload
│   └── res/
│       └── templates/
│           ├── site/
│           │   └── footer.tpl       # Template do footer principal
│           └── login.tpl            # Template da página de login
│
├── application/
│   └── Espo/
│       └── Resources/
│           └── texts/
│               └── about.md         # Conteúdo da página About
│
├── install/
│   └── core/
│       └── tpl/
│           ├── footer.tpl           # Footer do instalador
│           └── finish.tpl           # Página final do instalador
│
├── html/
│   └── main.html                    # HTML principal (title, meta tags)
│
├── custom/
│   └── Espo/
│       └── Custom/
│           └── Resources/
│               └── metadata/        # Metadata customizations
│                   └── clientDefs/  # Client definitions
│                       └── App.json # App-level customizations
│
└── docker-compose.yml               # ✅ Configurado com volumes
```

## 🔄 Como Funciona no Dokploy

1. **Git Push** → Dokploy faz pull automaticamente
2. **Volumes Montados** → Ficheiros do repo sobrescrevem os do container
3. **Read-Only (`:ro`)** → Container não pode alterar os ficheiros montados
4. **Branding Aplicado** → Automaticamente visível após restart

## 🛠️ Passos Pós-Deploy

### 1. Verificar volumes montados:
```bash
docker exec espocrm ls -la /var/www/html/client/custom/lib/
docker exec espocrm cat /var/www/html/client/res/templates/site/footer.tpl
docker exec espocrm cat /var/www/html/application/Espo/Resources/texts/about.md
```

### 2. Limpar cache e rebuild:
```bash
docker exec espocrm rm -rf /var/www/html/data/cache/*
docker exec espocrm php /var/www/html/rebuild.php
```

### 3. Restart containers (se necessário):
```bash
docker restart espocrm espocrm-daemon espocrm-websocket
```

## 🌐 Validação no Browser

1. **Limpar cache do browser:**
   - Windows/Linux: `Ctrl + Shift + R`
   - Mac: `Cmd + Shift + R`
   - Ou abrir em modo incógnito/privado

2. **Verificar branding:**
   - Footer: "© 2025 EVERTEC CRM"
   - Login page: Footer customizado
   - About page: Conteúdo EVERTEC
   - Title: "EVERTEC CRM"

## 📝 Boas Práticas

### ✅ DO:
- Manter estrutura de diretórios conforme acima
- Usar `:ro` nos volumes para proteção
- Sempre limpar cache após mudanças
- Commitar todas as mudanças no Git antes de deploy

### ❌ DON'T:
- Editar ficheiros diretamente no container
- Usar volumes sem `:ro` para ficheiros de branding
- Esquecer de limpar cache do browser
- Misturar ficheiros de branding com dados persistentes

## 🔧 Troubleshooting

### Branding não aparece:
```bash
# 1. Verificar se volumes estão montados
docker inspect espocrm | grep -A20 Mounts

# 2. Forçar rebuild
docker exec espocrm php /var/www/html/rebuild.php

# 3. Verificar logs
docker logs espocrm --tail 50
```

### Mudanças não refletem:
```bash
# 1. Pull mais recente do Git no Dokploy
# 2. Recreate containers
docker-compose down && docker-compose up -d

# 3. Limpar tudo
docker exec espocrm rm -rf /var/www/html/data/cache/*
docker exec espocrm rm -rf /var/www/html/client/lib/transpiled/*
```

## 🎯 Resultado Final

Com esta configuração:
- ✅ Continua a usar `espocrm/espocrm:latest`
- ✅ Branding aplicado automaticamente via volumes
- ✅ Git push → Dokploy pull → Branding atualizado
- ✅ Sem necessidade de build customizado
- ✅ Fácil manutenção e rollback