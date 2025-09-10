import SwiftUI
import Services

struct CreateObjectTypeData: Identifiable {
    let spaceId: String
    let name: String
    
    var id: String { spaceId }
}

struct CreateObjectTypeView: View {
    
    @StateObject private var model: CreateObjectTypeViewModel
    
    init(data: CreateObjectTypeData, completion: ((_ type: ObjectType) -> ())? = nil) {
        self._model = StateObject(wrappedValue: CreateObjectTypeViewModel(data: data, completion: completion))
    }
    
    var body: some View {
        ObjectTypeInfoView(info: model.info) { info in
            model.onCreate(info: info)
        }
    }
}
