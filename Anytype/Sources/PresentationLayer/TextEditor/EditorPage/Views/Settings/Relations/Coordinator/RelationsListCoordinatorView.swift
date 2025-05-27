import Foundation
import Services
import SwiftUI
import AnytypeCore


struct RelationsListCoordinatorView: View {
    
    @StateObject private var model: RelationsListCoordinatorViewModel
    
    init(document: some BaseDocumentProtocol, output: (any RelationValueCoordinatorOutput)?) {
        _model = StateObject(wrappedValue: RelationsListCoordinatorViewModel(document: document, output: output))
    }
    
    var body: some View {
        ObjectPropertiesView(
            document: model.document,
            output: model
        )
        .sheet(item: $model.relationValueData) { data in
            RelationValueCoordinatorView(data: data, output: model)
        }
        .sheet(item: $model.relationsSearchData) {
            RelationCreationView(data: $0)
        }
        .sheet(item: $model.objectTypeData) {
            TypePropertiesView(data: $0)
        }
        .sheet(isPresented: $model.showTypePicker) {
            ObjectTypeSearchView(
                title: Loc.changeType,
                spaceId: model.document.spaceId,
                settings: .editorChangeType
            ) { type in
                model.onTypeSelected(type)
            }
        }
    }
}
