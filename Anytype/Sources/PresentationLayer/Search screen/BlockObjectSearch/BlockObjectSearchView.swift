import Foundation
import SwiftUI
import Services

struct BlockObjectSearchData: Identifiable, Equatable, Hashable {
    let title: String
    let spaceId: String
    let excludedObjectIds: [String]
    let excludedLayouts: [DetailsLayout]
    @EquatableNoop
    var onSelect: (_ details: ObjectDetails) -> Void
    
    var id: Int { hashValue }
}

struct BlockObjectSearchView: View {
    
    let data: BlockObjectSearchData
    @Environment(\.dismiss) private var dismiss
    
    private let interactor: BlockObjectsSearchInteractor
    
    init(data: BlockObjectSearchData) {
        self.data = data
        
        let interactor = BlockObjectsSearchInteractor(
            spaceId: data.spaceId,
            excludedObjectIds: data.excludedObjectIds,
            excludedLayouts: data.excludedLayouts
        )
        
        self.interactor = interactor
    }
    
    var body: some View {
        
        
        return LegacySearchView(
            viewModel: LegacySearchViewModel(
                title: data.title,
                style: .default,
                itemCreationMode: .available { name in
                    Task {
                        let details = try await interactor.createObject(name: name)
                        AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: .link)
                        onSelect(details: [details])
                    }
                },
                internalViewModel: ObjectsSearchViewModel(
                    selectionMode: .singleItem,
                    interactor: interactor,
                    onSelect: { onSelect(details: $0) }
                )
            )
        )
    }
    
    private func onSelect(details: [ObjectDetails]) {
        guard let result = details.first else { return }
        dismiss()
        data.onSelect(result)
    }
}
