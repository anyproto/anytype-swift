import SwiftUI

struct NewRelationCoordinatorView: View {
    
    @StateObject private var model: NewRelationCoordinatorViewModel
    
    init(name: String, document: BaseDocumentProtocol, target: RelationsModuleTarget, output: NewRelationCoordinatorViewOutput?) {
        _model = StateObject(wrappedValue: NewRelationCoordinatorViewModel(name: name, document: document, target: target, output: output))
    }
    
    var body: some View {
        NewRelationView(
            name: model.name,
            document: model.document,
            target: model.target,
            output: model
        )
        .sheet(item: $model.relationFormatsData) {
            RelationFormatsListView(
                selectedFormat: $0.format,
                onFormatSelect: $0.onSelect
            )
        }
        .sheet(item: $model.newSearchData) {
            // TODO: Migrate from NewSearchView
            NewSearchView(
                viewModel: NewSearchViewModel(
                    title: Loc.limitObjectTypes,
                    style: .default,
                    itemCreationMode: .unavailable,
                    internalViewModel: MultiselectObjectTypesSearchViewModel(
                        selectedObjectTypeIds: $0.selectedObjectTypesIds,
                        interactor: Legacy_ObjectTypeSearchInteractor(
                            spaceId: model.document.spaceId,
                            showBookmark: true,
                            showSetAndCollection: false,
                            showFiles: false
                        ),
                        onSelect: $0.onSelect
                    )
                )
            )
        }
    }
}
