import SwiftUI
import Services
import AnytypeCore

struct CreateObjectTypeData: Identifiable {
    let spaceId: String
    let name: String
    let route: ScreenCreateTypeRoute

    var id: String { spaceId }
}

struct CreateObjectTypeView: View {

    @State private var model: CreateObjectTypeViewModel

    init(data: CreateObjectTypeData, completion: ((_ type: ObjectType) -> ())? = nil) {
        _model = State(initialValue: CreateObjectTypeViewModel(data: data, completion: completion))
    }
    
    var body: some View {
        ObjectTypeInfoView(info: model.info) { info in
            model.onCreate(info: info)
        }
        .onAppear {
            model.onAppear()
        }
    }
}
