import Foundation
import SwiftUI

@MainActor
struct PageNavigation {
    let push: (EditorScreenData) -> Void
    let pop: () -> Void
    let replace: (EditorScreenData) -> Void
}

struct PageNavigationEnvironmentKey: EnvironmentKey {
    static let defaultValue: PageNavigation = PageNavigation(push: { _ in }, pop: { }, replace: { _ in })
}

extension EnvironmentValues {
    var pageNavigation: PageNavigation {
        get { self[PageNavigationEnvironmentKey.self] }
        set { self[PageNavigationEnvironmentKey.self] = newValue }
    }
}
