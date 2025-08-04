import SwiftUI

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
        }
    }
    
    private var list: some View {
        List {
            
        }
        .listStyle(.plain)
    }
}

#Preview {
    MockView {
        SharingExtensionShareToView(data: SharingExtensionShareToData(spaceId: "1"))
    }
}
