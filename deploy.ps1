Write-Host "=== DEPLOY WIKI EY-BB (RESET + PUBLICACAO LIMPA) ==="
$ErrorActionPreference = "Stop"

# =====================================================
# 1. GARANTIR QUE NAO ESTA NA gh-pages
# =====================================================
$branch = git branch --show-current
if ($branch -eq "gh-pages") {
    Write-Error "Nao execute deploy a partir da branch gh-pages. Use main."
}

# =====================================================
# 2. PUSH DA VERSAO ATUAL (MAIN)
# =====================================================
Write-Host "Enviando commits para o repositorio remoto"
git push origin $branch

# =====================================================
# 3. LIMPAR BUILD LOCAL ANTIGO
# =====================================================
if (Test-Path "site") {
    Write-Host "Removendo build local anterior (site/)"
    Remove-Item site -Recurse -Force
}

# =====================================================
# 4. DEPLOY LIMPO (REMOVE DEPLOY ANTERIOR + PUBLICA NOVO)
# =====================================================
Write-Host "Publicando nova versao no GitHub Pages (deploy limpo)"
mkdocs gh-deploy --clean --force

Write-Host "=== DEPLOY FINALIZADO COM SUCESSO ==="
Write-Host "URL:"
Write-Host "https://rodrigo-ramos-ey.github.io/wiki-ey-bb/"
