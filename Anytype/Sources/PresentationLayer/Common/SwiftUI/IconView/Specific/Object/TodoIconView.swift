import Foundation
import SwiftUI
import Services

struct TodoIconView: View {
    
    private static let maxSide = 28.0
    
    @Injected(\.objectActionsService)
    private var objectActionsService: ObjectActionsServiceProtocol
    
    let checked: Bool
    let objectId: String?
    
    var body: some View {
        Image(asset: checked ? .TaskLayout.done : .TaskLayout.empty)
            .resizable()
            .scaledToFit()
            .buttonDynamicForegroundStyle()
            .frame(maxWidth: 28, maxHeight: 28)
            .onTapGesture {
                guard let objectId else { return }
                Task {
                    try await objectActionsService.updateBundledDetails(contextID: objectId, details: [.done(!checked)])
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                }
            }
    }
}
