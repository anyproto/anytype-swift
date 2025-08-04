import SwiftUI
import DesignKit

struct SharingExtensionShareToData: Hashable, Identifiable {
    let spaceId: String
    
    var id: Int { hashValue }
}

struct SharingExtensionShareToView: View {
    
    @StateObject private var model: SharingExtensionShareToViewModel
    
    init(data: SharingExtensionShareToData) {
        self._model = StateObject(wrappedValue: SharingExtensionShareToViewModel(data: data))
    }
    
    var body: some View {
        VStack {
            DragIndicator()
            ModalNavigationHeader(title: model.title)
            list
        }
        .throwingTask(id: model.searchText) {
            try await model.search()
        }
    }
    
    private var list: some View {
        PlainList {
            Text("1")
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
    }
}

#Preview {
    MockView {
        SharingExtensionShareToView(data: SharingExtensionShareToData(spaceId: "1"))
    }
}
