#!/bin/bash

<< 'COMENTARIO'

Script desenvolvido para alterar o DNS de uma conta cPanel ou de todas as contas de uma revenda.
Autor: Renan Pessoa       
E-Mail: renanhpessoa@gmail.com   
Data: 07/11/2015                   

** Antes de modificar o arquivo é realizado uma copia de segurança[dominio.db.bkp] **

COMENTARIO

<< 'CHANGELOG'

1.0 - 07 Novembro 2015 [ Autores: Renan Pessoa ]
  * Versão inicial

CHANGELOG

    # Adiciona cores ao script
    RS="\e[0;00m";
    R1="\e[31m";
    Y1="\e[1;33m";
    G1="\e[1;32m";  

    naomodifica="";

    inicio(){
   
    if [ -z $s1 ]; then
        read -p "Digite o revendedor ou domínio: " conta;

      else
        conta=$s1
    fi

    verifica2=$(echo "$conta" | grep -s "\.");

    if [[ -z "$conta" ]] ;then
      echo -e "\nEspaço em branco ? Digite um valor válido !  \n";
      inicio;
    fi

    if [[ ! -z $verifica2 ]] && [[ -z $(grep -w "^$conta" /etc/trueuserdomains | cut -d: -f1 | awk '{print $1}') ]];then
        echo -e "\nO domínio informado não existe ou é um dominio estacionado/adicional/subdomínio\n";
        inicio;
    fi

    if [[ -e /var/cpanel/users/$conta ]] || [[ ! -z $verifica2 ]];then

       if [[ $conta != $(grep -i -s owner /var/cpanel/users/$conta | cut -d= -f2) ]] && [[ -z $verifica2 ]];then

          echo -e "\nA conta existe, porém não é um revendedor ! \n";
          inicio;
        fi

       else
      echo -e "\nA conta informada não existe ou não foi encontrada !\n";
      inicio;

    fi
    }

    inicio;  

    lista=$(for i in `grep $conta /etc/trueuserowners | cut -d: -f1`; do grep -w -E "$i" /etc/trueuserdomains | cut -d: -f1 ; done;);
    clear;
    
 
    echo -e "\n$G1===========$RS Informações $G1===========$RS";
    
    if [[ ! -z $(echo "$conta" | grep -s "\.") ]];then
      lista=$(grep -w $conta /etc/trueuserdomains | cut -d: -f1); 
      echo -e "Domínio: $conta";
      echo -e "Usuário:" $(grep -w $conta /etc/trueuserdomains | awk '{print $2}') "\n";

    else
    
      echo -e "Revendedor: $conta";
      echo -e "Numero de contas:" $(grep $conta /etc/trueuserowners | wc -l);
      echo -e "Domínios:" $(echo $lista) "\n";
    
    fi  

    aviso(){
      echo -e "\nO formato do DNS está incorreto, ele deve ser da seguinte maneira: [algo].domínio.[algo] exemplo: ns1.seudominio.com.br\n";
           }

    dnspai(){

      dnsmaster(){
      
      read -p "Digite o novo DNS Master: " ns1;

      [[ -z $(echo "$ns1" | grep -E "^\w+\.\w+\.\w+") ]] && aviso && dnsmaster;
                 }

      dnsmaster;

      dnsslave(){
      
      read -p "Digite o novo DNS Slave:  " ns2;
      
      [[ -z $(echo "$ns2" | grep -E "^\w+\.\w+\.\w+") ]] && aviso && dnsslave;
                }

      dnsslave;

      echo -ne "\nVerifique se o DNS foi digitado corretamente, caso SIM aperte ENTER, caso NÃO aperte QUALQUER tecla para digitar novamente: ";
      read verifica;

      [[ ! -z $verifica ]] && dnspai;
    }

    dnspai;

    echo -e "\n$G1===========$RS Zonas Atualmente $G1===========$RS";

    atual()
    {
          for i in `echo $lista `; do 
               echo -e "\n"$G1"Dominio:"$RS" "$i"";
               echo -n "DNS Master: "; 
               master1=$(grep -w NS /var/named/"$i".db | grep -v ';' | sort | uniq | awk '{print $5}' | sed -n '1p' | sed 's/\.$//'); 

               echo "$master1" ; echo -n "DNS Slave:  ";
               slave2=$(grep -w NS /var/named/"$i".db | grep -v ';' | sort | uniq | awk '{print $5}' | sed -n '2p' | sed 's/\.$//'); 
               echo "$slave2" ;

               if [[ -z "$master1" ]] || [[ -z "$slave2" ]];then

                  if [[ $exibenovamente != "1" ]];then
                     echo -e ""$R1"=>"$RS" Não foi possível encontrar as entradas NS do domínio "$Y1"$i"$RS", por questões de segurança a zona de DNS não será modificada.";
                     naomodifica+=" $i "
                  else
                    echo -e "("$Y1"Não foi modificada"$RS")";
                  fi
               fi

          done;
    }
    
    atual;

    echo -e "\n$G1===========$RS Convertendo $G1===========$RS\n";
   
    converte()
    {
             for i in `echo $lista `; do
                 master=$(grep -w NS /var/named/"$i".db | grep -v ';' | sort | uniq | awk '{print $5}' | sed -n '1p' | sed 's/\.$//'); 
                 slave=$(grep -w NS /var/named/"$i".db | grep -v ';' | sort | uniq | awk '{print $5}' | sed -n '2p' | sed 's/\.$//'); 

                if [[ ! -z `echo "${naomodifica[@]}" | grep -w $i` ]];then

                    continue;

                else
                 
                   cp -Rap /var/named/"$i".db /var/named/"$i".db.bkp;
                   replace "$master" "$ns1" -- /var/named/"$i".db; 
                   replace "$slave" "$ns2" -- /var/named/"$i".db;
                fi

             done;
             rndc reload 2>/dev/null;
    }

    converte;   

    echo -e "\n$G1===========$RS Zonas Atualizadas $G1===========$RS";

    exibenovamente=1;
    atual;

    echo -e "\n$G1===========$RS Domínios que não foram atualizados $G1===========$RS";

    echo -e "${naomodifica[@]}" | xargs -n1;

    echo -e ""$G1"\nAs zonas foram atualizadas com sucesso, por gentileza verifique acima se tudo ocorreu da maneira esperada.\n\n[Foi gerado um arquivo de backup antes da alteração de cada zona com o seguinte formato: /var/named/dominio.db.bkp]"$RS"";
    exit;
