Write-Host "INICIANDO CORRECAO TOTAL DO PORTAL TECH"

# Verifica raiz
if (!(Test-Path "mkdocs.yml")) {
    Write-Error "mkdocs.yml nao encontrado. Execute na raiz do projeto."
    exit 1
}

# ============================
# 1. CRIA ESTRUTURA CORRETA
# ============================
Write-Host "Criando estrutura padrao..."

New-Item -ItemType Directory -Force -Path docs\assets\stylesheets | Out-Null
New-Item -ItemType Directory -Force -Path docs\portal\sobre | Out-Null
New-Item -ItemType Directory -Force -Path docs\portal\governanca | Out-Null
New-Item -ItemType Directory -Force -Path docs\portal\comunidades | Out-Null
New-Item -ItemType Directory -Force -Path docs\comunidades\engenharia | Out-Null
New-Item -ItemType Directory -Force -Path docs\comunidades\dados | Out-Null
New-Item -ItemType Directory -Force -Path docs\comunidades\cloud | Out-Null
New-Item -ItemType Directory -Force -Path docs\comunidades\seguranca | Out-Null

# ============================
# 2. MOVE CSS PARA LOCAL CORRETO
# ============================
Write-Host "Movendo CSS..."

if (Test-Path "docs\comunidades\assets\stylesheets\ey-tech.css") {
    Move-Item -Force `
        docs\comunidades\assets\stylesheets\ey-tech.css `
        docs\assets\stylesheets\ey-tech.css
}

if (Test-Path "docs\comunidades\assets") {
    Remove-Item -Recurse -Force docs\comunidades\assets
}

# ============================
# 3. MOVE PORTAL PARA RAIZ
# ============================
Write-Host "Corrigindo portal..."

if (Test-Path "docs\comunidades\portal") {
    Move-Item -Force docs\comunidades\portal docs\portal_temp
}

if (Test-Path "docs\portal_temp\sobre.md") {
    Move-Item -Force docs\portal_temp\sobre.md docs\portal\sobre\index.md
}
if (Test-Path "docs\portal_temp\governanca.md") {
    Move-Item -Force docs\portal_temp\governanca.md docs\portal\governanca\index.md
}
if (Test-Path "docs\portal_temp\comunidades.md") {
    Move-Item -Force docs\portal_temp\comunidades.md docs\portal\comunidades\index.md
}

if (Test-Path "docs\portal_temp") {
    Remove-Item -Recurse -Force docs\portal_temp
}

# ============================
# 4. REMOVE ARQUIVOS SOLTOS
# ============================
Write-Host "Removendo arquivos soltos..."

$arquivosSoltos = @(
    "arquitetura.md",
    "compliance.md",
    "governanca.md",
    "desenvolvimento.md",
    "seguranca.md"
)

foreach ($arquivo in $arquivosSoltos) {
    $path = "docs\comunidades\$arquivo"
    if (Test-Path $path) {
        Remove-Item -Force $path
    }
}

# ============================
# 5. LIMPA BUILD
# ============================
Write-Host "Limpando build..."

if (Test-Path "site") {
    Remove-Item -Recurse -Force site
}

mkdocs build --clean

# ============================
# 6. COMMIT E DEPLOY
# ============================
Write-Host "Commitando e publicando..."

git add .
git commit -m "Correcao estrutural total do Portal Tech" --allow-empty
git push origin main

mkdocs gh-deploy --clean

Write-Host "CORRECAO FINALIZADA COM SUCESSO"
Write-Host "Acesse: https://rodrigo-ramos-ey.github.io/wiki-ey-bb/"
