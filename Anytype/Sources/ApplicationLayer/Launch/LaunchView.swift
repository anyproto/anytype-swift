import Foundation
import SwiftUI

struct LaunchView<DebugView: View>: View {
    
    @State private var showDebugMenu = false
    let onDebugMenuAction:() -> DebugView
    
    var body: some View {
        ZStack {
            Color.black
            Image(asset: .splashLogoWhite)
                .onTapGesture(count: 10) {
                    showDebugMenu.toggle()
                }
                .sheet(isPresented: $showDebugMenu) {
                    onDebugMenuAction()
                }
        }
        .ignoresSafeArea()
    }
}

struct LaunchView_Previews: PreviewProvider {
    
    static var previews: some View {
        LaunchView(onDebugMenuAction: { Color.red.eraseToAnyView() })
    }
}
