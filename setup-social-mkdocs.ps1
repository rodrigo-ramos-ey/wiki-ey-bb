Write-Host "=== CORRECAO SEGURA MKDOCS - WIKI EY-BB ==="
$ErrorActionPreference = "Stop"

# =====================================================
# 1. GARANTIR HOME (docs/index.md)
# =====================================================
if (!(Test-Path "docs/index.md")) {
    Write-Host "Criando docs/index.md"
@"
# Wiki EY-BB

Bem-vindo a Wiki EY-BB.

Utilize o menu superior para navegar pelas comunidades, onboarding,
estrutura OF e ambiente BB.
"@ | Set-Content "docs/index.md" -Encoding UTF8
}

# =====================================================
# 2. REMOVER SOMENTE CLOUD / DEVOPS (SE EXISTIR)
# =====================================================
$invalidas = @(
  "docs/comunidades/cloud",
  "docs/comunidades/cloud-devops",
  "docs/comunidades/devops"
)

foreach ($p in $invalidas) {
  if (Test-Path $p) {
    Write-Host "Removendo $p"
    Remove-Item $p -Recurse -Force
  }
}

# =====================================================
# 3. CORRIGIR mkdocs.yml BASEADO NO QUE EXISTE
# =====================================================
$nav = @(
  "site_name: Wiki EY-BB",
  "docs_dir: docs",
  "site_dir: site",
  "",
  "theme:",
  "  name: material",
  "",
  "nav:",
  "  - Home: index.md",
  "  - Comunidades: comunidades/index.md"
)

if (Test-Path "docs/onboarding/index.md") {
  $nav += "  - Onboarding: onboarding/index.md"
}

if (Test-Path "docs/of/index.md") {
  $nav += "  - OF: of/index.md"
}

if (Test-Path "docs/ambiente/index.md") {
  $nav += "  - Ambiente BB: ambiente/index.md"
}

$nav += @(
  "",
  "extra_css:",
  "  - stylesheets/social.css"
)

$nav | Set-Content "mkdocs.yml" -Encoding UTF8

# =====================================================
# 4. LIMPAR BUILD ANTIGO E REBUILD
# =====================================================
if (Test-Path "site") {
    Remove-Item "site" -Recurse -Force
}

mkdocs build --clean

Write-Host "=== CORRECAO FINALIZADA ==="
Write-Host "Se estiver OK, execute: mkdocs gh-deploy --clean"
