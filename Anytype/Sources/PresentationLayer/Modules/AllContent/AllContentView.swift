import SwiftUI

struct AllContentView: View {
    
    @StateObject private var model: AllContentViewModel
    
    init(spaceId: String) {
        _model = StateObject(wrappedValue: AllContentViewModel(spaceId: spaceId))
    }
    
    var body: some View {
        Text("This is AllContentView")
    }
}

#Preview {
    AllContentView(spaceId: "")
}
