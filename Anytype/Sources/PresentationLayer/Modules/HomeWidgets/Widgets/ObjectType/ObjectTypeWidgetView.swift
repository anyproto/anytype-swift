import SwiftUI

struct ObjectTypeWidgetView: View {
    let info: ObjectTypeWidgetInfo
    
    var body: some View {
        ObjectTypeWidgetInternalView(info: info)
            .id(info.hashValue)
    }
}

private struct ObjectTypeWidgetInternalView: View {
    
    @StateObject private var model: ObjectTypeWidgetViewModel
    
    init(info: ObjectTypeWidgetInfo) {
        self._model = StateObject(wrappedValue: ObjectTypeWidgetViewModel(info: info))
    }
    
    var body: some View {
        Text(model.typeName)
            .task {
                await model.startSubscription()
            }
    }
}
