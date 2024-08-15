import Foundation
import SwiftUI

private struct UpdateShortcutsModifier: ViewModifier {
    
    let spaceId: String?
    @StateObject private var model = UpdateShortcutsModifierObject()
    @Environment(\.scenePhase) var scenePhase
    
    func body(content: Content) -> some View {
        content.onChange(of: scenePhase) { new in
            if new == .background {
                model.updateShortcuts(spaceId: spaceId)
            }
        }
    }
}

@MainActor
private final class UpdateShortcutsModifierObject: ObservableObject {
    
    @Injected(\.quickActionShortcutBuilder)
    private var quickActionShortcutBuilder: QuickActionShortcutBuilderProtocol
    
    func updateShortcuts(spaceId: String?) {
        if let spaceId {
            UIApplication.shared.shortcutItems = quickActionShortcutBuilder.buildShortcutItems(spaceId: spaceId)
        } else {
            UIApplication.shared.shortcutItems = []
        }
    }
}

extension View {
    func updateShortcuts(spaceId: String?) -> some View {
        modifier(UpdateShortcutsModifier(spaceId: spaceId))
    }
}
