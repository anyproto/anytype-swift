import SwiftUI

extension EnvironmentValues {
    @Entry var messageFlashId: Binding<String> = .constant("")
}

extension View {
    func messageFlashId(_ id: Binding<String>) -> some View {
        environment(\.messageFlashId, id)
    }
    
    func messageFlashBackground(id: String) -> some View {
        modifier(MessageFlashBackgroundModifier(id: id))
    }
}

fileprivate struct MessageFlashBackgroundModifier: ViewModifier {
    
    @Environment(\.messageFlashId) @Binding private var messageFlashId
    @State private var higlight: Bool = false
    
    let id: String
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                checkFlash()
            }
            .onChange(of: messageFlashId) { _ in
                checkFlash()
            }
            .background(higlight ? Color.Background.Chat.bubbleFlash : Color.clear)
    }
    
    private func checkFlash() {
        if messageFlashId == id {
            withAnimation(.default.delay(0.2)) {
                higlight = true
            }
            Task {
                try await Task.sleep(seconds: 0.6)
                messageFlashId = ""
            }
        } else if higlight {
            withAnimation(.default) {
                higlight = false
            }
        }
    }
}
