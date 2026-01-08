Write-Host "=== Setup Social MkDocs (modelo correto, com rollback) ==="

# =========================
# CONFIG
# =========================

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$rollbackDir = "_rollback/$timestamp"
$docsDir = "docs"
$comunidadesDir = "docs/comunidades"
$pessoasDir = "docs/pessoas"

# =========================
# BACKUP / ROLLBACK
# =========================

Write-Host "Criando backup..."

New-Item $rollbackDir -ItemType Directory -Force | Out-Null
Copy-Item $docsDir $rollbackDir -Recurse -Force
Copy-Item "mkdocs.yml" $rollbackDir -Force

git add .
git commit -m "backup: antes do setup social ($timestamp)"

# =========================
# CSS SOCIAL
# =========================

$cssDir = "docs/stylesheets"
New-Item $cssDir -ItemType Directory -Force | Out-Null

$cssFile = "$cssDir/social.css"

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
  object-fit: cover;
  display: block;
  margin: auto;
  border: 4px solid #f7c600;
}
.profile-name {
  text-align: center;
  font-size: 2rem;
  margin-top: 16px;
  color: #ffffff;
}
.profile-section {
  margin-top: 24px;
}
.profile-section h2 {
  color: #f7c600;
  font-size: 1.2rem;
}
.humor-green { color: #2ecc71; font-weight: bold; }
.humor-yellow { color: #f1c40f; font-weight: bold; }
.humor-red { color: #e74c3c; font-weight: bold; }
"@ | Set-Content $cssFile -Encoding UTF8

# =========================
# COLETAR PESSOAS DAS COMUNIDADES
# =========================

$pessoas = @{}

Get-ChildItem $comunidadesDir -Directory | ForEach-Object {

    $comSlug = $_.Name
    $indexFile = "$($_.FullName)/index.md"

    if (!(Test-Path $indexFile)) { return }

    Get-Content $indexFile | ForEach-Object {

        if ($_ -match '^- \[(.+?)\].+[-–—] (.+)$') {

            $nome = $matches[1]
            $papel = $matches[2]
            $slug = $nome.ToLower().Replace(" ", "-")

            if (-not $pessoas.ContainsKey($slug)) {
                $pessoas[$slug] = @{
                    nome = $nome
                    slug = $slug
                    comunidades = @()
                    papeis = @()
                }
            }

            $pessoas[$slug].comunidades += $comSlug
            $pessoas[$slug].papeis += "$papel ($comSlug)"
        }
    }
}

# =========================
# CRIAR PERFIS (PESSOA)
# =========================

New-Item $pessoasDir -ItemType Directory -Force | Out-Null

foreach ($p in $pessoas.Values) {

    $perfilDir = "$pessoasDir/$($p.slug)"
    New-Item $perfilDir -ItemType Directory -Force | Out-Null

    $foto = "$perfilDir/foto.jpg"
    if (!(Test-Path $foto)) {
        Set-Content $foto "adicione uma foto aqui"
    }

    # conexoes = pessoas das mesmas comunidades
    $conexoes = @()
    foreach ($o in $pessoas.Values) {
        if ($o.slug -ne $p.slug) {
            foreach ($c in $p.comunidades) {
                if ($o.comunidades -contains $c) {
                    $conexoes += $o
                    break
                }
            }
        }
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
<h2>Papéis</h2>
<ul>
$(($p.papeis | ForEach-Object { "<li>$_</li>" }) -join "`n")
</ul>
</div>

<div class="profile-section">
<h2>Conexões</h2>
<ul>
$(($conexoes | ForEach-Object { "<li><a href='../$($_.slug)/'>$($_.nome)</a></li>" }) -join "`n")
</ul>
</div>

<div class="profile-section">
<h2>Status</h2>
Em andamento
</div>

<div class="profile-section">
<h2>Humor</h2>
<span class="humor-green">Estável</span>
</div>

</div>
"@ | Set-Content "$perfilDir/index.md" -Encoding UTF8
}

# =========================
# MKDOCS
# =========================

$mk = Get-Content "mkdocs.yml"
if ($mk -notcontains "  - stylesheets/social.css") {
@"
extra_css:
  - stylesheets/social.css
"@ | Add-Content "mkdocs.yml"
}

Write-Host "Setup social aplicado com sucesso"
Write-Host "Rollback: git reset --hard HEAD~1"
