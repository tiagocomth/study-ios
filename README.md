# NomeDoApp

> Aplicativo iOS construído com arquitetura **MVVM-C** (MVVM + Coordinators), Workers e Services, organizado em uma estrutura de pastas **Core + Features**.

---

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Arquitetura](#-arquitetura)
- [Camadas](#-camadas)
- [Navegação](#-navegação)
- [Estrutura de Pastas](#-estrutura-de-pastas)
- [Como Rodar o Projeto](#-como-rodar-o-projeto)
- [Como Criar um Novo Flow](#-como-criar-um-novo-flow)
- [Decisões Técnicas](#-decisões-técnicas)
- [Convenções](#-convenções)

---

## 🎯 Visão Geral

Este projeto segue o padrão **MVVM-C** com camadas adicionais de **Worker** e **Service**, garantindo separação clara de responsabilidades, código testável e features isoladas.

Cada **flow de telas** é autocontido: possui seu próprio **Coordinator** (navegação) e sua própria **Factory** (criação de Views e ViewModels). Um flow pode agrupar várias telas relacionadas — por exemplo, o flow de **Autenticação** reúne Login, Register, Validação de E-mail e Recuperação de Senha.

---

## 🏗️ Arquitetura

```
AppCoordinator  (@Main, @State)
      │
      ▼
  Coordinator  ──────► Navegação entre as telas de um flow
      │
      ▼
   Factory  ─────────► Cria as Views e gerencia o ciclo de vida dos ViewModels
      │
      ▼
┌──────────────────────────────────────────────────────────────┐
│   View  ◄──►  ViewModel  ◄──►  Worker  ◄──►  Service / Helper  │
│   (UI)        (Dados/UI)      (Ações)      (Baixo nível)       │
└──────────────────────────────────────────────────────────────┘
```

### Fluxo de exemplo (Login)

```
LoginView
   └─► LoginViewModel.login()
         └─► LoginWorker.login { loginService, keychain }
               └─► LoginService.login() ─► Result ─► KeychainService
```

### Exemplo de flow agrupando várias telas (AuthCoordinator)

```
AuthCoordinator  +  AuthFactory
   ├── Login            (LoginView / LoginViewModel / LoginWorker / LoginService)
   ├── Register         (RegisterView / RegisterViewModel / RegisterWorker / RegisterService)
   ├── EmailValidation  (EmailValidationView / ...ViewModel / ...Worker / ...Service)
   └── ForgetPassword   (ForgetPassword → Code → NewPassword, cada um com sua tríade)
```

---

## 🧱 Camadas

| Camada | Responsabilidade |
|--------|------------------|
| **AppCoordinator** | Ponto de entrada do app (`@Main`). Gerencia o estado global e inicializa o primeiro flow. |
| **Coordinator** | Controla a navegação entre as telas de um flow específico. |
| **Factory** | Cria as Views e instancia/gerencia o ciclo de vida dos ViewModels do flow. |
| **View** | Camada de UI pura, sem lógica de negócio. |
| **ViewModel** | Prepara os dados para a UI e solicita navegação ao Coordinator (via `weak var coordinator`). |
| **Worker** | Executa ações do usuário, orquestrando Services e Helpers. |
| **Service** | Serviços de baixo nível (ex: autenticação, sessão de usuário, persistência em Keychain). |
| **Helper** | Generalização e utilitários compartilhados entre serviços. |

---

## 🧭 Navegação

A navegação é baseada em **Coordinators**, organizados de forma hierárquica:

- O **AppCoordinator** é a raiz e decide qual flow iniciar.
- Cada **flow de telas** possui seu próprio **Coordinator** filho (ex: `AuthCoordinator`).
- Cada flow possui também sua própria **Factory** (ex: `AuthFactory`), responsável por criar as telas daquele flow e gerenciar o ciclo de vida dos ViewModels.

Quando uma tela precisa navegar, o fluxo é:

```
View ─► ViewModel (weak var coordinator) ─► Coordinator ─► Factory cria a próxima View
```

> O `ViewModel` mantém uma referência **`weak`** ao Coordinator para evitar retain cycles. A `View` nunca conhece a navegação diretamente, mantendo o desacoplamento.

---

## 📁 Estrutura de Pastas

Inspirada na organização **Core + Features** ([referência](https://medium.com/swiftblade/tidy-up-your-xcode-folders-cde1ac3aff7d)).

```
NomeDoApp/
├── Core/
│   ├── AppCoordinator/
│   │   ├── AppCoordinator.swift
│   │   └── AppFactory.swift
│   ├── AppDelegate/
│   │   └── AppDelegate.swift
│   ├── Services/            # Services globais (KeychainService, UserSessionService, etc.)
│   ├── Helpers/             # Utilitários compartilhados
│   ├── Network/             # Camada de networking
│   ├── Extensions/
│   └── Constants/           # NotificationNames, URLs, chaves, etc.
│
└── Features/
    ├── Auth/
    │   ├── Coordinator/
    │   │   └── AuthCoordinator.swift
    │   ├── Factory/
    │   │   └── AuthFactory.swift
    │   ├── Login/
    │   │   ├── LoginView.swift
    │   │   ├── LoginViewModel.swift
    │   │   ├── LoginWorker.swift
    │   │   └── LoginService.swift
    │   ├── Register/
    │   │   ├── RegisterView.swift
    │   │   ├── RegisterViewModel.swift
    │   │   ├── RegisterWorker.swift
    │   │   └── RegisterService.swift
    │   ├── EmailValidation/
    │   │   └── ...
    │   └── ForgetPassword/
    │       ├── ForgetPassword/   (ForgetPasswordView / ...ViewModel / ...Worker / ...Service)
    │       ├── Code/             (CodeView / CodeViewModel / CodeWorker / CodeService)
    │       └── NewPassword/      (NewPasswordView / ...ViewModel / ...Worker / ...Service)
    │
    └── Groups/
        ├── Coordinator/
        ├── Factory/
        ├── ExploreGroups/        (ExploreGroupsView / ...Model / ...Worker / ...Service)
        └── JoinGroup/            (JoinGroupView / ...)
```

### Core

Guarda componentes **compartilhados** que não pertencem a uma feature específica, como `AppCoordinator`, `AppDelegate`, Services globais (`KeychainService`, `UserSessionService`), networking e constantes.

### Features

Cada subpasta é uma **feature/flow autocontido**, com seu próprio `Coordinator` e `Factory`. Um flow pode conter várias telas relacionadas, cada uma seguindo a tríade **View → ViewModel → Worker → Service**.

---

## 🚀 Como Rodar o Projeto

> Preencha conforme as configurações reais do projeto.

### Requisitos

- **Xcode:** `__.__` ou superior
- **iOS mínimo:** `__.__`
- **Swift:** `__.__`
- **Gerenciador de dependências:** `SPM / CocoaPods / Carthage`

### Passos

```bash
# 1. Clone o repositório
git clone https://github.com/usuario/nome-do-app.git
cd nome-do-app

# 2. Instale as dependências (se usar CocoaPods)
pod install

# 3. Abra o projeto
open NomeDoApp.xcworkspace   # ou .xcodeproj se usar SPM
```

### Configurações necessárias

- Variáveis de ambiente / arquivos de configuração: `___`
- Schemes disponíveis: `Debug`, `Release`, `___`

---

## 🆕 Como Criar um Novo Flow

Siga este passo a passo ao adicionar uma nova feature:

1. **Crie a pasta** da feature dentro de `Features/` (ex: `Profile/`).
2. **Crie o Coordinator** (`ProfileCoordinator.swift`) responsável pela navegação do flow.
3. **Crie a Factory** (`ProfileFactory.swift`) que instancia as Views e ViewModels.
4. **Crie a View** (`ProfileView.swift`) — apenas UI.
5. **Crie o ViewModel** (`ProfileViewModel.swift`) com os dados, a lógica de apresentação e um `weak var coordinator`.
6. **Crie o Worker** (`ProfileWorker.swift`) para as ações que exigem Services.
7. **Crie o Service** (`ProfileService.swift`) se a feature precisar de operações de baixo nível próprias.
8. **Conecte o novo Coordinator** ao Coordinator pai (ou ao AppCoordinator).

> Regra de ouro: a `View` nunca chama Services diretamente nem conhece navegação — tudo passa pelo `ViewModel` → `Worker` / `Coordinator`.

---

## 🔐 Decisões Técnicas

> Documente aqui o "porquê" das escolhas importantes.

- **Keychain para dados sensíveis:** tokens e credenciais são armazenados via `KeychainService` (Keychain) em vez de UserDefaults, por segurança.
- **Sessão de usuário:** gerenciada pelo `UserSessionService`, compartilhado entre os flows.
- **Comunicação ViewModel → Coordinator:** feita por `weak var coordinator` para evitar retain cycles.
- **Debounce:** usado em buscas reativas (ex: `ExploreGroups`) para reduzir chamadas desnecessárias.
- **Workers vs Services:** Workers orquestram a lógica de uma ação; Services encapsulam operações de baixo nível reutilizáveis.
- **Push Notifications:** `descreva como se encaixa na arquitetura`.

---

## 📐 Convenções

- **Nomenclatura:** arquivos e tipos nomeados por `Feature + Camada` (ex: `LoginViewModel`, `LoginWorker`, `LoginService`).
- **Pastas:** mantenha o conjunto fixo de pastas por feature; não crie pastas fora do padrão.
- **Branch strategy:** `Gitflow / trunk-based / ___`.
- **Commits:** `Conventional Commits / ___`.

---

## 📄 Licença

`Defina a licença do projeto (ex: MIT).`
