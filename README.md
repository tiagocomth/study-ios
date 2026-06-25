# Study

> Aplicativo iOS (SwiftUI) construído com arquitetura **MVVM-C** (MVVM + Coordinators), camadas de **Worker** e **Service**, organizado em uma estrutura de pastas **Core + Features**.

---

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Arquitetura](#-arquitetura)
- [Camadas](#-camadas)
- [Navegação](#-navegação)
- [Camada de Rede (Network)](#-camada-de-rede-network)
- [Sessão e Segurança](#-sessão-e-segurança)
- [Estrutura de Pastas](#-estrutura-de-pastas)
- [Como Rodar o Projeto](#-como-rodar-o-projeto)
- [Testes](#-testes)
- [Como Criar um Novo Flow](#-como-criar-um-novo-flow)
- [Decisões Técnicas](#-decisões-técnicas)
- [Convenções](#-convenções)

---

## 🎯 Visão Geral

Este projeto segue o padrão **MVVM-C** com camadas adicionais de **Worker** e **Service**, garantindo separação clara de responsabilidades, código testável e features isoladas.

Cada **flow de telas** é autocontido: possui seu próprio **Coordinator** (navegação), sua própria **Factory** (criação de Views e ViewModels) e, quando precisa de navegação, um **Router** (enum de rotas). Esses três tipos de infraestrutura ficam juntos numa pasta `Infra/` dentro da feature. Um flow pode agrupar várias telas relacionadas — por exemplo, o flow de **Autenticação** reúne Login, Recuperação de Senha, Código e Nova Senha.

---

## 🏗️ Arquitetura

```
StudyApp  (@main)
      │
      ▼
  AppWorker  ───────► Composition root: cria e injeta UserSessionService + APIClient
      │
      ▼
AppCoordinator + AppFactory  ─► Decide e cria o primeiro flow
      │
      ▼
  Coordinator  ──────► Navegação entre as telas de um flow (NavigationController)
      │
      ▼
   Factory  ─────────► Cria as Views e injeta os ViewModels (com weak coordinator)
      │
      ▼
┌──────────────────────────────────────────────────────────────┐
│   View  ◄──►  ViewModel  ◄──►  Worker  ◄──►  Service / Helper  │
│   (UI)        (Dados/UI)      (Ações)      (Baixo nível)       │
└──────────────────────────────────────────────────────────────┘
```

### Composition root (`AppWorker`)

O `AppWorker` é instanciado uma vez em `StudyApp` (`@State var appWorker = AppWorker()`). Ele é dono das dependências globais e as injeta para baixo:

- **`UserSessionService`** — fonte única de verdade do usuário logado.
- **`APIClient`** — único cliente de rede configurado, que lê o token atual da sessão a cada request (via `TokenProvider`).
- Configura o **`AuthenticationInterceptor`** para fazer **logout automático** sempre que um request retornar `401`.

### Fluxo de exemplo (Login)

```
LoginView
   └─► LoginViewModel.login()
         └─► LoginWorker.login()
               └─► LoginService.login() ─► Result ─► UserSessionService / Keychain
```

### Exemplo de flow agrupando várias telas (AuthCoordinator)

```
AuthCoordinator (Infra)  +  AuthFactory (Infra)  +  AuthRouter (Infra)
   ├── Login            (LoginView / LoginViewModel / LoginWorker / LoginService)
   ├── ForgetPassword   (ForgetPasswordView / ...ViewModel / ...Worker / ...Service)
   ├── Code             (CodeView / CodeViewModel / CodeWorker / CodeService)
   └── NewPassword      (NewPasswordView / ...ViewModel / ...Worker / ...Service)
```

---

## 🧱 Camadas

| Camada | Responsabilidade |
|--------|------------------|
| **StudyApp** | Ponto de entrada do app (`@main`). Cria o `AppWorker` e apresenta o primeiro flow via `CoordinateView`. |
| **AppWorker** | Composition root. Cria e injeta as dependências globais (`UserSessionService`, `APIClient`) e configura o logout automático em `401`. |
| **AppCoordinator / AppFactory** | Decidem e criam o primeiro flow (ex.: `AuthCoordinator`). |
| **Coordinator** | Controla a navegação entre as telas de um flow. Conforma ao protocolo `Coordinator` e aos `*CoordinatorProtocol` de cada tela. |
| **Factory** | Cria as Views e instancia/gerencia o ciclo de vida dos ViewModels do flow, injetando o `weak coordinator`. |
| **Router** | `enum` (`Hashable & Identifiable`) com as rotas possíveis do flow (ex.: `AuthRouter`). |
| **View** | Camada de UI pura, sem lógica de negócio nem navegação. |
| **ViewModel** | Prepara os dados para a UI e solicita navegação ao Coordinator (via `weak var coordinator`). |
| **Worker** | Executa ações do usuário, orquestrando Services e Helpers. |
| **Service** | Operações de baixo nível (autenticação, sessão, Keychain, timer, StoreKit, etc.). |
| **Helper / Util** | Generalizações e utilitários compartilhados (loggers, chaves, extensões). |

---

## 🧭 Navegação

A navegação é baseada em **Coordinators** sobre um pequeno framework próprio em `Core/Navigation`:

- **`Coordinator`** (protocolo) — define `rootView`, `coordinate(to:)` e um `NavigationController`.
- **`NavigationController`** (`@Observable`, `@MainActor`) — encapsula um `NavigationPath` (push/pop/popToRoot) e um `SheetPath` (apresentar/dispensar sheets).
- **`CoordinateView`** — `View` genérica que monta o `NavigationStack`, conecta os `navigationDestination` / `sheetDestination` ao `coordinate(to:)` do coordinator e aplica o modificador de sheet.
- **`SheetNavigation/`** — `SheetPath`, `SheetModifier` e `SheetFactoryKey` para apresentação de sheets dirigida por rota.

Hierarquia:

- O **`AppWorker` + `AppCoordinator`** decidem qual flow iniciar.
- Cada **flow** possui seu próprio **Coordinator**, **Factory** e **Router** (em `Infra/`).
- O **Coordinator** conforma aos protocolos por-tela (ex.: `LoginCoordinatorProtocol`), expondo só os métodos de navegação que cada ViewModel precisa conhecer.

Quando uma tela precisa navegar:

```
View ─► ViewModel (weak var coordinator: SomeCoordinatorProtocol)
        └─► Coordinator.navigateToX()  ─►  NavigationController.push(router:)
              └─► CoordinateView resolve a rota em coordinate(to:) ─► Factory cria a próxima View
```

> O `ViewModel` mantém referência **`weak`** ao Coordinator (tipado por um `*CoordinatorProtocol`) para evitar retain cycles e acoplamento. A `View` nunca conhece a navegação diretamente.

---

## 🌐 Camada de Rede (Network)

A pasta `Core/Network` concentra todo o networking, isolado das features:

```
Core/Network/
├── Client/
│   ├── APIClient.swift       # APIClientProtocol + implementação async/await
│   └── RequestBuilder.swift  # Monta URLRequest a partir de um Endpoint (+ token)
├── Endpoint/
│   ├── Endpoint.swift        # Protocolo: baseURL, path, method, task, headers
│   ├── HTTPMethod.swift
│   └── HTTPTask.swift        # plain / com parâmetros (body, query)
├── Auth/
│   ├── AuthenticationInterceptor.swift  # Reage a 401 (callback configurável)
│   └── TokenProviding.swift             # Fornece o bearer token por request
├── Logging/
│   └── NetworkLogger.swift   # Loga request / response / falha (os.Logger)
└── Models/
    ├── NetworkError.swift    # Erros tipados (unauthorized, notFound, decoding…)
    └── EmptyResponse.swift   # Para respostas sem corpo (204 / DELETE)
```

Pontos-chave:

- **`APIClient`** expõe `request<T: Decodable>(_ endpoint:) async throws -> T`. Injetável: recebe `URLSession`, `TokenProviding`, `AuthenticationInterceptorProtocol` e `NetworkLogging` (todos com defaults), o que o torna fácil de testar.
- **Detecção vs. reação a 401:** a camada de rede apenas *detecta* o `401` e notifica o `AuthenticationInterceptor`; a *reação* (logout + voltar ao login) é configurada pelo app no `AppWorker`. Assim `Core/Network` não depende da feature de sessão.
- **Token por request:** o `APIClient` lê o token atual via `TokenProvider { session.token }`, sem armazenar estado de sessão.

---

## 🔐 Sessão e Segurança

- **`UserSessionService`** (`@MainActor`, `ObservableObject`) — fonte única de verdade do usuário logado. Expõe `restore() / startSession() / update() / logout()` e o `token` (leitura `nonisolated` para o `TokenProvider`). Há também o protocolo `UserSessionProtocol` para call sites testáveis.
- **`KeychainService`** (em `Features/Auth/Infra`) — abstração sobre o Keychain (protocolo `KeychainServicing`), guardando token e usuário codificados em JSON. Usado pela sessão.
- **Logout automático:** configurado no `AppWorker` — qualquer `401` dispara `session.logout()` no main actor.

---

## 📁 Estrutura de Pastas

Inspirada na organização **Core + Features** ([referência](https://medium.com/swiftblade/tidy-up-your-xcode-folders-cde1ac3aff7d)).

```
Study/
├── App/
│   └── StudyApp.swift              # @main
├── Core/
│   ├── AppWorker/
│   │   ├── AppWorker.swift         # Composition root
│   │   ├── AppCoordinator.swift
│   │   └── AppFactory.swift
│   ├── Navigation/
│   │   ├── Coordinator.swift       # Protocolo Coordinator
│   │   ├── NavigationController.swift
│   │   ├── CoordinateView.swift
│   │   ├── NavigationFactory.swift
│   │   └── SheetNavigation/        # SheetPath, SheetModifier, SheetFactoryKey
│   ├── Network/                    # Client, Endpoint, Auth, Logging, Models
│   ├── Services/                   # UserSessionService, StoreKitService, SocialShareService,
│   │   │                           #   CreateLinkService, OperationQueueService
│   │   └── Protocol/               # PaymentProtocol, …
│   ├── Entities/                   # User, Group
│   ├── Extensions/
│   ├── Constants/
│   └── Utils/                      # Loggers, AppKeys
│
└── Features/
    ├── Auth/
    │   ├── Infra/                  # AuthCoordinator, AuthFactory, AuthRouter, KeychainService
    │   ├── Login/                  # View / ViewModel / Worker / Service / CoordinatorProtocol
    │   ├── Register/
    │   ├── EmailValidation/
    │   ├── Code/
    │   └── ForgetPassword/
    │       ├── ForgetPassword/
    │       └── NewPassword/
    ├── Groups/
    │   ├── Infra/Coordinator/      # GroupCoordinator
    │   ├── Infra/Factory/          # GroupFactory
    │   ├── MyGroups/
    │   ├── ExploreGroups/
    │   ├── CreateGroup/
    │   ├── JoinGroup/
    │   ├── GroupDetails/  (+ Sheets/)
    │   └── GroupConfig/   (+ Sheets/)
    ├── StudySession/
    │   ├── Infra/Coordinator/ · Infra/Factory/
    │   ├── Services/               # TimerService, BlockService
    │   └── StudySession/
    ├── Metrics/
    │   ├── Infra/Coordinator/ · Infra/Factory/
    │   └── Metrics/
    └── Profile/
        ├── Infra/Coordinator/ · Infra/Factory/
        └── Profile/
```

### Core

Componentes **compartilhados** que não pertencem a uma feature específica: composition root (`AppWorker`), framework de navegação, camada de rede, services globais, entidades e utilitários.

### Features

Cada subpasta é uma **feature/flow autocontido**. A infraestrutura de navegação do flow (`Coordinator`, `Factory`, `Router`) fica em `Infra/`, e cada tela segue a tríade **View → ViewModel → Worker → Service**.

---

## 🚀 Como Rodar o Projeto

### Requisitos

- **Xcode:** 16 ou superior
- **iOS mínimo:** 17.6
- **Swift:** 5
- **Gerenciador de dependências:** Swift Package Manager (sem dependências externas — usa apenas frameworks da Apple: SwiftUI, Security/Keychain, StoreKit)

### Passos

```bash
# 1. Clone o repositório
git clone <url-do-repositorio>
cd Study

# 2. Crie a configuração local a partir do template versionado
#    e preencha o host real da API (API_BASE_URL).
cp Study/Core/Constants/Config.xcconfig.example Study/Core/Constants/Config.xcconfig

# 3. Abra o projeto
open Study.xcodeproj

# 4. Selecione o scheme "Study" e rode (⌘R)
```

> **Config local:** o host da API vem de `Study/Core/Constants/Config.xcconfig`
> (não versionado — ver `.gitignore`). Use o `Config.xcconfig.example` como
> base. O valor é injetado no `Info.plist` via `$(API_BASE_URL)` e lido em
> `APIConstants.host`.

---

## 🧪 Testes

Os testes ficam em `StudyTests/` e cobrem hoje a camada de rede:

```
StudyTests/
├── Network/
│   ├── APIClientTests.swift
│   └── RequestBuilderTests.swift
└── Support/
    ├── MockURLProtocol.swift   # Intercepta requests para respostas determinísticas
    └── TestDoubles.swift       # Fakes de TokenProviding, interceptor, logger, etc.
```

Rode com **⌘U** no Xcode (ou `xcodebuild test -scheme Study`). O `APIClient` foi desenhado para injeção de dependências (`URLSession`, token provider, interceptor e logger), permitindo testar sem rede real via `MockURLProtocol`.

---

## 🆕 Como Criar um Novo Flow

1. **Crie a pasta** da feature dentro de `Features/` (ex.: `Profile/`).
2. **Crie a infra** em `Infra/`:
   - `ProfileCoordinator.swift` — conforma a `Coordinator`, expõe `rootView` e `coordinate(to:)`.
   - `ProfileFactory.swift` — cria as Views/ViewModels e injeta o `weak coordinator`.
   - `ProfileRouter.swift` — `enum` (`Hashable & Identifiable`) com as rotas do flow.
3. Para cada tela, crie a tríade:
   - **View** (`ProfileView.swift`) — apenas UI.
   - **ViewModel** (`ProfileViewModel.swift`) — dados, lógica de apresentação e `weak var coordinator: ProfileCoordinatorProtocol`.
   - **Worker** (`ProfileWorker.swift`) — ações que exigem Services.
   - **Service** (`ProfileService.swift`) — operações de baixo nível, se necessário.
   - **CoordinatorProtocol** (`ProfileCoordinatorProtocol.swift`) — métodos de navegação que a tela precisa.
4. **Faça o Coordinator conformar** aos `*CoordinatorProtocol` das telas e implementar os métodos de navegação (`push`/`pop`/`presentSheet`).
5. **Conecte o novo Coordinator** ao Coordinator/Factory pai (ou ao `AppCoordinator`).

> Regra de ouro: a `View` nunca chama Services diretamente nem conhece navegação — tudo passa pelo `ViewModel` → `Worker` / `Coordinator`.

---

## 🔐 Decisões Técnicas

- **Composition root (`AppWorker`):** dependências globais são criadas num único lugar e injetadas para baixo, em vez de cada service criar a sua. Facilita testes e evita singletons espalhados.
- **Networking isolado:** `Core/Network` não conhece a feature de sessão. Ele só *detecta* `401` e avisa o `AuthenticationInterceptor`; quem decide deslogar é o app.
- **Token por request:** o `APIClient` lê o token atual da sessão a cada chamada (closure `TokenProvider`), sem manter estado próprio de autenticação.
- **Keychain para dados sensíveis:** token e usuário são guardados via `KeychainService` (Keychain), não em UserDefaults.
- **Navegação própria com Coordinators:** `NavigationController` (`@Observable`) encapsula `NavigationPath` + `SheetPath`, e `CoordinateView` conecta tudo ao `NavigationStack` de forma genérica.
- **Comunicação ViewModel → Coordinator:** via `weak var coordinator` tipado por um `*CoordinatorProtocol`, evitando retain cycles e expondo só o necessário.
- **Concorrência:** uso de `async/await`, `@MainActor` e `@Observable` (Swift Concurrency / Observation).
- **Workers vs Services:** Workers orquestram a lógica de uma ação; Services encapsulam operações de baixo nível reutilizáveis.

> Algumas features (Groups, StudySession, Metrics, Profile) e services (StoreKit, SocialShare, CreateLink, OperationQueue, Timer, Block) já têm a estrutura criada com `// TODO`, aguardando implementação.

---

## 📐 Convenções

- **Nomenclatura:** arquivos e tipos nomeados por `Feature + Camada` (ex.: `LoginViewModel`, `LoginWorker`, `LoginService`).
- **Pastas:** mantenha o conjunto fixo de pastas por feature; infraestrutura de navegação fica sempre em `Infra/`.
- **Commits:** Conventional Commits (`feat`, `fix`, `refactor`, `test`, `chore`, …).
- **Branch strategy:** branches por feature (ex.: `feature/network`).
</content>
</invoke>
