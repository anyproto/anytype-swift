import Foundation
import SwiftUI
import PulseUI

public final class LoggerUI {
    
    public static func makeView() -> some View {
        NavigationView {
            ConsoleView()
        }.navigationViewStyle(.stack)
    }
}
