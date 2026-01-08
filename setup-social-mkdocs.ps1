Write-Host "=== SETUP SOCIAL MKDOCS | MODO LOCAL (AUTORITARIO) ==="
$ErrorActionPreference = "Stop"

# ======================================================
# ROLLBACK (GIT)
# ======================================================
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

git add .
git commit -m "backup: estado antes do setup social ($timestamp)" | Out-Null

# ======================================================
# LIMPEZA
# ======================================================
if (Test-Path "site") {
    Remove-Item -Recurse -Force site
}

# ======================================================
# ESTRUTURA BASE
# ======================================================
$docs = "docs"
$comDir = "$docs/comunidades"
$pessoasDir = "$docs/pessoas"
$cssDir = "$docs/stylesheets"

New-Item $docs -ItemType Directory -Force | Out-Null
New-Item $comDir -ItemType Directory -Force | Out-Null
New-Item $pessoasDir -ItemType Directory -Force | Out-Null
New-Item $cssDir -ItemType Directory -Force | Out-Null

# ======================================================
# MKDOCS.YML (SOBRESCREVE - LOCAL)
# ======================================================
@"
site_name: Wiki EY-BB

theme:
  name: material

use_directory_urls: true

nav:
  - Home: index.md
  - Comunidades:
      - Visão Geral: comunidades/index.md
  - Pessoas: pessoas/
  - Onboarding: onboarding/index.md
  - OF: of/index.md
  - Ambiente BB: ambiente/index.md

extra_css:
  - stylesheets/social.css
"@ | Set-Content "mkdocs.yml" -Encoding UTF8

# ======================================================
# INDEX PRINCIPAL
# ======================================================
@"
# Wiki EY-BB

Bem-vindo à Wiki Corporativa EY-BB.

Este portal conecta **pessoas**, **comunidades técnicas** e **processos**.
"@ | Set-Content "$docs/index.md" -Encoding UTF8

# ======================================================
# CSS SOCIAL
# ======================================================
@"
.profile-card {
  max-width: 720px;
  margin: auto;
  padding: 24px;
  background: #1e1f26;
  border-radius: 12px;
}
.profile-avatar {
  width: 160px;
  height: 160px;
  border-radius: 50%;
  display: block;
  margin: auto;
  border: 4px solid #f7c600;
}
.profile-name {
  text-align: center;
  font-size: 2rem;
  margin-top: 16px;
}
.profile-section {
  margin-top: 24px;
}
.profile-section h2 {
  color: #f7c600;
}
"@ | Set-Content "$cssDir/social.css" -Encoding UTF8

# ======================================================
# DADOS (FONTE UNICA)
# ======================================================
$comunidades = @(
  @{
    nome="TryCatchers"; pasta="trycatchers";
    membros=@(
      @{nome="Luiza Abreu"; papel="Líder"},
      @{nome="Thiago Favorino"; papel="Membro"},
      @{nome="Alan Barbosa"; papel="Membro"},
      @{nome="Felipe Silveira"; papel="Membro"},
      @{nome="Guilherme Oliveira"; papel="Membro"},
      @{nome="Luiz Octavio Horta"; papel="Membro"},
      @{nome="Tairone Gomes"; papel="Deploy"},
      @{nome="Thais Guedes"; papel="OF"}
    )
  },
  @{
    nome="MainFriends"; pasta="mainfriends";
    membros=@(
      @{nome="Mauro Napoli"; papel="Líder"},
      @{nome="Alessandro Miranda"; papel="Deploy"},
      @{nome="Arthur Letissio"; papel="Membro"},
      @{nome="Bruna Bertolotto"; papel="Membro"},
      @{nome="Bernardo Sousa"; papel="Membro"},
      @{nome="Dalvolinda da Silva"; papel="Membro"},
      @{nome="Daniel Dantas"; papel="OF"},
      @{nome="Karoline Gomes"; papel="Membro"},
      @{nome="Mayara Serra"; papel="Vice-Líder"},
      @{nome="Rodrigo Ramos"; papel="Membro"}
    )
  }
)

# ======================================================
# MAPA DE PESSOAS
# ======================================================
$pessoas = @{}

foreach ($c in $comunidades) {
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
    $pessoas[$slug].papeis += "$($m.papel) ($($c.nome))"
  }
}

# ======================================================
# COMUNIDADES
# ======================================================
$indexCom = @("# Comunidades","","Lista das comunidades técnicas.","")

foreach ($c in $comunidades) {

  $dir = "$comDir/$($c.pasta)"
  New-Item $dir -ItemType Directory -Force | Out-Null

  $indexCom += "- [$($c.nome)]($($c.pasta)/)"

  $md = @("# $($c.nome)","","## Pessoas","")
  foreach ($m in $c.membros) {
    $slug = $m.nome.ToLower().Replace(" ","-")
    $md += "- [$($m.nome)](../../pessoas/$slug/index.md)"
  }

  Set-Content "$dir/index.md" $md -Encoding UTF8
}

Set-Content "$comDir/index.md" $indexCom -Encoding UTF8

# ======================================================
# PERFIS (FACEBOOK-LIKE)
# ======================================================
foreach ($p in $pessoas.Values) {

  $dir = "$pessoasDir/$($p.slug)"
  New-Item $dir -ItemType Directory -Force | Out-Null

  if (!(Test-Path "$dir/foto.jpg")) {
    Set-Content "$dir/foto.jpg" "adicione-foto-aqui"
  }

  $md = @()
  $md += "<div class='profile-card'>"
  $md += "<img src='foto.jpg' class='profile-avatar'/>"
  $md += "<div class='profile-name'>$($p.nome)</div>"

  $md += "<div class='profile-section'><h2>Comunidades</h2><ul>"
  foreach ($c in $p.comunidades) {
    $md += "<li><a href='../../comunidades/$c/index.md'>$c</a></li>"
  }
  $md += "</ul></div>"

  $md += "<div class='profile-section'><h2>Papéis</h2><ul>"
  foreach ($r in $p.papeis) {
    $md += "<li>$r</li>"
  }
  $md += "</ul></div>"

  $md += "<div class='profile-section'><h2>Status</h2>Em andamento</div>"
  $md += "<div class='profile-section'><h2>Humor</h2>Estável</div>"
  $md += "</div>"

  Set-Content "$dir/index.md" $md -Encoding UTF8
}

Write-Host "=== SETUP FINALIZADO ==="
Write-Host "Agora execute: mkdocs serve"
