Write-Host "=== Setup Social MkDocs | MODELO CORRETO ==="
$ErrorActionPreference = "Stop"

# =========================
# ROLLBACK
# =========================
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$rollbackDir = "_rollback/$timestamp"

New-Item $rollbackDir -ItemType Directory -Force | Out-Null
if (Test-Path "docs") { Copy-Item "docs" $rollbackDir -Recurse -Force }
if (Test-Path "mkdocs.yml") { Copy-Item "mkdocs.yml" $rollbackDir }

git add .
git commit -m "backup: antes do setup social ($timestamp)" | Out-Null

# =========================
# BASE
# =========================
$docs = "docs"
$comDir = "$docs/comunidades"
$pessoasDir = "$docs/pessoas"
$cssDir = "$docs/stylesheets"

New-Item $comDir -ItemType Directory -Force | Out-Null
New-Item $pessoasDir -ItemType Directory -Force | Out-Null
New-Item $cssDir -ItemType Directory -Force | Out-Null

# =========================
# CSS SOCIAL
# =========================
@(
".profile-card { max-width:720px; margin:auto; padding:24px; background:#1e1f26; border-radius:12px }",
".profile-avatar { width:160px; height:160px; border-radius:50%; display:block; margin:auto; border:4px solid #f7c600 }",
".profile-name { text-align:center; font-size:2rem; margin-top:16px; color:#fff }",
".profile-section { margin-top:24px }",
".profile-section h2 { color:#f7c600 }"
) | Set-Content "$cssDir/social.css" -Encoding UTF8

# =========================
# DADOS (FONTE ÚNICA)
# =========================
$dados = $comunidades   # <-- USA EXATAMENTE O QUE VOCÊ JÁ TEM

# =========================
# MAPA DE PESSOAS
# =========================
$pessoas = @{}

foreach ($c in $dados) {
  foreach ($m in $c.membros) {
    $slug = $m.nome.ToLower().Replace(" ","-")
    if (!$pessoas.ContainsKey($slug)) {
      $pessoas[$slug] = @{
        nome = $m.nome
        slug = $slug
        comunidades = @()
        papeis = @()
      }
    }
    $pessoas[$slug].comunidades += $c.pasta
    $pessoas[$slug].papeis += ($m.papel + " (" + $c.nome + ")")
  }
}

# =========================
# COMUNIDADES (SÓ LISTA)
# =========================
foreach ($c in $dados) {
  $dir = "$comDir/$($c.pasta)"
  New-Item $dir -ItemType Directory -Force | Out-Null

  $md = @()
  $md += "# " + $c.nome
  $md += ""
  $md += "## Pessoas"
  $md += ""

  foreach ($m in $c.membros) {
    $slug = $m.nome.ToLower().Replace(" ","-")
    $md += "- [" + $m.nome + "](../../pessoas/" + $slug + "/)"
  }

  Set-Content "$dir/index.md" $md -Encoding UTF8
}

# =========================
# PERFIS (FACEBOOK-LIKE)
# =========================
foreach ($p in $pessoas.Values) {

  $dir = "$pessoasDir/$($p.slug)"
  New-Item $dir -ItemType Directory -Force | Out-Null

  if (!(Test-Path "$dir/foto.jpg")) {
    Set-Content "$dir/foto.jpg" "adicione foto aqui"
  }

  $md = @()
  $md += "<div class='profile-card'>"
  $md += "<img src='foto.jpg' class='profile-avatar'/>"
  $md += "<div class='profile-name'>" + $p.nome + "</div>"

  $md += "<div class='profile-section'><h2>Comunidades</h2><ul>"
  foreach ($c in $p.comunidades) {
    $md += "<li><a href='../../comunidades/" + $c + "/'>" + $c + "</a></li>"
  }
  $md += "</ul></div>"

  $md += "<div class='profile-section'><h2>Papéis</h2><ul>"
  foreach ($r in $p.papeis) {
    $md += "<li>" + $r + "</li>"
  }
  $md += "</ul></div>"

  $md += "<div class='profile-section'><h2>Status</h2>Em andamento</div>"
  $md += "<div class='profile-section'><h2>Humor</h2>Estável</div>"
  $md += "</div>"

  Set-Content "$dir/index.md" $md -Encoding UTF8
}

# =========================
# MKDOCS
# =========================
if ((Get-Content "mkdocs.yml") -notmatch "social.css") {
  Add-Content "mkdocs.yml" "extra_css:"
  Add-Content "mkdocs.yml" "  - stylesheets/social.css"
}

Write-Host "FINALIZADO COM SUCESSO"
Write-Host "Rollback: git reset --hard HEAD~1"
