import SwiftUI

struct SetRelationsCoordinatorView: View {
    @StateObject var model: SetRelationsCoordinatorViewModel
    
    var body: some View {
        SetRelationsView(
            setDocument: model.setDocument,
            viewId: model.viewId,
            output: model
        )
        .sheet(item: $model.addRelationsData) { data in
            model.newRelationView(data: data)
        }
    }
}
