Write-Host "Iniciando correcao MkDocs..."

# 1. Remover site/
if (Test-Path "site") {
    Write-Host "Removendo site/"
    Remove-Item -Recurse -Force site
}

# 2. Garantir .gitignore
if (!(Test-Path ".gitignore")) {
    New-Item ".gitignore" -ItemType File | Out-Null
}

$gitignore = Get-Content ".gitignore" -ErrorAction SilentlyContinue
if ($gitignore -notcontains "site/") {
    Add-Content ".gitignore" "site/"
}

# 3. Garantir docs/comunidades
if (!(Test-Path "docs/comunidades")) {
    New-Item "docs/comunidades" -ItemType Directory -Force | Out-Null
}

# 4. Ler JSON
$jsonPath = "data/comunidades.json"
if (!(Test-Path $jsonPath)) {
    Write-Error "Arquivo data/comunidades.json nao encontrado"
    exit 1
}

$comunidades = Get-Content $jsonPath -Raw | ConvertFrom-Json

# 5. Gerar Markdown
$md = @()
$md += "# Comunidades"
$md += ""
$md += "Lista oficial de comunidades tecnicas."
$md += ""

$grupos = $comunidades | Group-Object area

foreach ($grupo in $grupos) {
    $md += "## " + $grupo.Name
    $md += ""

    foreach ($c in $grupo.Group) {
        $linha = "- **" + $c.nome + "** - " + $c.lider
        $md += $linha
    }

    $md += ""
}

Set-Content -Path "docs/comunidades/index.md" -Value $md -Encoding UTF8

# 6. Build MkDocs
Write-Host "Executando mkdocs build --clean"
mkdocs build --clean

# 7. Commit
git add .
git commit -m "Corrige MkDocs e publica comunidades"

Write-Host "Finalizado. Execute git push."
