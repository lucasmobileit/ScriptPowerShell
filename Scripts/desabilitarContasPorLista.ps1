# Criei uma variavel para ler o conteudo do documento que recebi do RH;
$dados = Import-Csv "usuarios_desligados.csv" 
#Criando um arquivo para futuramente receber os logs;
set-content -path "Logs.txt" -Value "Logs"

foreach($dado in $dados) {
    # Verifica se o usuario que esta na lista existe:
    $usuario = $dado.usuario_desligado.Trim()


    if(Get-ADUser -Filter {SamAccountName -eq $usuario} -ErrorAction SilentlyContinue ) {
        Disable-ADAccount -Identity $usuario
        Write-Host "Conta $usuario desativada com sucesso!"
        Add-Content -path "Logs.txt" -Value "[$(Get-Date)] Conta $usuario Desativada."
    } else {
        #Caso o usuario nao for encontrado
        Write-Host "Usuario nao encontrado." 
        Add-Content -path "Logs.txt" -Value "[$(Get-Date)] conta $usuario nao existe."  
    }
}
