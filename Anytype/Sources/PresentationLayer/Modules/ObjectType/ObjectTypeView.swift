import SwiftUI

struct ObjectTypeView: View {
    @StateObject private var model: ObjectTypeViewModel
    
    init(data: EditorTypeObject) {
        _model = StateObject(wrappedValue: ObjectTypeViewModel(data: data))
    }
    
    var body: some View {
        content
            .task { await model.setup() }
    }
    
    private var content: some View {
        VStack {
            AnytypeText(model.title, style: .title)
            AnytypeText("TBD", style: .subheading).foregroundColor(.Text.secondary)
        }
    }
}

#Preview {
    ObjectTypeView(data: EditorTypeObject(objectId: "", spaceId: ""))
}
