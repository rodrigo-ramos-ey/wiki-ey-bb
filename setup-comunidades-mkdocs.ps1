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
  }
)

# Garantir base
New-Item $baseDocs -ItemType Directory -Force | Out-Null

# INDEX GERAL
$index = @("# Comunidades","","## Tech","")
foreach ($c in $comunidades) {
  $lider = ($c.membros | Where-Object {$_.papel -eq "Lider"}).nome
  $index += "- [" + $c.nome + "](" + $c.pasta + "/) - " + $lider
}
Set-Content ($baseDocs + "/index.md") $index -Encoding UTF8

# COMUNIDADES E MEMBROS
foreach ($c in $comunidades) {

  $comBase = $baseDocs + "/" + $c.pasta
  $membrosBase = $comBase + "/membros"
  New-Item $membrosBase -ItemType Directory -Force | Out-Null

  # Pagina da comunidade
  $conteudo = @("# " + $c.nome,"","## Membros","")
  foreach ($m in $c.membros) {
    $slug = $m.nome.ToLower().Replace(" ","-")
    $conteudo += "- [" + $m.nome + "](membros/" + $slug + "/) - " + $m.papel

    # Perfil do membro
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

# Limpeza build
if (Test-Path "site") {
  Remove-Item -Recurse -Force site
}

# Deploy
mkdocs gh-deploy --clean

Write-Host "Setup finalizado com sucesso"
