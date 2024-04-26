import SwiftUI

struct NewRelationCoordinatorView: View {
    
    @StateObject private var model: NewRelationCoordinatorViewModel
    
    init(name: String, document: BaseDocumentProtocol, target: RelationsModuleTarget) {
        _model = StateObject(wrappedValue: NewRelationCoordinatorViewModel(name: name, document: document, target: target))
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
    }
}
