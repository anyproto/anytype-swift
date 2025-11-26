import SwiftUI
import Services

struct ExportStackGoroutinesViewModifier: ViewModifier {
    
    @State private var model = ExportStackGoroutinesViewModel()
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
        Task { shareUrlFile = try await model.exportStackGoroutinesZip() }
    }
}

@MainActor
@Observable
private final class ExportStackGoroutinesViewModel {
    
    @Injected(\.debugService) @ObservationIgnored
    private var debugService: any DebugServiceProtocol
    
    func exportStackGoroutinesZip() async throws -> URL {
        try await debugService.exportStackGoroutinesZip()
    }
}

extension View {
    func exportStackGoroutinesSheet(isPresented: Binding<Bool>) -> some View {
        modifier(ExportStackGoroutinesViewModifier(isPresented: isPresented))
    }
}
