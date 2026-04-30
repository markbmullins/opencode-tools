---
name: swift-ui
description: Build premium-quality macOS SwiftUI interfaces with strict architecture, design system consistency, and scalable patterns. Enforces separation of concerns, clean state management, theming, and native macOS interaction patterns. Use when generating UI code, designing app structure, or refining SwiftUI components for maintainability and polish.
---
# SKILL.md — Premium, Scalable SwiftUI macOS App (LLM-Optimized)

## PURPOSE

This document defines strict rules, patterns, and examples for building a **premium-quality macOS SwiftUI app** that is:

- Visually consistent
- Architecturally scalable
- Easy to extend
- High performance
- Never spaghetti

This is an execution spec, not guidance.

---

# 1. CORE PRINCIPLES

## 1.1 System Over Screens

Build:

- A design system
- A state system
- A composition system

Never build isolated UI.

---

## 1.2 Strict Separation of Concerns

| Layer     | Responsibility              |
| --------- | --------------------------- |
| View      | Rendering + interaction     |
| ViewModel | State + logic               |
| Service   | Side effects (API, storage) |
| Model     | Data structures             |

❌ Business logic in Views = forbidden

---

## 1.3 Small, Composable Units

- Views must be small
- Files must be short
- Components must be reusable

---

## 1.4 Consistency Over Creativity

- Same spacing
- Same typography
- Same patterns everywhere

---

# 2. PROJECT STRUCTURE (MANDATORY)

```swift
Features/
  Projects/
    ProjectListView.swift
    ProjectListViewModel.swift
    ProjectRow.swift

Core/
  DesignSystem/
  Services/
  Navigation/
  Extensions/
```

❌ Never organize by type (Views/, ViewModels/)

---

## 2.1 File Rules

Create a new file when:

- View > 120 lines
- Component is reusable
- Subview has its own logic

---

# 3. DECISION RULES (CRITICAL)

## 3.1 When to Create a ViewModel

Create a ViewModel if:

- Async work exists
- More than 2 pieces of state
- Data transformation is needed
- Logic is reused

Do NOT create one if:

- View is purely presentational

---

## 3.2 Property Wrapper Rules

| Use Case           | Wrapper         |
| ------------------ | --------------- |
| Local simple state | @State          |
| Pass state down    | @Binding        |
| Own ViewModel      | @StateObject    |
| Observe external   | @ObservedObject |

❌ Avoid @EnvironmentObject unless absolutely necessary

---

## 3.3 When to Split Views

Split when:

- Nested conditions appear
- Sections are visually distinct
- Reuse is possible

---

# 4. VIEW ARCHITECTURE

## 4.1 Views Are Dumb

Views:

- Render state
- Emit actions

They do NOT:

- Fetch data
- Transform data
- Contain logic

---

## 4.2 Standard View Pattern

```swift
struct ExampleView: View {
    @StateObject private var vm: ExampleViewModel

    var body: some View {
        content
            .onAppear { vm.onAppear() }
    }
}
```

---

## 4.3 Composition Pattern

```swift
var body: some View {
    VStack {
        HeaderView()
        ContentView()
        FooterView()
    }
}
```

---

## 4.4 Standard Screen State Pattern

```swift
Group {
    if vm.isLoading {
        LoadingView()
    } else if let error = vm.error {
        ErrorView(error: error)
    } else if vm.items.isEmpty {
        EmptyStateView()
    } else {
        List(vm.items) { item in
            RowView(item: item)
        }
    }
}
```

---

# 5. VIEWMODEL DESIGN

## 5.1 Responsibilities

- Own UI state
- Handle logic
- Call services

---

## 5.2 State Shape Pattern (STANDARD)

```swift
struct ViewState {
    var items: [Item] = []
    var isLoading = false
    var error: String?
}
```

---

## 5.3 Async Pattern

```swift
func onAppear() {
    Task {
        await load()
    }
}
```

---

## 5.4 Rules

- No SwiftUI import
- Minimal state
- Single source of truth

---

# 6. DESIGN SYSTEM (MANDATORY)

## 6.1 Tokens

```swift
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
}

enum Radius {
    static let sm: CGFloat = 6
    static let md: CGFloat = 10
}
```

---

## 6.2 No Magic Numbers

❌ `.padding(13)`
✅ `.padding(Spacing.md)`

---

## 6.3 Component Modifiers

```swift
extension View {
    func cardStyle() -> some View {
        self
            .padding(Spacing.md)
            .background(Color.secondary)
            .cornerRadius(Radius.md)
    }
}
```

---

## 6.4 Naming Patterns

- `SomethingView`
- `SomethingRow`
- `SomethingCard`
- `SomethingSection`
- `SomethingHeader`

---

# 7. THEMING SYSTEM

## 7.1 Theme Model

```swift
struct Theme {
    let background: Color
    let text: Color
    let accent: Color
}
```

---

## 7.2 Environment Usage

```swift
@Environment(\.theme) private var theme

Text("Hello")
    .foregroundColor(theme.text)
    .padding()
    .background(theme.background)
```

---

## 7.3 Rules

- No raw colors in views
- Use semantic colors only

---

# 8. NAVIGATION

## 8.1 Route Model

```swift
enum Route: Hashable {
    case detail(UUID)
    case settings
}
```

---

## 8.2 Navigation State

```swift
@State private var path: [Route] = []
```

---

## 8.3 Rules

- Navigation is state-driven
- No deep hardcoded navigation

---

# 9. INTERACTION RULES

## 9.1 Must Support

- Keyboard shortcuts
- Context menus
- Hover states
- Focus states

---

## 9.2 Motion

- Fast (150–250ms)
- Subtle
- Purposeful

---

# 10. LAYOUT

## 10.1 Adaptive UI

Must support:

- Small windows
- Large monitors

---

## 10.2 Behavior

- Collapse sidebars
- Avoid fixed sizes

---

# 11. PERFORMANCE

## 11.1 Rules

- No heavy logic in `body`
- Use Lazy stacks
- Minimize updates

---

## 11.2 RED FLAGS

- Computation in body
- ViewModel creation inside body
- Large non-lazy lists

---

# 12. ERROR / EMPTY STATES

Must include:

- Loading
- Empty
- Error

Each must:

- Be informative
- Provide next action

---

# 13. ACCESSIBILITY

Required:

- VoiceOver labels
- Keyboard navigation
- Focus handling

---

# 14. DEPENDENCY INJECTION

## 14.1 Rule

Never hardcode services

---

## 14.2 Example

```swift
init(service: DataService) {
    self.service = service
}
```

---

# 15. GOLDEN PATH EXAMPLE (REFERENCE)

```swift
struct ProjectListView: View {
    @StateObject private var vm: ProjectListViewModel
    @Environment(\.theme) private var theme

    var body: some View {
        Group {
            if vm.isLoading {
                ProgressView()
            } else if vm.projects.isEmpty {
                Text("No Projects")
            } else {
                List(vm.projects) { project in
                    ProjectRow(project: project)
                }
            }
        }
        .padding(Spacing.md)
        .background(theme.background)
        .onAppear { vm.onAppear() }
    }
}

final class ProjectListViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var isLoading = false

    private let service: ProjectService

    init(service: ProjectService) {
        self.service = service
    }

    func onAppear() {
        Task { await load() }
    }

    func load() async {
        isLoading = true
        projects = await service.fetch()
        isLoading = false
    }
}
```

---

# 16. PREVIEWS

Always include:

- Empty state
- Loaded state
- Error state

Use mock data.

---

# 17. TESTING

Test:

- ViewModels
- State transitions

Mock services always.

---

# 18. ANTI-PATTERNS (FORBIDDEN)

- Business logic in Views
- Massive Views (>150 lines)
- Global state abuse
- Hardcoded styles
- Copy-paste UI
- Async work in Views

---

# 19. SELF-CHECK BEFORE OUTPUT (MANDATORY)

Before producing code, verify:

- No business logic in View
- Uses design tokens (no magic numbers)
- Uses ViewModel when needed
- Handles loading/empty/error states
- Uses semantic colors / theme
- Files/components are split correctly
- No performance red flags

---

# 20. FINAL PRINCIPLE

A premium SwiftUI app is built on:

- Small components
- Clear state ownership
- Centralized design system
- Explicit dependencies
- Native macOS behavior

Violation of any rule will degrade quality.
