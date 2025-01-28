import SwiftUI
import Services

struct SimpleSetView: View {
    
    @StateObject private var model: SimpleSetViewModel
    
    init(objectId: String, spaceId: String, output: (any SimpleSetModuleOutput)?) {
        self._model = StateObject(wrappedValue: SimpleSetViewModel(objectId: objectId, spaceId: spaceId, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            PageNavigationHeader(title: "Simple set") {}
            Spacer()
        }
    }
}

#Preview {
    SimpleSetView(objectId: "", spaceId: "", output: nil)
}
