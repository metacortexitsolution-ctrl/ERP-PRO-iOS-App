# SwiftUI iOS ERP Project Development Rules

## 1. Platform
- Build with **SwiftUI**.
- Support **iPhone**, **iPad**, and **Mac Catalyst**.
- Use **adaptive layouts**; never force the iPhone layout onto iPad or Mac.
- Follow native Apple navigation, touch targets, typography, spacing, and interaction patterns.

## 2. Architecture
- Use **feature-based MVC**.
- Every feature/module follows:
  ```
  ModuleName/
  ├── Models/
  ├── Views/
  └── Controllers/
  ```
- Do not create global `Models`, `Views`, or `Controllers` folders.
- Keep feature-specific code inside its own module.

## 3. Existing Project Structure
```
ERPPro/
├── App/
├── Core/
├── DesignSystem/
├── Modules/
│   ├── Administration/
│   ├── Compliance/
│   ├── CustCompany/
│   ├── Dashboard/
│   ├── Finance/
│   ├── Inventory/
│   ├── Invoiceing/
│   ├── Purchasing/
│   └── Reports/
└── Tests/
```

## 4. Networking
- Use one centralized `Core/Networking/APIManager.swift`.
- Never create feature-specific API managers.
- Never duplicate networking code.
- **API Flow:** View → Controller → APIManager → Backend.
- Request bodies must use `Codable` request objects/models.
- Do not invent API endpoints; follow the existing backend API contract.
- Keep authentication and security centralized.

## 5. Business Data
- Production screens display backend-provided data.
- Do not calculate or derive business metrics locally.
- Do not invent, estimate, or modify business values.
- Charts must visualize API-provided datasets.
- Static/demo data is allowed only when explicitly requested for UI development.

## 6. Shared Core
Reuse existing shared files:
- `Core/Common/`
- `Core/Constants/`
- `Core/Extensions/`
- `Core/Navigation/`
- `Core/Networking/`
- `Core/Storage/`
- `Core/Security/`
- `Core/Configuration/`

Use:
- `ConstantString.swift` for common/user-facing strings
- `CommonColor.swift` for shared colors
- `CommonFont.swift` for typography
- `CommonSpacing.swift` for spacing
- `CommonDateFormatter.swift` for dates
- `CommonCurrencyFormatter.swift` for currency
- `CommonValidation.swift` for validation
- `AppRoute.swift` for navigation routes

## 7. Strings
- Use `ConstantString.swift` for common/user-facing strings.
- Do not create duplicate feature string files.
- Do not duplicate the same string across modules.

## 8. Design System
- Reuse the existing `DesignSystem`.
- Do not create feature-specific design systems.
- Maintain consistent colors, typography, spacing, corner radius, buttons, cards, icons, and states.

## 9. Navigation
- Keep application-level navigation centralized.
- Use `NavigationStack` appropriately per major screen.
- Do not put the entire application's navigation logic inside one feature.
- Keep Home navigation clean and native.

## 10. Home Screen
- Use native navigation title: **Home**.
- **Company action:** separate icon-only circular button on the left.
- **Profile action:** separate icon-only circular button on the right.
- Do not combine Company and Profile into one pill.
- Do not add unnecessary navigation-bar buttons.
- No Refresh button unless explicitly requested.

## 11. Responsive UI
### iPhone
- Optimize for small screens.
- Avoid excessive vertical scrolling.
- Use horizontal scrolling/paging where appropriate.
- KPI cards may use a 2 × 2 layout per horizontal page.
### iPad
- Prefer multi-column layouts.
- Show all 8 Home KPI cards as a 4 × 2 grid when space allows.
- Avoid unnecessary scrolling when the available screen can display the content.
### Mac Catalyst
- Use available width effectively.
- Prefer wider multi-column layouts.
- Do not make the UI look like a stretched iPhone application.
- Support mouse/trackpad interaction and native toolbar behavior.

## 12. KPI Cards
- Cards in the same grid must have equal width and height.
- Maintain consistent spacing and alignment.
- Use compact visual hierarchy.
- Avoid unnecessary section titles.
- Use sparklines/charts only when useful.
- Do not stretch cards unnecessarily on large screens.

## 13. Charts
- Use **Swift Charts** where appropriate.
- Charts must be readable on iPhone, iPad, and Mac.
- Use horizontal paging when multiple charts would create excessive vertical scrolling.
- Context menus may be used for switching between related chart views.
- Never calculate business metrics locally just to populate a chart.

## 14. Files
- **Strict rule:** do not create unnecessary files.
- Check whether an existing file can be reused first.
- Create a new file only when genuinely required by the architecture.
- Do not create unnecessary Helpers, Utils, Managers, Services, Repositories, DTOs, Mock files, Preview files, API managers, Extensions, or design-system files.

## 15. Code Quality
- No duplicate code.
- No unused imports.
- No unused properties.
- No dead code.
- No temporary debugging code.
- **Controllers** handle screen/business orchestration.
- **Views** handle presentation.
- **Models** handle data representation.

## 16. UI States
Where applicable, support:
- Loading
- Loaded
- Empty
- Error
Reuse existing common components instead of creating separate state files for every feature.

## 17. Performance
- Use Swift concurrency appropriately.
- Avoid unnecessary API requests.
- Cancel obsolete requests when appropriate.
- Use `LazyVStack`, `LazyHStack`, and efficient grids for large content.
- Avoid blocking the main thread.
- Keep charts and scrolling smooth.

## 18. Security
- Never store authentication tokens or secrets in plain `UserDefaults`.
- Use the existing security/storage architecture.
- Never hard-code credentials, API keys, or secrets.

## 19. Testing
Maintain:
```
Tests/
├── UnitTests/
├── IntegrationTests/
└── UITests/
```
Test important controllers, API handling, navigation, responsive layouts, and critical user flows.

## 20. Most Important Rule
**Do exactly what is requested — nothing extra.**
Do not:
- Invent functionality.
- Invent backend APIs.
- Invent business calculations.
- Add unnecessary files.
- Add unnecessary UI.
- Refactor unrelated code.
- Change existing architecture without approval.
- Replace existing components unnecessarily.

Always inspect the existing project structure and code first, then make the smallest clean change required.
