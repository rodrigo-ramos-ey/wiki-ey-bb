Write-Host "=== Setup Social MkDocs | EXECUTAVEL ==="

$ErrorActionPreference = "Stop"

# -------------------------
# CONFIG
# -------------------------
$docs = "docs"
$comDir = "$docs/comunidades"
$pessoasDir = "$docs/pessoas"
$cssDir = "$docs/stylesheets"
$rollback = "_rollback/$(Get-Date -Format yyyyMMdd-HHmmss)"

# -------------------------
# ROLLBACK
# -------------------------
Write-Host "Criando rollback..."
New-Item $rollback -ItemType Directory -Force | Out-Null
if (Test-Path $docs) { Copy-Item $docs $rollback -Recurse -Force }
if (Test-Path "mkdocs.yml") { Copy-Item "mkdocs.yml" $rollback }

git add .
git commit -m "backup: antes do setup social" | Out-Null

# -------------------------
# DADOS (FONTE UNICA)
# -------------------------
$dados = @(
  @{
    nome="TryCatchers"; slug="trycatchers";
    membros=@(
      @{nome="Luiza Abreu"; papel="Lider"},
      @{nome="Thiago Favorino"; papel="Membro"},
      @{nome="Alan Barbosa"; papel="Membro"},
      @{nome="Felipe Silveira"; papel="Membro"},
      @{nome="Guilherme Oliveira"; papel="Membro"},
      @{nome="Luiz Octavio Horta"; papel="Membro"},
      @{nome="Tairone Gomes"; papel="Deploy"},
      @{nome="Thais Guedes"; papel="OF"}
    )
  }
)

# -------------------------
# GARANTIR PASTAS
# -------------------------
New-Item $docs -ItemType Directory -Force | Out-Null
New-Item $comDir -ItemType Directory -Force | Out-Null
New-Item $pessoasDir -ItemType Directory -Force | Out-Null
New-Item $cssDir -ItemType Directory -Force | Out-Null

# -------------------------
# CSS
# -------------------------
@"
.profile-card { max-width:720px; margin:auto; padding:24px; background:#1e1f26; border-radius:12px }
.profile-avatar { width:160px; height:160px; border-radius:50%; display:block; margin:auto; border:4px solid #f7c600 }
.profile-name { text-align:center; font-size:2rem; margin-top:16px; color:#fff }
.profile-section { margin-top:24px }
.profile-section h2 { color:#f7c600 }
"@ | Set-Content "$cssDir/social.css" -Encoding UTF8

# -------------------------
# MAPA DE PESSOAS
# -------------------------
$pessoas = @{}

foreach ($c in $dados) {
  foreach ($m in $c.membros) {
    $slug = $m.nome.ToLower().Replace(" ","-")
    if (-not $pessoas.ContainsKey($slug)) {
      $pessoas[$slug] = @{
        nome=$m.nome
        slug=$slug
        comunidades=@()
        papeis=@()
      }
    }
    $pessoas[$slug].comunidades += $c.slug
    $pessoas[$slug].papeis += "$($m.papel) ($($c.nome))"
  }
}

# -------------------------
# COMUNIDADES
# -------------------------
foreach ($c in $dados) {
  $dir = "$comDir/$($c.slug)"
  New-Item $dir -ItemType Directory -Force | Out-Null

  @"
# $($c.nome)

## Membros
$(($c.membros | ForEach-Object {
"- [$($_.nome)](../../pessoas/$($_.nome.ToLower().Replace(" ","-"))/) - $($_.papel)"
}) -join "`n")
"@ | Set-Content "$dir/index.md" -Encoding UTF8
}

# -------------------------
# PERFIS
# -------------------------
foreach ($p in $pessoas.Values) {
  $dir = "$pessoasDir/$($p.slug)"
  New-Item $dir -ItemType Directory -Force | Out-Null

  if (!(Test-Path "$dir/foto.jpg")) {
    Set-Content "$dir/foto.jpg" "adicione foto aqui"
  }

  @"
<div class="profile-card">
<img src="foto.jpg" class="profile-avatar"/>
<div class="profile-name">$($p.nome)</div>

<div class="profile-section">
<h2>Comunidades</h2>
<ul>
$(($p.comunidades | ForEach-Object { "<li><a href='../../comunidades/$_/'>$_</a></li>" }) -join "`n")
</ul>
</div>

<div class="profile-section">
<h2>Papeis</h2>
<ul>
$(($p.papeis | ForEach-Object { "<li>$_</li>" }) -join "`n")
</ul>
</div>

<div class="profile-section">
<h2>Status</h2>
Em andamento
</div>

<div class="profile-section">
<h2>Humor</h2>
Estavel
</div>
</div>
"@ | Set-Content "$dir/index.md" -Encoding UTF8
}

# -------------------------
# MKDOCS
# -------------------------
if (!(Test-Path "mkdocs.yml")) {
@"
site_name: Wiki EY-BB
theme:
  name: material
"@ | Set-Content "mkdocs.yml"
}

if ((Get-Content "mkdocs.yml") -notmatch "social.css") {
@"
extra_css:
  - stylesheets/social.css
"@ | Add-Content "mkdocs.yml"
}

Write-Host "FINALIZADO COM SUCESSO"
Write-Host "Rollback: git reset --hard HEAD~1"
