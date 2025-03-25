# Carrega o módulo do Active Directory
Import-Module ActiveDirectory

# Define o período de inatividade 
$inatividade = 0
$data_limite = (Get-Date).AddDays(-$inatividade)

# Busca usuários e computadores inativos
$usuarios = Get-ADUser -Filter {LastLogonDate -lt $data_limite -and Enabled -eq $true} -Properties LastLogonDate, Name
$computadores = Get-ADComputer -Filter {LastLogonDate -lt $data_limite -and Enabled -eq $true} -Properties LastLogonDate, Name

# Verifica se há algo para processar
if (!$usuarios -and !$computadores) {
    Write-Host "Nada inativo encontrado!"
    exit
}

# Mostra usuários inativos
if ($usuarios) {
    Write-Host "Usuarios inativos:"
    foreach ($u in $usuarios) {
        Write-Host " - $($u.Name) (Ultimo login: $($u.LastLogonDate))"
    }
} else {
    Write-Host "Nenhum usuario inativo."
}

# Mostra computadores inativos
if ($computadores) {
    Write-Host "`nComputadores inativos:"
    foreach ($c in $computadores) {
        Write-Host " - $($c.Name) (Ultimo login: $($c.LastLogonDate))"
    }
} else {
    Write-Host "Nenhum computador inativo."
}

# Gera relatórios simples em CSV
$usuarios | Select-Object Name, LastLogonDate | Export-Csv "usuarios_inativos.csv" -NoTypeInformation  # Exporta os usuários inativos
$computadores | Select-Object Name, LastLogonDate | Export-Csv "computadores_inativos.csv" -NoTypeInformation # Exporta os computadores inativos
Write-Host "`nRelatorios salvos como 'usuarios_inativos.csv' e 'computadores_inativos.csv'."

# Pergunta se quer agir
$acao = Read-Host "Desativar ou remover contas inativas? ([D]esativar/[R]emover/[S]air)" 
if ($acao -eq "D") {
    foreach ($u in $usuarios) {
        Disable-ADAccount -Identity $u.Name
        Write-Host "Usuario $($u.Name) desativado."
    }
    foreach ($c in $computadores) {
        Disable-ADAccount -Identity $c.Name
        Write-Host "Computador $($c.Name) desativado."
    }
} elseif ($acao -eq "R") {
    foreach ($u in $usuarios) {
        Remove-ADUser -Identity $u.Name -Confirm:$false
        Write-Host "Usuario $($u.Name) removido."
    }
    foreach ($c in $computadores) {
        Remove-ADComputer -Identity $c.Name -Confirm:$false
        Write-Host "Computador $($c.Name) removido."
    }
}


# Envia e-mail se alguma ação foi feita
if ($acao -eq "D" -or $acao -eq "R") {
    $mensagem = "Ação executada em $(Get-Date): $usuarios.Count usuários e $computadores.Count computadores afetados."
    Send-MailMessage -To "admin@exemplo.local" `
                     -From "notificacoes@exemplo.local" `
                     -Subject "Acao em Contas Inativas" `
                     -Body $mensagem `
                     -Attachments "usuarios_inativos.csv", "computadores_inativos.csv" `
                     -SmtpServer "smtp.exemplo.local"
    Write-Host "Email enviado ao administrador."
}

# Resumo final
Write-Host "`nFim do script.`nUsuarios inativos: $($usuarios.Count).`nComputadores inativos: $($computadores.Count)."
