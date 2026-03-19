import Foundation
import SwiftUI
import Services

struct TodoIconView: View {

    @State private var model = TodoIconViewModel()

    let checked: Bool
    let objectId: String?

    var body: some View {
        Button {
            guard let objectId else { return }
            model.updateDone(objectId: objectId, checked: !checked)
        } label: {
            Image(asset: checked ? .TaskLayout.done : .TaskLayout.empty)
                .resizable()
                .scaledToFit()
                .buttonDynamicForegroundStyle()
                .frame(maxWidth: 20, maxHeight: 20)
        }
        .buttonStyle(.plain)
    }
}

@MainActor
@Observable
private final class TodoIconViewModel {
    
    @Injected(\.objectActionsService) @ObservationIgnored
    private var objectActionsService: any ObjectActionsServiceProtocol
    
    func updateDone(objectId: String, checked: Bool) {
        Task {
            try await objectActionsService.updateBundledDetails(contextID: objectId, details: [.done(checked)])
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }
}
