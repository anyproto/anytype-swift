import Foundation
import SwiftUI

struct PageNavigation {
    let open: (ScreenData) -> Void
    let pushHome: () -> Void
    let pop: () -> Void
    let popToFirstInSpace: () -> Void
    let replace: (EditorScreenData) -> Void
    // Opens the unified search overlay over the current screen - one owner
    // (the hub coordinator), reachable from any screen's search affordance
    var openSearch: () -> Void = { }
    // Same overlay, seeded with the space scope plus the chat's filter token
    var openChatSearch: (_ chatId: String) -> Void = { _ in }
    let replaceHome: (String, AnyHashable) -> Void
}

extension EnvironmentValues {
    @Entry var pageNavigation = PageNavigation(open: { _ in }, pushHome: { }, pop: { }, popToFirstInSpace: {}, replace: { _ in }, replaceHome: { _, _ in })
}

extension View {
    func pageNavigation(_ navigation: PageNavigation) -> some View {
        environment(\.pageNavigation, navigation)
    }
}
