Write-Host "Setup completo de comunidades - MkDocs"

# Base
$baseDocs = "docs/comunidades"

# Definicao das comunidades
$comunidades = @(
  @{ nome="TryCatchers"; pasta="trycatchers"; lider="Thiago Favorino"; liderPasta="thiago-favorino" },
  @{ nome="Capotamasnumbreca"; pasta="capotamasnumbreca"; lider="Fabio Rhormens"; liderPasta="fabio-rhormens" },
  @{ nome="MainFriends"; pasta="mainfriends"; lider="Mauro Napoli"; liderPasta="mauro-napoli" },
  @{ nome="CloudDevios"; pasta="clouddevios"; lider="Rodrigo Ramos"; liderPasta="rodrigo-ramos" },
  @{ nome="Technautas"; pasta="technautas"; lider="Mariany Santos"; liderPasta="mariany-santos" },
  @{ nome="Apollo DEVs"; pasta="apollodevs"; lider="Josue Alcantara"; liderPasta="josue-alcantara" },
  @{ nome="404 Ninjas"; pasta="404-ninjas"; lider="pedro-borges"; liderPasta="pedro-borges" },
  @{ nome="R.I.P (REST in Peace)"; pasta="rip"; lider="Gabriel Serafim"; liderPasta="gabriel-serafim" },
  @{ nome="ArchiByte"; pasta="archibyte"; lider="Daniel Dantas"; liderPasta="daniel-dantas" }
)

# Criar base
if (!(Test-Path $baseDocs)) {
  New-Item $baseDocs -ItemType Directory -Force | Out-Null
}

# -------------------------
# INDEX GERAL
# -------------------------
$index = @()
$index += "# Comunidades"
$index += ""
$index += "Lista oficial das comunidades tecnicas."
$index += ""
$index += "## Tech"
$index += ""

foreach ($c in $comunidades) {
  $linha = "- [" + $c.nome + "](" + $c.pasta + "/) - " + $c.lider
  $index += $linha
}

Set-Content -Path ($baseDocs + "/index.md") -Value $index -Encoding UTF8

# -------------------------
# COMUNIDADES E MEMBROS
# -------------------------
foreach ($c in $comunidades) {

  $comBase = $baseDocs + "/" + $c.pasta
  $membrosBase = $comBase + "/membros"
  $liderBase = $membrosBase + "/" + $c.liderPasta

  New-Item $liderBase -ItemType Directory -Force | Out-Null

  # Comunidade
  $conteudoComunidade = @()
  $conteudoComunidade += "# " + $c.nome
  $conteudoComunidade += ""
  $conteudoComunidade += "Especialidade: Tecnologia"
  $conteudoComunidade += "Lider: " + $c.lider
  $conteudoComunidade += ""
  $conteudoComunidade += "## Sobre"
  $conteudoComunidade += "Comunidade tecnica formada por profissionais da EY BB."
  $conteudoComunidade += ""
  $conteudoComunidade += "## Membros"
  $conteudoComunidade += "- [" + $c.lider + "](membros/" + $c.liderPasta + "/)"

  Set-Content -Path ($comBase + "/index.md") -Value $conteudoComunidade -Encoding UTF8

  # Perfil do lider
  $conteudoLider = @()
  $conteudoLider += "# " + $c.lider
  $conteudoLider += ""
  $conteudoLider += "Comunidade: " + $c.nome
  $conteudoLider += "Papel: Lider"
  $conteudoLider += ""
  $conteudoLider += "## OF atual"
  $conteudoLider += "Nao informado"
  $conteudoLider += ""
  $conteudoLider += "## Status report"
  $conteudoLider += "Atuacao regular"
  $conteudoLider += ""
  $conteudoLider += "## Termometro de humor"
  $conteudoLider += "Verde"

  Set-Content -Path ($liderBase + "/index.md") -Value $conteudoLider -Encoding UTF8
}

# -------------------------
# LIMPEZA BUILD
# -------------------------
if (Test-Path "site") {
  Remove-Item -Recurse -Force site
}

# -------------------------
# DEPLOY
# -------------------------
Write-Host "Publicando no GitHub Pages..."
mkdocs gh-deploy --clean

Write-Host "Setup finalizado com sucesso"
