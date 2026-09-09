# Mini App de Inspeção de Campo

Aplicativo Flutter desenvolvido como parte do desafio técnico para **Desenvolvedor Mobile Flutter**.

O projeto simula o fluxo de trabalho de um técnico em campo, permitindo consultar ordens de serviço, registrar inspeções com evidência fotográfica e localização, trabalhar offline e sincronizar os dados posteriormente com uma API.

## Funcionalidades

* Autenticação utilizando API mock
* Persistência segura do token
* Logout
* Listagem de ordens de serviço
* Estados de loading, vazio e erro
* Pull-to-refresh
* Cache local das ordens de serviço
* Consulta de detalhes da OS
* Formulário de inspeção
* Registro de observação
* Registro da condição encontrada
* Captura de foto pela câmera
* Seleção de imagem da galeria
* Captura da localização atual
* Salvamento de rascunho
* Persistência local das inspeções
* Fila de sincronização
* Sincronização manual
* Tentativa automática de sincronização ao recuperar conectividade
* Histórico de inspeções
* Filtro por status
* Retry de inspeções com falha
* Identificação visual do estado de sincronização

## Tecnologias

Principais tecnologias utilizadas:

* Flutter / Dart
* flutter_bloc
* Dio
* Drift
* SQLite
* flutter_secure_storage
* connectivity_plus
* image_picker
* geolocator
* uuid

## Arquitetura

O projeto utiliza uma arquitetura organizada por features, mantendo separadas as responsabilidades de interface, gerenciamento de estado e acesso a dados.

Fluxo principal:

```text
UI
 ↓
BLoC / Cubit
 ↓
Repository
 ↓
Data Source
 ↓
API / Banco local
```

Estrutura simplificada:

```text
lib/
├── app/
│   └── app.dart
│
├── core/
│   ├── database/
│   ├── network/
│   └── storage/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   └── presentation/
│   │
│   ├── work_orders/
│   │   ├── data/
│   │   └── presentation/
│   │
│   └── inspections/
│       ├── data/
│       └── presentation/
│
└── main.dart
```

### Gerenciamento de estado

Foi utilizado **BLoC/Cubit** para evitar que regras de negócio e chamadas de infraestrutura fiquem diretamente nas telas.

A interface dispara eventos e reage aos estados emitidos pelo BLoC.

## Persistência local

O banco local foi implementado utilizando **Drift**.

A escolha foi feita por oferecer:

* tipagem forte
* queries reativas
* integração com SQLite
* suporte a migrations
* boa separação entre persistência e regra de negócio

O banco armazena tanto as inspeções quanto um cache das ordens de serviço.

### Inspeções

Cada inspeção possui um `clientId` gerado no dispositivo.

Esse identificador é mantido durante todo o ciclo da inspeção e também é enviado à API durante a sincronização.

Estados possíveis:

```text
draft
pending
synced
failed
```

#### `draft`

Inspeção salva como rascunho.

Não entra na fila de sincronização.

#### `pending`

Inspeção concluída localmente e aguardando sincronização.

#### `synced`

Inspeção enviada com sucesso para a API.

#### `failed`

A API rejeitou a sincronização e uma mensagem de erro é armazenada para apresentação ao usuário.

## Estratégia offline-first

Uma das prioridades do projeto foi permitir que o técnico continue trabalhando mesmo sem acesso à API.

### Ordens de serviço

A busca utiliza estratégia **remote-first com fallback local**.

```text
GET /work-orders
       ↓
API disponível?
   ↓          ↓
  sim        não
   ↓          ↓
atualiza    busca
 cache      cache local
   ↓          ↓
 exibe       exibe
```

Quando uma resposta válida é obtida da API, as ordens são armazenadas localmente.

Caso uma consulta posterior falhe por indisponibilidade da rede, o aplicativo tenta utilizar os dados previamente armazenados.

Por isso, o primeiro carregamento das ordens ainda depende de uma consulta bem-sucedida à API.

## Fila de sincronização

Ao concluir uma inspeção, o aplicativo primeiro persiste os dados localmente com status:

```text
pending
```

Somente depois tenta enviar a inspeção para:

```http
POST /inspections
```

Isso evita perda dos dados caso o aplicativo seja fechado ou a conexão desapareça durante o envio.

Fluxo:

```text
Preenchimento
     ↓
Salvar localmente
     ↓
   pending
     ↓
Tentativa de sync
     ↓
 ┌───────────────┐
 │               │
sucesso        erro
 │               │
 ↓               ↓
synced      pending / failed
```

### Idempotência

O mesmo `clientId` é mantido durante novas tentativas de envio.

Dessa forma, retries não geram um novo identificador de inspeção no dispositivo e podem utilizar o mecanismo de idempotência disponibilizado pela API mock.

## Tratamento de falhas de sincronização

Falhas relacionadas a indisponibilidade temporária, como ausência de resposta do servidor, mantêm a inspeção na fila como `pending`.

Erros considerados definitivos são armazenados como `failed`, juntamente com uma mensagem legível.

Inspeções com status `failed` podem ser reenviadas manualmente através da tela de histórico.

## Sincronização automática

O aplicativo utiliza `connectivity_plus` para observar mudanças de conectividade.

Ao detectar que uma conexão voltou a estar disponível, o aplicativo tenta processar novamente as inspeções pendentes.

Também existe uma ação de sincronização manual disponível na tela de ordens de serviço.

> A existência de uma interface de rede não garante que a API esteja acessível. Por isso, a sincronização também trata falhas reais da requisição HTTP.

## Autenticação

O login é realizado utilizando:

```http
POST /auth/login
```

O token recebido é armazenado através de `flutter_secure_storage`.

As chamadas protegidas utilizam o token no header:

```http
Authorization: Bearer <token>
```

Também é possível realizar logout, removendo o token armazenado localmente.

## API mock

A API utilizada no desafio está disponível na pasta:

```text
mock-api/
```

### Pré-requisitos

* Flutter stable
* Android SDK
* Node.js 18 ou superior
* Emulador Android ou dispositivo físico

## Como executar

### 1. Clonar o projeto

```bash
git clone <https://github.com/lukasreei/mini-app-de-inspe-o-de-campo.git>
cd mini-app-de-inspe-o-de-campo
```

### 2. Instalar as dependências Flutter

```bash
flutter pub get
```

### 3. Subir a API mock

Em outro terminal:

```bash
cd mock-api
npm install
npm start
```

A API será iniciada em:

```text
http://localhost:3000
```

## Android Emulator

Para acessar o servidor da máquina host através do emulador Android é utilizado:

```text
http://10.0.2.2:3000
```

O aplicativo está configurado para utilizar esse endereço durante o desenvolvimento no Android Emulator.

## Dispositivo físico

Caso seja utilizado um dispositivo Android físico, o endereço da API precisa apontar para o IP da máquina na rede local.

Exemplo:

```text
http://192.168.0.10:3000
```

O computador e o dispositivo devem estar conectados à mesma rede.

## Executar o aplicativo

Com a API mock em execução:

```bash
flutter run
```

Ou escolha explicitamente um dispositivo:

```bash
flutter devices
flutter run -d <device-id>
```

## Credenciais de teste

| Perfil        | E-mail                   | Senha      |
| ------------- | ------------------------ | ---------- |
| Técnico       | `tecnico@orbytis.com.br` | `123456`   |
| Administrador | `admin@orbytis.com.br`   | `admin123` |

## Como testar o fluxo offline

Uma forma simples de validar o comportamento offline:

1. Inicie a API mock.
2. Faça login.
3. Abra a lista de ordens de serviço para gerar o cache local.
4. Abra uma ordem.
5. Desative a conexão do dispositivo/emulador.
6. Preencha a inspeção.
7. Adicione foto e localização.
8. Conclua a inspeção.
9. Verifique no histórico que ela permanece localmente como pendente.
10. Feche e abra novamente o aplicativo.
11. Confirme que os dados continuam disponíveis.
12. Restaure a conexão.
13. Utilize a sincronização manual ou aguarde a tentativa automática.
14. Confira a mudança para o status sincronizado.

## Histórico

A tela de histórico apresenta todas as inspeções locais e permite filtrar por:

* Todas
* Rascunhos
* Pendentes
* Sincronizadas
* Falhas

Inspeções que falharam também possuem a ação **Tentar novamente**.

## Decisões técnicas

### BLoC

Escolhido para manter regras de negócio fora da camada de UI e também por ser uma tecnologia alinhada ao escopo desejável do desafio.

### Drift

Escolhido para a persistência estruturada das inspeções e do cache de ordens de serviço, com suporte a tipagem, streams e migrations.

### Dio

Utilizado como cliente HTTP para centralizar comunicação com a API e tratamento de erros.

### Secure Storage

O token de autenticação não é salvo em armazenamento comum da aplicação. Foi utilizado `flutter_secure_storage`.

### UUID / clientId

O identificador é criado localmente e preservado durante as tentativas de sincronização para evitar duplicação causada por retries.

## Limitações conhecidas

* O endereço padrão da API está direcionado ao Android Emulator.
* Em dispositivo físico é necessário configurar o IP da máquina.
* O cache das ordens somente estará disponível após pelo menos uma consulta online bem-sucedida.
* A detecção de conectividade não garante que a API esteja acessível; a requisição HTTP continua sendo a fonte definitiva para determinar sucesso ou falha.
* A API mock mantém informações de autenticação em memória; reiniciar o servidor pode invalidar uma sessão já autenticada.
* O projeto não implementa os itens opcionais de formulário dinâmico, geofence, dark mode e CI.
* O projeto está focado em Android, conforme solicitado pelo desafio.

## Comandos úteis

Análise estática:

```bash
flutter analyze
```

Testes:

```bash
flutter test
```

Formatar o projeto:

```bash
dart format lib test
```

