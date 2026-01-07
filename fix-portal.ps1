Write-Host "CORRECAO FINAL DA ESTRUTURA DO PORTAL TECH"

if (!(Test-Path "mkdocs.yml")) {
    Write-Error "Execute este script na raiz do projeto"
    exit 1
}

# ============================
# 1. GARANTE ESTRUTURA FINAL
# ============================
Write-Host "Garantindo estrutura correta..."

New-Item -ItemType Directory -Force -Path docs\assets\stylesheets | Out-Null
New-Item -ItemType Directory -Force -Path docs\portal\comunidades | Out-Null
New-Item -ItemType Directory -Force -Path docs\portal\governanca | Out-Null
New-Item -ItemType Directory -Force -Path docs\portal\sobre | Out-Null
New-Item -ItemType Directory -Force -Path docs\comunidades | Out-Null

# ============================
# 2. MOVE COMUNIDADES DUPLICADAS
# ============================
Write-Host "Corrigindo duplicacao de comunidades..."

$origem = "docs\comunidades\comunidades"

if (Test-Path $origem) {
    Get-ChildItem $origem -Directory | ForEach-Object {
        $destino = "docs\comunidades\$($_.Name)"
        if (!(Test-Path $destino)) {
            Move-Item $_.FullName $destino
        }
    }
    Remove-Item -Recurse -Force $origem
}

# ============================
# 3. REMOVE PASTAS VAZIAS
# ============================
Write-Host "Removendo pastas vazias..."

Get-ChildItem docs\comunidades -Directory | ForEach-Object {
    if ((Get-ChildItem $_.FullName -Recurse | Measure-Object).Count -eq 0) {
        Remove-Item -Recurse -Force $_.FullName
    }
}

# ============================
# 4. GARANTE INDEX NAS COMUNIDADES
# ============================
Write-Host "Validando index.md..."

$comunidades = @("cloud","dados","engenharia","seguranca")

foreach ($c in $comunidades) {
    $path = "docs\comunidades\$c\index.md"
    if (!(Test-Path $path)) {
        New-Item -ItemType File -Path $path | Out-Null
    }
}

# ============================
# 5. LIMPA BUILD E DEPLOY
# ============================
Write-Host "Limpando build e publicando..."

if (Test-Path "site") {
    Remove-Item -Recurse -Force site
}

mkdocs build --clean

git add .
git commit -m "Limpeza definitiva da estrutura de comunidades" --allow-empty
git push origin main

mkdocs gh-deploy --clean

Write-Host "ESTRUTURA FINAL CORRIGIDA COM SUCESSO"
Write-Host "URL: https://rodrigo-ramos-ey.github.io/wiki-ey-bb/"
