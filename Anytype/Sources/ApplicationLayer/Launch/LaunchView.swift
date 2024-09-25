import Foundation
import SwiftUI

struct LaunchView<DebugView: View>: View {
    
    @State private var showDebugMenu = false
    @State private var exportStackGoroutines = false
    let onDebugMenuAction:() -> DebugView

    var body: some View {
        ZStack {
            Color.black
                .onTapGesture(count: 10) {
                    showDebugMenu.toggle()
                }
            LaunchCircle()
                .onTapGesture(count: 5) {
                    exportStackGoroutines.toggle()
                }
                .sheet(isPresented: $showDebugMenu) {
                    onDebugMenuAction()
                }
                .exportStackGoroutinesSheet(isPresented: $exportStackGoroutines)
        }
        .ignoresSafeArea()
    }
}
