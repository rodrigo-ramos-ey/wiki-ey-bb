Write-Host "=== SETUP DEFINITIVO WIKI EY-BB ==="
$ErrorActionPreference = "Stop"

# =====================================================
# BACKUP AUTOMATICO
# =====================================================
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
if (!(Test-Path "_rollback")) {
    New-Item "_rollback" -ItemType Directory | Out-Null
}

git add . | Out-Null
git commit -m "backup: antes do setup definitivo ($ts)" | Out-Null

# =====================================================
# LIMPEZA TOTAL
# =====================================================
if (Test-Path "site") { Remove-Item "site" -Recurse -Force }
if (Test-Path "docs/pessoas") { Remove-Item "docs/pessoas" -Recurse -Force }

# remove pastas membros dentro de comunidades (modelo errado antigo)
Get-ChildItem "docs/comunidades" -Recurse -Directory -ErrorAction SilentlyContinue |
Where-Object { $_.Name -eq "membros" } |
ForEach-Object { Remove-Item $_.FullName -Recurse -Force }

# =====================================================
# ESTRUTURA BASE CORRETA
# =====================================================
$docs    = "docs"
$comDir  = "$docs/comunidades"
$membDir = "$docs/membros"
$cssDir  = "$docs/stylesheets"

New-Item $comDir  -ItemType Directory -Force | Out-Null
New-Item $membDir -ItemType Directory -Force | Out-Null
New-Item $cssDir  -ItemType Directory -Force | Out-Null

# =====================================================
# CSS SOCIAL
# =====================================================
@"
.profile-card { max-width:720px; margin:auto; padding:24px; background:#1e1f26; border-radius:12px }
.profile-avatar { width:160px; height:160px; border-radius:50%; display:block; margin:auto; border:4px solid #f7c600 }
.profile-name { text-align:center; font-size:2rem; margin-top:16px; color:#ffffff }
.profile-section { margin-top:24px }
.profile-section h2 { color:#f7c600 }
"@ | Set-Content "$cssDir/social.css" -Encoding UTF8

# =====================================================
# REGISTRO OFICIAL - FONTE UNICA
# =====================================================
$comunidades = @(
@{ nome="TryCatchers"; pasta="trycatchers"; lider="Luiza Abreu"; membros=@(
  "Thiago Favorino","Alan Barbosa","Felipe Silveira","Guilherme Oliveira",
  "Luiz Octavio Horta","Tairone Gomes (Deploy)","Thais Guedes (OF)"
)},
@{ nome="MainFriends"; pasta="mainfriends"; lider="Mauro Napoli"; membros=@(
  "Alessandro Miranda (Deploy)","Arthur Letissio","Bruna Bertolotto",
  "Bernardo Sousa","Dalvolinda da Silva","Daniel Dantas (OF)",
  "Karoline Gomes","Mayara Serra (Vice-lider / Timesheet)","Rodrigo Ramos"
)},
@{ nome="Technautas"; pasta="technautas"; lider="Mariany Santos"; membros=@(
  "Antonio Melo","Fabricio Lemos (Deploy)","Karolina Trindade (Timesheet)",
  "Maria Melo","Rodrigo Santos","Vitor Matheus (OF)",
  "Vinicius Vieira","Yago Santos"
)},
@{ nome="CapotaMasNumBrega"; pasta="capotamasnumbreca"; lider="Fabio Rhormens"; membros=@(
  "Alessandro Miranda","Eduardo Borges","Gabriel Cardoso","Gabriel Carvalho",
  "Gabriel Caneschi","Gabriel Freitas (Vice-lider)","Kenia Duarte (OF)",
  "Marcus Monteiro"
)},
@{ nome="ClouDevios"; pasta="cloudevis"; lider="Rodrigo Ramos"; membros=@(
  "Fabio Rhormens","Marcos Porfirio","Mauro Napoli","Roberto Souza"
)},
@{ nome="Apollo DEVs"; pasta="apollodevs"; lider="Josue Alcantara"; membros=@(
  "Joel Silva (Deploy)","Felipe Saraiva","Luca Lacerda",
  "Jose Martinez","Kevin Mailho","Rychard Ryan"
)},
@{ nome="404 Ninjas"; pasta="404-ninjas"; lider="Pedro Borges"; membros=@(
  "Alan Lima (Vice-lider)","Daniel Mesquita","Eriani da Silva","Luiza Sofal",
  "Marcos Fabio","Mariane Rozeno (OF)","Rafael Goncalves","Wesley Barbosa"
)},
@{ nome="R.I.P (REST in Peace)"; pasta="rip"; lider="Gabriel Serafim"; membros=@(
  "Ivens Oliveira","Fabricio Barbosa","Lucas Almeida","Lucas Bueno",
  "Mikaela Pereira","Magno Mendes","Moises Araujo","Lucas Gomes"
)},
@{ nome="ArchiByte"; pasta="archibyte"; lider="Daniel Dantas"; membros=@(
  "Alan Bruno de Melo Rosa","Ciro Jose Velozo Ribeiro",
  "Gabriel Moreira da Silva","Thaissa Lopes Moreira","Romulo Belo"
)}
)

# =====================================================
# MAPA GLOBAL DE MEMBROS
# =====================================================
$membros = @{}

function Add-Membro {
    param($nome,$comunidade,$papel)

    $slug = $nome.ToLower()
    $slug = $slug -replace "[^a-z0-9áéíóúãõç ]",""
    $slug = $slug -replace " ","-"

    if (!$membros.ContainsKey($slug)) {
        $membros[$slug] = @{
            nome = $nome
            comunidades = @()
        }
    }

    $membros[$slug].comunidades += "$comunidade - $papel"
}

# =====================================================
# COMUNIDADES
# =====================================================
$indexCom = @("# Comunidades Tech","")

foreach ($c in $comunidades) {

    $cDir = "$comDir/$($c.pasta)"
    New-Item $cDir -ItemType Directory -Force | Out-Null

    $indexCom += "- [$($c.nome)]($($c.pasta)/)"

    $md = @(
        "# $($c.nome)",
        "",
        "## Lider",
        $c.lider,
        "",
        "## Integrantes",
        ""
    )

    Add-Membro $c.lider $c.nome "Lider"

    foreach ($m in $c.membros) {

        if ($m -match "(.*)\s+\((.*)\)") {
            $nome  = $Matches[1]
            $papel = $Matches[2]
        } else {
            $nome  = $m
            $papel = "Membro"
        }

        $slug = $nome.ToLower()
        $slug = $slug -replace "[^a-z0-9áéíóúãõç ]",""
        $slug = $slug -replace " ","-"

        $md += "- [$nome](../../membros/$slug/) - $papel"
        Add-Membro $nome $c.nome $papel
    }

    Set-Content "$cDir/index.md" $md -Encoding UTF8
}

Set-Content "$comDir/index.md" $indexCom -Encoding UTF8

# =====================================================
# PERFIS DE MEMBROS
# =====================================================
foreach ($slug in $membros.Keys) {

    $m = $membros[$slug]
    $dir = "$membDir/$slug"
    New-Item $dir -ItemType Directory -Force | Out-Null

    if (!(Test-Path "$dir/foto.jpg")) {
        Set-Content "$dir/foto.jpg" "placeholder"
    }

    $md = @(
        "# $($m.nome)",
        "",
        "![Foto](foto.jpg)",
        "",
        "## Comunidades"
    )

    foreach ($c in $m.comunidades) {
        $md += "- $c"
    }

    $md += @(
        "",
        "## Status Atual",
        "Em andamento",
        "",
        "## Termometro de Humor",
        "Verde"
    )

    Set-Content "$dir/index.md" $md -Encoding UTF8
}

# =====================================================
# MKDOCS
# =====================================================
@"
site_name: Wiki EY-BB
docs_dir: docs
site_dir: site
theme:
  name: material
nav:
  - Home: index.md
  - Comunidades: comunidades/index.md
extra_css:
  - stylesheets/social.css
"@ | Set-Content "mkdocs.yml" -Encoding UTF8

Write-Host "=== SETUP FINALIZADO COM SUCESSO ==="
Write-Host "Execute agora: mkdocs serve"
