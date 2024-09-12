import Foundation
import Services

@MainActor
final class AllContentViewModel: ObservableObject {

    @Published var rows: [SearchObjectRowView.Model] = []
    @Published var state = AllContentState()
    
    @Injected(\.allContentSubscriptionService)
    private var allContentSubscriptionService: any AllContentSubscriptionServiceProtocol
    
    private let spaceId: String
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func onDisappear() {
        stopSubscription()
    }
    
    func onTypeChanged(_ type: AllContentType) {
        state.type = type
    }
    
    func restartSubscription() async {
        await allContentSubscriptionService.startSubscription(
            spaceId: spaceId,
            supportedLayouts: state.type.supportedLayouts
        ) { [weak self] details in
            self?.updateRows(with: details)
        }
    }
    
    private func stopSubscription() {
        Task {
            await allContentSubscriptionService.stopSubscription()
        }
    }
    
    private func updateRows(with details: [ObjectDetails]) {
        rows = details.map {
            SearchObjectRowView.Model(
                id: $0.id, 
                icon: $0.objectIconImage,
                title: $0.title,
                subtitle: $0.objectType.name,
                style: .default,
                isChecked: false
            )
        }
    }
}
