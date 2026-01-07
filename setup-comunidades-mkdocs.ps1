Write-Host "Setup completo de comunidades - MkDocs"

$baseDocs = "docs/comunidades"

$comunidades = @(
  @{
    nome="TryCatchers"; pasta="trycatchers";
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
  },
  @{
    nome="MainFriends"; pasta="mainfriends";
    membros=@(
      @{nome="Mauro Napoli"; papel="Lider"},
      @{nome="Alessandro Miranda"; papel="Deploy"},
      @{nome="Arthur Letissio"; papel="Membro"},
      @{nome="Bruna Bertolotto"; papel="Membro"},
      @{nome="Bernardo Sousa"; papel="Membro"},
      @{nome="Dalvolinda da Silva"; papel="Membro"},
      @{nome="Daniel Dantas"; papel="OF"},
      @{nome="Karoline Gomes"; papel="Membro"},
      @{nome="Mayara Serra"; papel="Vice-Lider / Timesheet"},
      @{nome="Rodrigo Ramos"; papel="Membro"}
    )
  },
  @{
    nome="Technautas"; pasta="technautas";
    membros=@(
      @{nome="Mariany Santos"; papel="Lider"},
      @{nome="Antonio Melo"; papel="Membro"},
      @{nome="Fabricio Lemos"; papel="Deploy"},
      @{nome="Karolina Trindade"; papel="Timesheet"},
      @{nome="Maria Melo"; papel="Membro"},
      @{nome="Rodrigo Santos"; papel="Membro"},
      @{nome="Vitor Matheus"; papel="OF"},
      @{nome="Vinicius Vieira"; papel="Membro"},
      @{nome="Yago Santos"; papel="Membro"}
    )
  },
  @{
    nome="CloudDevios"; pasta="clouddevios";
    membros=@(
      @{nome="Rodrigo Ramos"; papel="Lider"},
      @{nome="Fabio Rhormens"; papel="Membro"},
      @{nome="Marcos Porfirio"; papel="Membro"},
      @{nome="Mauro Napoli"; papel="Membro"},
      @{nome="Roberto Souza"; papel="Membro"}
    )
  },
  @{
    nome="Apollo DEVs"; pasta="apollodevs";
    membros=@(
      @{nome="Josue Alcantara"; papel="Lider"},
      @{nome="Joel Silva"; papel="Deploy"},
      @{nome="Felipe Saraiva"; papel="Membro"},
      @{nome="Luca Lacerda"; papel="Membro"},
      @{nome="Jose Martinez"; papel="Membro"},
      @{nome="Kevin Mailho"; papel="Membro"},
      @{nome="Rychard Ryan"; papel="Membro"}
    )
  },
  @{
    nome="404 Ninjas"; pasta="404-ninjas";
    membros=@(
      @{nome="Pedro Borges"; papel="Lider"},
      @{nome="Alan Lima"; papel="Vice-Lider"},
      @{nome="Daniel Mesquita"; papel="Membro"},
      @{nome="Eriani da Silva"; papel="Membro"},
      @{nome="Luiza Sofal"; papel="Membro"},
      @{nome="Marcos Fabio"; papel="Membro"},
      @{nome="Mariane Rozeno"; papel="OF"},
      @{nome="Rafael Goncalves"; papel="Membro"},
      @{nome="Wesley Barbosa"; papel="Membro"}
    )
  },
  @{
    nome="R.I.P (REST in Peace)"; pasta="rip";
    membros=@(
      @{nome="Gabriel Serafim"; papel="Lider"},
      @{nome="Ivens Oliveira"; papel="Membro"},
      @{nome="Fabricio Barbosa"; papel="Membro"},
      @{nome="Lucas Almeida"; papel="Membro"},
      @{nome="Lucas Bueno"; papel="Membro"},
      @{nome="Mikaela Pereira"; papel="Membro"},
      @{nome="Magno Mendes"; papel="Membro"},
      @{nome="Moises Araujo"; papel="Membro"},
      @{nome="Lucas Gomes"; papel="Membro"}
    )
  },
  @{
    nome="ArchiByte"; pasta="archibyte";
    membros=@(
      @{nome="Daniel Dantas"; papel="Lider"},
      @{nome="Alan Bruno de Melo Rosa"; papel="Membro"},
      @{nome="Ciro Jose Velozo Ribeiro"; papel="Membro"},
      @{nome="Gabriel Moreira da Silva"; papel="Membro"},
      @{nome="Thaissa Lopes Moreira"; papel="Membro"},
      @{nome="Romulo Belo"; papel="Membro"}
    )
  }
)

# Garantir base
New-Item $baseDocs -ItemType Directory -Force | Out-Null

# ============================
# INDEX GERAL
# ============================
$index = @("# Comunidades","","## Tech","")
foreach ($c in $comunidades) {
  $lider = ($c.membros | Where-Object { $_.papel -eq "Lider" }).nome
  $index += "- [" + $c.nome + "](" + $c.pasta + "/) - " + $lider
}
Set-Content ($baseDocs + "/index.md") $index -Encoding UTF8

# ============================
# COMUNIDADES E MEMBROS
# ============================
foreach ($c in $comunidades) {

  $comBase = $baseDocs + "/" + $c.pasta
  $membrosBase = $comBase + "/membros"
  New-Item $membrosBase -ItemType Directory -Force | Out-Null

  $conteudo = @("# " + $c.nome,"","## Membros","")

  foreach ($m in $c.membros) {

    $slug = $m.nome.ToLower()
    $slug = $slug.Replace(" ","-")

    $conteudo += "- [" + $m.nome + "](membros/" + $slug + "/) - " + $m.papel

    $perfilPath = $membrosBase + "/" + $slug
    New-Item $perfilPath -ItemType Directory -Force | Out-Null

    $perfil = @(
      "# " + $m.nome,
      "",
      "Comunidade: " + $c.nome,
      "Papel: " + $m.papel,
      "",
      "## OF atual",
      "Nao informado",
      "",
      "## Status report",
      "Em andamento",
      "",
      "## Termometro de humor",
      "Verde"
    )

    Set-Content ($perfilPath + "/index.md") $perfil -Encoding UTF8
  }

  Set-Content ($comBase + "/index.md") $conteudo -Encoding UTF8
}

# ============================
# LIMPEZA BUILD
# ============================
if (Test-Path "site") {
  Remove-Item -Recurse -Force site
}

# ============================
# DEPLOY
# ============================
mkdocs gh-deploy --clean

Write-Host "Setup finalizado com sucesso"
