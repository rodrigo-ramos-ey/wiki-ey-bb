Write-Host "=== CORRECAO DEFINITIVA: REMOCAO CLOUD & DEVOPS ==="
$ErrorActionPreference = "Stop"

# =====================================================
# 1. REMOVER PASTAS INVALIDAS
# =====================================================
$pastasInvalidas = @(
  "docs/comunidades/cloud",
  "docs/comunidades/clouddevios",
  "site/comunidades/cloud",
  "site/comunidades/clouddevios"
)

foreach ($p in $pastasInvalidas) {
  if (Test-Path $p) {
    Write-Host "Removendo $p"
    Remove-Item $p -Recurse -Force
  }
}

# =====================================================
# 2. LIMPAR MKDOCS.YML (NAV)
# =====================================================
$mkdocs = @"
site_name: Wiki EY-BB
docs_dir: docs
site_dir: site

theme:
  name: material

nav:
  - Home: index.md
  - Comunidades: comunidades/index.md
  - Onboarding: onboarding/index.md
  - OF: of/index.md
  - Ambiente BB: ambiente/index.md

extra_css:
  - stylesheets/social.css
"@

Set-Content "mkdocs.yml" $mkdocs -Encoding UTF8

# =====================================================
# 3. LIMPAR SITE BUILD ANTIGO
# =====================================================
if (Test-Path "site") {
  Write-Host "Limpando site/"
  Remove-Item "site" -Recurse -Force
}

# =====================================================
# 4. REBUILD LIMPO
# =====================================================
Write-Host "Executando mkdocs build --clean"
mkdocs build --clean

# =====================================================
# 5. COMMIT
# =====================================================
git add .
git commit -m "fix: remove Cloud & DevOps e corrige estrutura de comunidades"

Write-Host "=== CORRECAO FINALIZADA ==="
Write-Host "Agora execute: git push"
