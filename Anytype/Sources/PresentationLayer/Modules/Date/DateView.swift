import SwiftUI

struct DateView: View {
    
    @StateObject private var model: DateViewModel
    
    init(objectId: String, spaceId: String) {
        self._model = StateObject(wrappedValue: DateViewModel(objectId: objectId, spaceId: spaceId))
    }
    
    var body: some View {
        Text("DateView")
    }
}

#Preview {
    DateView(objectId: "", spaceId: "")
}
