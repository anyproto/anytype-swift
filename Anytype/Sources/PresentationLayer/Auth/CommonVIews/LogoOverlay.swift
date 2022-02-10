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
                        .onTapGesture {
                            titleTapCount += 1
                            if titleTapCount == 10 {
                                titleTapCount = 0
                                AudioServicesPlaySystemSound(1109)
                                showDebug = true
                            }
                        }
                    Spacer()
                }
                    .modifier(ReadabilityPadding(padding: 20)),
                alignment: .topLeading
            )
            .sheet(isPresented: $showDebug) {
                DebugMenu()
            }
    }
}
