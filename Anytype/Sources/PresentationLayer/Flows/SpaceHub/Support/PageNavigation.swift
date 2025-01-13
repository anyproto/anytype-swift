import Foundation
import SwiftUI

struct PageNavigation {
    let open: (ScreenData) -> Void
    let pushHome: () -> Void
    let pop: () -> Void
    let popToFirstInSpace: () -> Void
    let replace: (EditorScreenData) -> Void
}

extension EnvironmentValues {
    @Entry var pageNavigation = PageNavigation(open: { _ in }, pushHome: { }, pop: { }, popToFirstInSpace: {}, replace: { _ in })
}
