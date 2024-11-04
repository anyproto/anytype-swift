import SwiftUI

struct ObjectTypeCoordinator: View {
    let data: EditorTypeObject
    
    var body: some View {
        ObjectTypeView(data: data)
    }
}

#Preview {
    ObjectTypeCoordinator(data: EditorTypeObject(objectId: "", spaceId: ""))
}
