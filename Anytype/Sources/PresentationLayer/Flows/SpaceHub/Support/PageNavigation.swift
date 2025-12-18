import Foundation
import SwiftUI

struct PageNavigation {
    let open: (ScreenData) -> Void
    let pushHome: () -> Void
    let pop: () -> Void
    let popToFirstInSpace: () -> Void
    let openWidgets: () -> Void
    let replace: (EditorScreenData) -> Void
}

extension EnvironmentValues {
    @Entry var pageNavigation = PageNavigation(open: { _ in }, pushHome: { }, pop: { }, popToFirstInSpace: {}, openWidgets: {}, replace: { _ in })
}

extension View {
    func pageNavigation(_ navigation: PageNavigation) -> some View {
        environment(\.pageNavigation, navigation)
    }
}
