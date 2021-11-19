import SwiftUI

struct EditorSetView: View {
    @ObservedObject var model: EditorSetViewModel
    @State private var yOffset = CGFloat.zero
    @State private var headerSize = CGRect.zero
    
    var body: some View {
        ZStack {
            SetTableView(yOffset: $yOffset, headerSize: $headerSize.size)
            SetDetailsHeader(yOffset: $yOffset, headerSize: $headerSize)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .environmentObject(model)
    }
}

struct EditorSetView_Previews: PreviewProvider {
    static var previews: some View {
        EditorSetView(model: EditorSetViewModel(document: BaseDocument(objectId: "")))
    }
}
