import Foundation
import SwiftUI

@MainActor
struct PageNavigation {
    let push: (EditorScreenData) -> Void
    let pop: () -> Void
    let replace: (EditorScreenData) -> Void
}

extension EnvironmentValues {
    @Entry var pageNavigation = PageNavigation(push: { _ in }, pop: { }, replace: { _ in })
}
