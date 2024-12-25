import Foundation
import SwiftUI

struct PageNavigation {
    let push: (EditorScreenData) -> Void
    let pushHome: () -> Void
    let pop: () -> Void
    let replace: (EditorScreenData) -> Void
}

extension EnvironmentValues {
    @Entry var pageNavigation = PageNavigation(push: { _ in }, pushHome: { }, pop: { }, replace: { _ in })
}
