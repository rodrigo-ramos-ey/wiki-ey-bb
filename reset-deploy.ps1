Write-Host "RESET COMPLETO DO PORTAL TECH - EY + BB"

# 1. Verifica se esta na raiz correta
if (!(Test-Path "mkdocs.yml")) {
    Write-Error "mkdocs.yml nao encontrado. Execute o script na raiz do projeto."
    exit 1
}

# 2. Limpa build local
Write-Host "Limpando build local..."
mkdocs build --clean

# 3. Remove pasta site se existir
if (Test-Path "site") {
    Remove-Item -Recurse -Force site
    Write-Host "Pasta site removida"
}

# 4. Valida configuracao do MkDocs
Write-Host "Validando configuracao do MkDocs..."
mkdocs config

# 5. Commit automatico
Write-Host "Commitando alteracoes..."
git add .
git commit -m "Reset tecnico MkDocs e correcoes estruturais" --allow-empty
git push origin main

# 6. Deploy limpo no GitHub Pages
Write-Host "Realizando deploy limpo no GitHub Pages..."
mkdocs gh-deploy --clean

Write-Host "DEPLOY FINALIZADO"
Write-Host "URL: https://rodrigo-ramos-ey.github.io/wiki-ey-bb/"
