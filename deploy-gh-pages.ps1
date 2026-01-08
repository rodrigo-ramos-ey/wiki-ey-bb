Write-Host "=== DEPLOY WIKI EY-BB (MkDocs + GitHub Pages) ==="
$ErrorActionPreference = "Stop"

# =====================================================
# 1. GARANTIR BRANCH PRINCIPAL
# =====================================================
$branch = git branch --show-current
if ($branch -ne "main") {
    Write-Host "Trocando para branch main"
    git checkout main
}

# =====================================================
# 2. ADD + COMMIT AUTOMATICO
# =====================================================
Write-Host "Adicionando arquivos ao git"
git add .

$hasChanges = git status --porcelain
if ($hasChanges) {
    Write-Host "Commitando alteracoes"
    git commit -m "chore: update wiki content and redeploy pages"
} else {
    Write-Host "Nenhuma alteracao para commit"
}

# =====================================================
# 3. PUSH PARA ORIGEM
# =====================================================
Write-Host "Enviando alteracoes para o repositorio remoto"
git push origin main

# =====================================================
# 4. LIMPAR BUILD LOCAL
# =====================================================
if (Test-Path "site") {
    Write-Host "Removendo pasta site/"
    Remove-Item site -Recurse -Force
}

# =====================================================
# 5. DEPLOY CORRETO COM MKDOCS
# =====================================================
Write-Host "Publicando no GitHub Pages via MkDocs"
mkdocs gh-deploy --clean --force

Write-Host "=== DEPLOY FINALIZADO COM SUCESSO ==="
Write-Host "Aguarde 1-3 minutos e acesse:"
Write-Host "https://rodrigo-ramos-ey.github.io/wiki-ey-bb/"
