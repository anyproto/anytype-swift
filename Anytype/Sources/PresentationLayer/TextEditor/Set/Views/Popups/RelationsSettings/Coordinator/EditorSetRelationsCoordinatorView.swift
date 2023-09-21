import SwiftUI

struct SetRelationsCoordinatorView: View {
    @StateObject var model: EditorSetRelationsCoordinatorViewModel
    
    var body: some View {
        model.list()
            .sheet(item: $model.addRelationsData) { data in
                model.newRelationView(data: data)
            }
    }
}
