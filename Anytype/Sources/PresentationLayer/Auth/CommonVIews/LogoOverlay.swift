import SwiftUI
import AudioToolbox

struct LogoOverlay: ViewModifier {
    @State private var showDebug = false
    @State private var titleTapCount = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Image.logo.padding(.leading, 20).padding(.top, 30)
                    .onTapGesture {
                        titleTapCount += 1
                        if titleTapCount == 10 {
                            titleTapCount = 0
                            AudioServicesPlaySystemSound(1109)
                            showDebug = true
                        }
                    },
                alignment: .topLeading
            )
            .sheet(isPresented: $showDebug) {
                FeatureFlagsView()
            }
    }
}
