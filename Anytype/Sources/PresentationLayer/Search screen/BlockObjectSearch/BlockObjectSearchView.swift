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
    
    var body: some View {
        let interactor = BlockObjectsSearchInteractor(
            spaceId: data.spaceId,
            excludedObjectIds: data.excludedObjectIds,
            excludedLayouts: data.excludedLayouts
        )
        
        let viewModel = ObjectsSearchViewModel(
            selectionMode: .singleItem,
            interactor: interactor,
            onSelect: { details in
                guard let result = details.first else { return }
                dismiss()
                data.onSelect(result)
            }
        )
        
        return LegacySearchView(
            viewModel: LegacySearchViewModel(
                title: data.title,
                style: .default,
                itemCreationMode: .available { name in
                    Task {
                        let details = try await interactor.createObject(name: name)
                        viewModel.onSelect([details])
                    }
                },
                internalViewModel: viewModel
            )
        )
    }
}
