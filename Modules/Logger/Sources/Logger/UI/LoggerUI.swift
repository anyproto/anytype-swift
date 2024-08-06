import Foundation
import SwiftUI
import PulseUI

@MainActor
public final class LoggerUI {
    
    public static func makeView() -> some View {
        NavigationView {
            ConsoleView()
        }.navigationViewStyle(.stack)
    }
}
