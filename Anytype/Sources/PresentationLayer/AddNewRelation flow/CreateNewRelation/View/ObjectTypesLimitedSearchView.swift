import Foundation
import SwiftUI
import Services

struct ObjectTypesLimitedSearchData: Identifiable, Equatable, Hashable {
    let title: String
    let spaceId: String
    let selectedObjectTypesIds: [String]
    @EquatableNoop
    var onSelect: (_ ids: [String]) -> Void
    
    var id: Int { hashValue }
}

// TODO: Migrate from LegacySearchView
struct ObjectTypesLimitedSearchView: View {
    
    let data: ObjectTypesLimitedSearchData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        LegacySearchView(
            viewModel: LegacySearchViewModel(
                title: data.title,
                style: .default,
                itemCreationMode: .unavailable,
                internalViewModel: MultiselectObjectTypesSearchViewModel(
                    selectedObjectTypeIds: data.selectedObjectTypesIds,
                    interactor: Legacy_ObjectTypeSearchInteractor(
                        spaceId: data.spaceId,
                        showBookmark: true,
                        showSetAndCollection: true,
                        showFiles: true
                    ),
                    onSelect: { ids in
                        dismiss()
                        data.onSelect(ids)
                    }
                )
            )
        )
    }
}
