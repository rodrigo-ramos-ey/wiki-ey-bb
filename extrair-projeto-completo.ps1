# ==============================
# EXTRAIR ESTRUTURA + CONTEUDO DO PROJETO
# ==============================

$root = Get-Location
$output = "dump-projeto-completo.txt"

# Pastas a ignorar
$ignoreDirs = @(".git", "site", "node_modules", "__pycache__")

# Limpa arquivo anterior
if (Test-Path $output) {
    Remove-Item $output
}

Add-Content $output "=== DUMP COMPLETO DO PROJETO ==="
Add-Content $output ("Gerado em: " + (Get-Date))
Add-Content $output ""
Add-Content $output "RAIZ: $root"
Add-Content $output ""
Add-Content $output "----------------------------------------"
Add-Content $output ""

function IgnorarDiretorio($path) {
    foreach ($dir in $ignoreDirs) {
        if ($path -like "*\$dir*") {
            return $true
        }
    }
    return $false
}

Get-ChildItem -Recurse -Force | ForEach-Object {

    if (IgnorarDiretorio $_.FullName) {
        return
    }

    $relativePath = $_.FullName.Replace($root.Path + "\", "")

    if ($_.PSIsContainer) {

        Add-Content $output ""
        Add-Content $output ("[DIRETORIO] " + $relativePath)
        Add-Content $output ""

    } else {

        Add-Content $output ""
        Add-Content $output ("[ARQUIVO] " + $relativePath)
        Add-Content $output "----------------------------------------"

        try {
            $conteudo = Get-Content $_.FullName -Raw -ErrorAction Stop
            if ($conteudo.Trim().Length -eq 0) {
                Add-Content $output "(arquivo vazio)"
            } else {
                Add-Content $output $conteudo
            }
        } catch {
            Add-Content $output "(nao foi possivel ler o arquivo)"
        }

        Add-Content $output ""
        Add-Content $output "----------------------------------------"
    }
}

Add-Content $output ""
Add-Content $output "=== FIM DO DUMP ==="
