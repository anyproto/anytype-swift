import Foundation
import SwiftUI
import Services

struct RelationsSearchCoordinatorView: View {
    
    @StateObject private var model: RelationsSearchCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: RelationsSearchData) {
        _model = StateObject(wrappedValue: RelationsSearchCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        // TODO: Migrate from NewSearchView
        NewSearchView(
            viewModel: NewSearchViewModel(
                searchPlaceholder: Loc.Relation.Search.View.placeholder,
                style: .default,
                itemCreationMode: .available(action: { name in
                    model.onShowCreateNewRelation(name: name)
                }),
                internalViewModel: RelationsSearchViewModel(
                    document: model.data.document,
                    excludedRelationsIds: model.data.excludedRelationsIds,
                    target: model.data.target,
                    interactor: RelationsSearchInteractor(
                        relationsInteractor: RelationsInteractor(objectId: model.data.document.objectId)
                    ),
                    onSelect: {
                        model.onSelectRelation($0)
                    }
                )
            )
        )
        .sheet(item: $model.newRelationData) {
            NewRelationCoordinatorView(
                data: $0,
                output: model
            )
            .mediumPresentationDetents()
        }
        .snackbar(toastBarData: $model.toastData)
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
}
