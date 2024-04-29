import Foundation
import SwiftUI
import Services

struct SetRelationsDetailsLocalSearchData: Identifiable, Equatable, Hashable {
    let relationsDetails: [RelationDetails]
    @EquatableNoop
    var onSelect: (RelationDetails) -> Void
    
    var id: Int { hashValue }
}

// TODO: Migrate from NewSearchView
struct SetRelationsDetailsLocalSearchView: View { //
    
    let data: SetRelationsDetailsLocalSearchData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NewSearchView(
            viewModel: NewSearchViewModel(
                searchPlaceholder: Loc.EditSet.Popup.Sort.Add.searchPlaceholder,
                style: .default,
                itemCreationMode: .unavailable,
                internalViewModel: SetSortsSearchViewModel(
                    interactor: SetRelationsDetailsLocalSearchInteractor(relationsDetails: data.relationsDetails),
                    onSelect: { details in
                        guard let result = details.first else { return }
                        data.onSelect(result)
                        dismiss()
                    }
                )
            )
        )
    }
}
