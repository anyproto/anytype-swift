import Foundation
import Services

// Routing output for the My Favorites section on the widgets screen.
//
// Kept separate from `CommonWidgetModuleOutput` (which passes `ScreenData` directly) because
// My Favorites rows hand back an `ObjectDetails` — the coordinator layer bridges to
// `ScreenData` via `details.screenData()`. This matches the plan's Task 5 contract and keeps
// the widget self-contained from the navigation layer (IOS-5864).
@MainActor
protocol MyFavoritesModuleOutput: AnyObject {
    func onObjectSelected(details: ObjectDetails)
}
