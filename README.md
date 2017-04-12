### Sobre

#### **`Este script funciona apenas em servidores cPanel/WHM`**

Este script foi desenvolvido para alterar o DNS Master e Slave de um domínio ou de todas as contas de uma revenda.

### Utilização

A utilização é muito simples, após executar o script será solicitado o revendedor ou domínio. Se desejar alterar o DNS de apenas um domínio, digite o domínio em questão, como por exemplo: seudominio.com.br 

Caso deseje alterar o DNS de todas as contas de uma revenda, você deve digitar o revendedor(usuário), exemplo: wwwrevendedor

Este script pode ser útil quando for necessário alterar o DNS de todas as contas de uma revenda após uma migração, ou se ele desejar utilizar DNS personalizado em todas as contas. 

## Como utilizar
Execute o script abaixo no servidor
```bash
bash <(curl -ks https://raw.githubusercontent.com/renanpessoa/altera-dns/master/dns.sh)
```
