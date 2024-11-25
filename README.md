# Cyber-Infra-AWS

## Participantes - Grupo 3

- [Felipe Maluli](https://github.com/FeMCDias)
- [Lucca Hiratsuca](https://github.com/LuccaHiratsuca)
- [Thomas Chiari](https://github.com/thomaschiari)

## Infraestrutura:

<img width="878" alt="image" src="https://github.com/user-attachments/assets/c2f2345a-44ea-41a6-bead-688b062fac8e">


Falando um pouco sobre nossa infraestrutura:

Criamos uma Virtual Private Cloud (VPC) com duas subnets para segmentarmos os melhor nossos recursos para ter uma maior segurança da infraestrutura, sendo elas:

- ## Sub-rede pública:

  Esta sub-rede é configurada para ser acessível pela Internet por meio de um **Internet Gateway**. Ela hospeda serviços que necessitam de comunicação externa ou interação direta com usuários e sistemas externos.
  
  ### Serviços Implementados
  
  #### 1. **Jump Server**
  - Ponto de acesso seguro que atua como intermediário para gerenciar e interagir com os recursos dentro do ambiente.
  - Protege o acesso direto às instâncias, garantindo maior segurança e controle.
  
  #### 2. **Zabbix**
  - Ferramenta robusta de monitoramento de infraestrutura.
  - Coleta métricas do ambiente e assegura o funcionamento correto dos serviços.
  
  #### 3. **Wazuh**
  - Solução de monitoramento de segurança e detecção de intrusão.
  - Protege o ambiente contra ameaças, fornecendo análise contínua e alertas sobre possíveis riscos.
  
  #### 4. **FastAPI**
  - Serviço de backend que fornece uma API para comunicação com usuários e sistemas externos.
  - Projetado para alta performance e escalabilidade.
  
  #### Conexão e Segurança
  
  Todos os serviços mencionados são acessíveis dentro da sub-rede, que utiliza o **Internet Gateway** para comunicação com a Internet de forma segura e eficiente.

- ## Sub-rede privada:

  Esta sub-rede é projetada para ser **isolada da Internet**, garantindo a proteção de dados sensíveis. Apenas os recursos internos têm acesso a ela, controlados por regras específicas.

  ### Serviços Implementados
  
  #### 1. **Banco de Dados**
  - Responsável pelo armazenamento seguro das informações.
  - Mantido na sub-rede privada para evitar exposição direta à Internet.
  - Protege os dados contra acessos não autorizados, garantindo confidencialidade e integridade.
  
  #### 2. **NAT Gateway**
  - Permite que os recursos privados realizem tarefas que exijam acesso à Internet, como atualizações de software ou envio de dados para serviços externos.
  - Mantém a segurança da sub-rede privada, evitando que ela fique diretamente exposta à Internet.
  
  #### Conexão e Segurança
  
  A configuração desta sub-rede prioriza o isolamento completo de acessos externos, garantindo que apenas recursos internos possam interagir com seus serviços. O uso do **NAT Gateway** assegura que o acesso à Internet seja controlado e seguro.

## Implementações:

### FastApi (Application):
- Link do repositório: https://github.com/LuccaHiratsuca/App-Web-Cyber

![WhatsApp Image 2024-11-25 at 09 13 48](https://github.com/user-attachments/assets/e24bb992-60c1-44c8-8223-a43a33989bec)

![WhatsApp Image 2024-11-25 at 09 13 49](https://github.com/user-attachments/assets/efbd2731-64a6-45fc-84d2-911eacc7955d)

### Zabbix:

- **URL de acesso**: [zabbix.abcplace.net.br/zabbix](http://zabbix.abcplace.net.br/zabbix)

![WhatsApp Image 2024-11-25 at 09 13 47](https://github.com/user-attachments/assets/66882596-e2e9-4aca-aed3-53f2841927d6)

![WhatsApp Image 2024-11-25 at 09 13 47 (1)](https://github.com/user-attachments/assets/9129b5ef-e40b-4c08-be62-a6182b0f8348)

### Wazuh:

- **URL de acesso**: [dashboard.abcplace.net.br](http://dashboard.abcplace.net.br)

![WhatsApp Image 2024-11-25 at 09 25 40](https://github.com/user-attachments/assets/cade249e-741a-4fd5-af5f-6e3b8a2e7fe8)

![WhatsApp Image 2024-11-25 at 09 25 40 (1)](https://github.com/user-attachments/assets/237708bd-e2f1-47da-ad77-233d724f09cf)

![WhatsApp Image 2024-11-25 at 09 25 41](https://github.com/user-attachments/assets/ebaf2164-d8b0-498e-a7d4-2552d9476242)


## Vídeo:



