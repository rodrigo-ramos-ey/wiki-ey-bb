Write-Host "Setup completo de comunidades - MkDocs"

# Base
$baseDocs = "docs/comunidades"

# Definicao das comunidades (ALINHADAS AO PRINT)
$comunidades = @(
  @{ nome="TryCatchers"; pasta="trycatchers"; lider="Luiza Abreu"; liderPasta="luiza-abreu"; exLider="Thiago Favorino" },
  @{ nome="Capotamasnumbreca"; pasta="capotamasnumbreca"; lider="Fabio Rhormens"; liderPasta="fabio-rhormens" },
  @{ nome="MainFriends"; pasta="mainfriends"; lider="Mauro Napoli"; liderPasta="mauro-napoli" },
  @{ nome="CloudDevios"; pasta="clouddevios"; lider="Rodrigo Ramos"; liderPasta="rodrigo-ramos" },
  @{ nome="Technautas"; pasta="technautas"; lider="Mariany Santos"; liderPasta="mariany-santos" },
  @{ nome="Apollo DEVs"; pasta="apollodevs"; lider="Josue Alcantara"; liderPasta="josue-alcantara" },
  @{ nome="404 Ninjas"; pasta="404-ninjas"; lider="Pedro Borges"; liderPasta="pedro-borges" },
  @{ nome="R.I.P (REST in Peace)"; pasta="rip"; lider="Gabriel Serafim"; liderPasta="gabriel-serafim" },
  @{ nome="ArchiByte"; pasta="archibyte"; lider="Daniel Dantas"; liderPasta="daniel-dantas" }
)

# Criar base
if (!(Test-Path $baseDocs)) {
  New-Item $baseDocs -ItemType Directory -Force | Out-Null
}

# ======================================================
# INDEX GERAL DE COMUNIDADES
# ======================================================
$index = @()
$index += "# Comunidades"
$index += ""
$index += "Lista oficial das comunidades tecnicas da EY BB."
$index += ""
$index += "## Tech"
$index += ""

foreach ($c in $comunidades) {
  $linha = "- [" + $c.nome + "](" + $c.pasta + "/) - " + $c.lider
  $index += $linha
}

Set-Content -Path ($baseDocs + "/index.md") -Value $index -Encoding UTF8

# ======================================================
# PAGINAS DE COMUNIDADES E PERFIS
# ======================================================
foreach ($c in $comunidades) {

  $comBase = $baseDocs + "/" + $c.pasta
  $membrosBase = $comBase + "/membros"
  $liderBase = $membrosBase + "/" + $c.liderPasta

  New-Item $liderBase -ItemType Directory -Force | Out-Null

  # ---------- Pagina da Comunidade ----------
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
  $conteudoComunidade += "- [" + $c.lider + "](membros/" + $c.liderPasta + "/) - Lider"

  if ($c.ContainsKey("exLider")) {
    $conteudoComunidade += "- " + $c.exLider
  }

  Set-Content -Path ($comBase + "/index.md") -Value $conteudoComunidade -Encoding UTF8

  # ---------- Perfil do Lider ----------
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
  $conteudoLider += "Responsavel pela lideranca da comunidade."
  $conteudoLider += ""
  $conteudoLider += "## Termometro de humor"
  $conteudoLider += "Verde"

  Set-Content -Path ($liderBase + "/index.md") -Value $conteudoLider -Encoding UTF8
}

# ======================================================
# LIMPEZA DE BUILD ANTIGO
# ======================================================
if (Test-Path "site") {
  Remove-Item -Recurse -Force site
}

# ======================================================
# DEPLOY
# ======================================================
Write-Host "Publicando no GitHub Pages..."
mkdocs gh-deploy --clean

Write-Host "Setup finalizado com sucesso"
