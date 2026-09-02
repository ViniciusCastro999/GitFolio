# GitFolio

Um app iOS nativo, escrito em **Swift + SwiftUI**, para buscar desenvolvedores no GitHub, ver seus perfis e repositórios, e favoritá-los localmente. Feito como projeto de portfólio com foco em **Swift Concurrency (`async`/`await`)** usada de forma idiomática, não decorativa.

## 📱 Screenshots

<img width="300" height="652" alt="image" src="https://github.com/user-attachments/assets/c155ad0c-4d1e-4747-8e96-bb218b8f2c35" />
<img width="300" height="652" alt="image" src="https://github.com/user-attachments/assets/12c2d0f2-0feb-4ed3-8101-6a602580372b" />
<img width="300" height="652" alt="image" src="https://github.com/user-attachments/assets/7671260f-6139-4fd8-8c9c-cd5be64f730e" />
<img width="300" height="652" alt="image" src="https://github.com/user-attachments/assets/a350f815-79d5-42b7-bb5e-e1fe8eeeb1c4" />


## ✨ Funcionalidades

- Busca de usuários do GitHub com **debounce** (sem disparar uma request a cada tecla)
- Tela de detalhes que carrega **perfil + repositórios em paralelo**
- Cache de imagens de avatar em memória, thread-safe, com **coalescing** de requisições duplicadas
- Favoritar/desfavoritar perfis, persistidos localmente com **SwiftData**
- Cancelamento automático de requisições obsoletas (ex: usuário digita rápido, ou sai da tela)
- Testes unitários assíncronos, com mocks sem dependência de rede real

## 🧠 Onde o `async`/`await` aparece

| Onde | O que mostra |
|---|---|
| `NetworkService.fetch` | Chamada de rede básica com `URLSession.data(for:)` async |
| `GitHubService.fetchUserDetail` | `withThrowingTaskGroup` para buscar perfil e repositórios **em paralelo**, com cancelamento automático se um deles falhar |
| `ImageCache` (actor) | Isolamento de dados thread-safe sem locks manuais; `Task` em cache evita downloads duplicados da mesma imagem |
| `SearchViewModel` | Debounce implementado com `Task.sleep` cancelável — cada nova tecla cancela a busca anterior |
| `CachedAsyncImage` | `.task(id:)` para carregar imagem de forma assíncrona e reagir a mudanças de URL |
| `GitFolioTests` | `XCTestCase` com métodos `async throws`, incluindo teste do caminho de `TaskGroup` |

## 🏗️ Arquitetura

MVVM simples, com injeção de dependência via `Environment` do SwiftUI (nada de singletons globais):

```
Views          → SwiftUI, sem lógica de negócio
ViewModels     → @MainActor, @Observable, orquestram chamadas async
Services       → GitHubServiceProtocol (regra de negócio / composição de chamadas)
Networking     → NetworkServiceProtocol (abstração sobre URLSession)
Persistence    → SwiftData (@Model FavoriteUser)
```

Cada camada depende apenas de **protocolos** da camada abaixo, o que torna tudo testável com mocks (veja `MockNetworkService` e `StubGitHubService`).

## 📁 Estrutura do projeto

```
GitFolio/
├── project.yml              # definição do projeto Xcode (XcodeGen)
├── Sources/
│   ├── GitFolioApp.swift
│   ├── App/                 # DI via Environment
│   ├── Models/               # Codable / Sendable
│   ├── Networking/            # NetworkService + ImageCache (actor)
│   ├── Services/              # GitHubService (TaskGroup)
│   ├── Persistence/           # SwiftData
│   ├── ViewModels/            # @MainActor @Observable
│   └── Views/
└── Tests/
    └── GitFolioTests/
```

## 🚀 Como abrir o projeto

Este repositório não versiona o `.xcodeproj` (é gerado, não deveria estar no controle de versão). Duas formas de abrir:

### Opção 1 — XcodeGen (recomendado)

```bash
brew install xcodegen
cd GitFolio
xcodegen generate
open GitFolio.xcodeproj
```

### Opção 2 — Manual

1. Abra o Xcode → **File → New → Project → iOS App**
2. Nome: `GitFolio`, interface: **SwiftUI**, linguagem: **Swift**, marque **SwiftData**
3. Delete os arquivos padrão gerados (`ContentView.swift`, `Item.swift`)
4. Arraste a pasta `Sources` para dentro do projeto (marcando "Copy items if needed")
5. Adicione um novo target de testes unitários e arraste `Tests/GitFolioTests`
6. Defina o **Deployment Target** para iOS 17.0 (necessário para SwiftData e `@Observable`)
7. Rode com `Cmd+R`

## ✅ Requisitos

- Xcode 15.4+
- iOS 17.0+ (SDK)
- Sem dependências de terceiros (100% SDKs da Apple)

## 🧪 Rodando os testes

```
Cmd+U
```

ou via linha de comando:

```bash
xcodebuild test -scheme GitFolio -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 📡 API utilizada

[GitHub REST API v3](https://docs.github.com/en/rest) (pública, sem necessidade de autenticação para os endpoints de leitura usados aqui). Atenção: sem autenticação, o limite de requisições é baixo (60/hora por IP) — é esperado que a busca eventualmente retorne `APIError.rateLimited` em testes manuais intensos.

## 📄 Licença

MIT — veja [LICENSE](LICENSE).
