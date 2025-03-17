import SwiftUI
import Services
import AnytypeCore


@MainActor
final class RelationCreationViewModel: ObservableObject {
    
    private let data: RelationsSearchData
    
    @Published var rows: [SearchDataSection<ObjectSearchData>] = []

    
    init(data: RelationsSearchData) {
        self.data = data
    }
    
    func setupSubscriptions() async {
        async let subscription: () = subscribe()
        
        (_) = await (subscription)
    }
    
    // MARK: - Private
    private func subscribe() async {
        
    }
}
