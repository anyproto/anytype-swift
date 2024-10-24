import Foundation
import SwiftUI

struct LaunchView: View {
    
    @State private var showPrivateDebugMenu = false
    @State private var showPublicDebugMenu = false

    var body: some View {
        ZStack {
            Color.black
                .onTapGesture(count: 10) {
                    showPrivateDebugMenu.toggle()
                }
            LaunchCircle()
                .onTapGesture(count: 5) {
                    showPublicDebugMenu.toggle()
                }
                .sheet(isPresented: $showPrivateDebugMenu) {
                    DebugMenuView()
                }
                .sheet(isPresented: $showPublicDebugMenu) {
                    PublicDebugMenuView()
                }
        }
        .ignoresSafeArea()
    }
}
