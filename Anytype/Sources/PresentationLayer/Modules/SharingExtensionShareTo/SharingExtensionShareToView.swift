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
        Text("Hello, world!")
    }
}

#Preview {
    MockView {
        SharingExtensionShareToView(data: SharingExtensionShareToData(spaceId: "1"))
    }
}
