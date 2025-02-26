import Foundation
import SwiftUI
import AnytypeCore


struct RelationsListCoordinatorView: View {
    
    @StateObject private var model: RelationsListCoordinatorViewModel
    
    init(document: some BaseDocumentProtocol, output: (any RelationValueCoordinatorOutput)?) {
        _model = StateObject(wrappedValue: RelationsListCoordinatorViewModel(document: document, output: output))
    }
    
    var body: some View {
        ObjectFieldsView(
            document: model.document,
            output: model
        )
        .sheet(item: $model.relationValueData) { data in
            RelationValueCoordinatorView(data: data, output: model)
        }
        .sheet(item: $model.relationsSearchData) {
            RelationsSearchCoordinatorView(data: $0)
        }
        .sheet(item: $model.objectTypeData) {
            TypeFieldsView(data: $0)
        }
    }
}
