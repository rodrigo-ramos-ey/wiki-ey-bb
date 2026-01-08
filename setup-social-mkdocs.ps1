Write-Host "=== Setup Social MkDocs (com rollback) ==="

# ======================================================
# CONFIGURACAO
# ======================================================

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$rollbackDir = "_rollback/$timestamp"
$docsDir = "docs"

# ======================================================
# ROLLBACK - BACKUP COMPLETO
# ======================================================

Write-Host "Criando backup para rollback..."

New-Item $rollbackDir -ItemType Directory -Force | Out-Null
Copy-Item $docsDir $rollbackDir -Recurse -Force
Copy-Item "mkdocs.yml" $rollbackDir -Force

Write-Host "Backup criado em $rollbackDir"

# ======================================================
# COMMIT DE SEGURANCA
# ======================================================

git add .
git commit -m "backup: estado antes do setup social ($timestamp)"

# ======================================================
# CRIAR ESTRUTURA PESSOAS
# ======================================================

$pessoasDir = "docs/pessoas"
New-Item $pessoasDir -ItemType Directory -Force | Out-Null

# ======================================================
# CSS SOCIAL
# ======================================================

$cssDir = "docs/stylesheets"
New-Item $cssDir -ItemType Directory -Force | Out-Null

$cssFile = "$cssDir/social.css"

$css = @(
".profile-card { max-width:700px; margin:auto; padding:24px; background:#1e1f26; border-radius:12px; }",
".profile-avatar { width:160px; height:160px; border-radius:50%; object-fit:cover; display:block; margin:auto; border:4px solid #f7c600; }",
".profile-name { text-align:center; font-size:2rem; margin-top:16px; }",
".profile-section { margin-top:24px; }",
".profile-section h2 { color:#f7c600; font-size:1.2rem; }",
".humor-green { color:#2ecc71; font-weight:bold; }",
".humor-yellow { color:#f1c40f; font-weight:bold; }",
".humor-red { color:#e74c3c; font-weight:bold; }"
)

Set-Content $cssFile $css -Encoding UTF8

# ======================================================
# COLETAR PESSOAS DAS COMUNIDADES EXISTENTES
# ======================================================

$pessoas = @{}

Get-ChildItem "docs/comunidades" -Directory | ForEach-Object {

    $comunidade = $_.Name
    $membrosDir = "$($_.FullName)/membros"

    if (Test-Path $membrosDir) {
        Get-ChildItem $membrosDir -Directory | ForEach-Object {

            $slug = $_.Name

            if (!$pessoas.ContainsKey($slug)) {
                $pessoas[$slug] = @{
                    slug = $slug
                    comunidades = @()
                    papeis = @()
                }
            }

            $pessoas[$slug].comunidades += $comunidade
        }
    }
}

# ======================================================
# GERAR PERFIS DE PESSOAS
# ======================================================

foreach ($p in $pessoas.Keys) {

    $perfilDir = "$pessoasDir/$p"
    New-Item $perfilDir -ItemType Directory -Force | Out-Null

    # foto placeholder
    $foto = "$perfilDir/foto.jpg"
    if (!(Test-Path $foto)) {
        Set-Content $foto "(adicione uma foto aqui)"
    }

    # conexoes = pessoas da mesma comunidade
    $conexoes = @()
    foreach ($c in $pessoas[$p].comunidades) {
        foreach ($outro in $pessoas.Keys) {
            if ($outro -ne $p -and $pessoas[$outro].comunidades -contains $c) {
                if ($conexoes -notcontains $outro) {
                    $conexoes += $outro
                }
            }
        }
    }

    $md = @()
    $md += "<div class='profile-card'>"
    $md += "<img src='foto.jpg' class='profile-avatar'/>"
    $md += "<div class='profile-name'>$p</div>"
    $md += "<div class='profile-section'><h2>Comunidades</h2><ul>"

    foreach ($c in $pessoas[$p].comunidades) {
        $md += "<li><a href='../../comunidades/$c/'>$c</a></li>"
    }

    $md += "</ul></div>"
    $md += "<div class='profile-section'><h2>Conexoes</h2><ul>"

    foreach ($cx in $conexoes) {
        $md += "<li><a href='../$cx/'>$cx</a></li>"
    }

    $md += "</ul></div>"
    $md += "<div class='profile-section'><h2>Status</h2><p>Em andamento</p></div>"
    $md += "<div class='profile-section'><h2>Humor</h2><span class='humor-green'>Estavel</span></div>"
    $md += "</div>"

    Set-Content "$perfilDir/index.md" $md -Encoding UTF8
}

# ======================================================
# ATUALIZAR COMUNIDADES PARA LINKAR PESSOAS
# ======================================================

Get-ChildItem "docs/comunidades" -Directory | ForEach-Object {

    $com = $_.Name
    $index = "$($_.FullName)/index.md"

    if (Test-Path $index) {
        $conteudo = Get-Content $index
        $conteudo += ""
        $conteudo += "## Pessoas"
        foreach ($p in $pessoas.Keys) {
            if ($pessoas[$p].comunidades -contains $com) {
                $conteudo += "- [$p](../../pessoas/$p/)"
            }
        }
        Set-Content $index $conteudo -Encoding UTF8
    }
}

# ======================================================
# ATUALIZAR MKDOCS
# ======================================================

$mk = Get-Content "mkdocs.yml"
if ($mk -notcontains "  - stylesheets/social.css") {
    Add-Content "mkdocs.yml" ""
    Add-Content "mkdocs.yml" "extra_css:"
    Add-Content "mkdocs.yml" "  - stylesheets/social.css"
}

# ======================================================
# FINAL
# ======================================================

Write-Host "Setup social aplicado com sucesso"
Write-Host "Rollback disponivel em: $rollbackDir"
Write-Host "Para desfazer: copie o conteudo de $rollbackDir de volta para a raiz"
