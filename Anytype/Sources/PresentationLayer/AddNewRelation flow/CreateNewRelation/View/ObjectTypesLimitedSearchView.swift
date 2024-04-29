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

// TODO: Migrate from NewSearchView
struct ObjectTypesLimitedSearchView: View {
    
    let data: ObjectTypesLimitedSearchData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NewSearchView(
            viewModel: NewSearchViewModel(
                title: data.title,
                style: .default,
                itemCreationMode: .unavailable,
                internalViewModel: MultiselectObjectTypesSearchViewModel(
                    selectedObjectTypeIds: data.selectedObjectTypesIds,
                    interactor: Legacy_ObjectTypeSearchInteractor(
                        spaceId: data.spaceId,
                        showBookmark: true,
                        showSetAndCollection: false,
                        showFiles: false
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
