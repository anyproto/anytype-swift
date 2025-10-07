import Foundation
import SwiftUI

struct LaunchView: View {
    
    @State private var showPrivateDebugMenu = false
    @State private var showPublicDebugMenu = false

    var body: some View {
        ZStack {
            Color.Background.primary
                .onTapGesture(count: 10) {
                    showPrivateDebugMenu.toggle()
                }
                .ignoresSafeArea()
            
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
                .zStackPosition(.center)
                .ignoresSafeArea()
            
            HStack(spacing: 8) {
                IconView(asset: .X18.lockWithTick)
                // Do not localize
                Text("encrypted, local, yours forever")
                    .anytypeStyle(.previewTitle2Medium)
                    .foregroundStyle(Color.Text.secondary)
            }
            .zStackPosition(.bottom)
            .padding(.bottom, 26)
        }
    }
}

#Preview {
    LaunchView()
}
