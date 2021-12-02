import SwiftUI

struct EditorSetView: View {
    @ObservedObject var model: EditorSetViewModel
    
    @State private var offset = CGPoint.zero
    @State private var headerSize = CGRect.zero
    
    var body: some View {
        ZStack {
            SetTableView(offset: $offset, headerSize: $headerSize.size)
            SetHeader(offset: $offset, headerSize: $headerSize)
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
