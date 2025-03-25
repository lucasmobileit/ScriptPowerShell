# Importando a lista com os usuários e grupos
$lista = "listausuarios.txt"

# Loop para criar os usuários e grupos baseados no arquivo .txt 
foreach ($usuario in Get-Content $lista) {

    # Separa os dados da lista para serem utilizados
    $dados = $usuario.Split(";")
    $nome = $dados[0]
    $departamento = $dados[1]
    
    # Nome do grupo, seguindo uma nomenclatura padrão
    $groupAD = "SP_$departamento"

    # Cria o grupo
    if(-not(Get-ADGroup -Filter {Name -eq $groupAD})) {
        New-ADGroup -Name $groupAD -GroupScope Global -GroupCategory Security -Description "Grupo de acesso ao departamento $departamento"
        write-host "Grupo $groupAD criado com sucesso!"
    }

    # Cria a senha
    $senha = ConvertTo-SecureString -AsPlainText "Senha123!" -Force

    # Cria o usuário
    if(-not(Get-ADUser -Filter {Name -eq $nome})) {
        New-ADUser -Name $nome -SamAccountName $nome -AccountPassword $senha -Enabled $true -ChangePasswordAtLogon $true
        write-host "Usuario $nome criado com sucesso!"
    }

    # Adiciona o usuário ao grupo
    Add-ADGroupMember -Identity $groupAD -Members $nome
    write-host "Usuario $nome adicionado ao grupo $groupAD com sucesso!"

    # Log
    Set-Content -path logdo$($nome).txt -value "Usuario $nome criado com sucesso, e adicionado ao seu grupo!"

}
