import SwiftUI
import Services


struct ExportStackGoroutinesViewModifier: ViewModifier {
    @Injected(\.debugService)
    private var debugService: any DebugServiceProtocol
    
    @State private var shareUrlFile: URL?
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .sheet(item: $shareUrlFile) { url in
                ActivityViewController(activityItems: [url], applicationActivities: nil)
            }
            .onChange(of: isPresented) { _, isPresented in
                guard isPresented else { return }
                exportStackGoroutines()
            }
    }
    
    private func exportStackGoroutines() {
        Task { shareUrlFile = try await debugService.exportStackGoroutinesZip() }
    }
}


extension View {
    func exportStackGoroutinesSheet(isPresented: Binding<Bool>) -> some View {
        modifier(ExportStackGoroutinesViewModifier(isPresented: isPresented))
    }
}
