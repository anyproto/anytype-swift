import Foundation
import SwiftUI
import Services

struct SetPropertiesDetailsLocalSearchData: Identifiable, Equatable, Hashable {
    let relationsDetails: [PropertyDetails]
    @EquatableNoop
    var onSelect: (PropertyDetails) -> Void
    
    var id: Int { hashValue }
}

// TODO: Migrate from LegacySearchView
struct SetPropertiesDetailsLocalSearchView: View { //
    
    let data: SetPropertiesDetailsLocalSearchData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        LegacySearchView(
            viewModel: LegacySearchViewModel(
                searchPlaceholder: Loc.EditSet.Popup.Sort.Add.searchPlaceholder,
                style: .default,
                itemCreationMode: .unavailable,
                internalViewModel: SetSortsSearchViewModel(
                    interactor: SetPropertiesDetailsLocalSearchInteractor(relationsDetails: data.relationsDetails),
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
