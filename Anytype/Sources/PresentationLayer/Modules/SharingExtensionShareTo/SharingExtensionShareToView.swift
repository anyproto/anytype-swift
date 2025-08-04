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
            SearchBar(text: $model.searchText, focused: false, placeholder: Loc.search)
            list
        }
        .task(id: model.searchText) {
            await model.search()
        }
    }
    
    private var list: some View {
        PlainList {
            ForEach(model.searchData) {
                SearchCell(data: $0)
            }
        }
    }
}

#Preview {
    MockView {
        SharingExtensionShareToView(data: SharingExtensionShareToData(spaceId: "1"))
    }
}
