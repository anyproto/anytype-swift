import SwiftUI
import AudioToolbox

struct LogoOverlay: ViewModifier {
    @State private var showDebug = false
    @State private var titleTapCount = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                HStack {
                    Image.logo
                        .onTapGesture(perform: onTap)
                    Spacer()
                }
                    .padding(.horizontal, 20)
                    .readabilityPadding()
                ,
                alignment: .topLeading
            )
            .sheet(isPresented: $showDebug) {
                DebugMenu()
            }
    }
    
    private func onTap() {
        titleTapCount += 1
        if titleTapCount == 10 {
            titleTapCount = 0
            AudioServicesPlaySystemSound(1109)
            showDebug = true
        }
    }
}
