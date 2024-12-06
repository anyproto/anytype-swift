import UIKit
import SwiftUI

enum AnytypeStatusBarStyle {
    case `default`
    case lightContent
    case darkContent
    
    func toKitStyle() -> UIStatusBarStyle {
        switch self {
        case .default:
            return .default
        case .lightContent:
            return .lightContent
        case .darkContent:
            return .darkContent
        }
    }
}


struct StatusBarStyleModifier: ViewModifier {
    
    private static var lastId: UUID?
    
    @State private var id = UUID()
    
    let style: AnytypeStatusBarStyle
    
    @available(*, deprecated) // Workround for disable deprecated API warning
    func body(content: Content) -> some View {
        content
            .onAppear {
                UIApplication.shared.statusBarStyle = style.toKitStyle()
                StatusBarStyleModifier.lastId = id
            }
            .onDisappear {
                // Reset only if any other view doesn't setup style
                if StatusBarStyleModifier.lastId == id {
                    UIApplication.shared.statusBarStyle = .default
                    StatusBarStyleModifier.lastId = nil
                }
            }
    }
}

extension View {
    func anytypeStatusBar(style: AnytypeStatusBarStyle) -> some View {
        self.modifier(StatusBarStyleModifier(style: style))
    }
}
