import SwiftUI

struct EditorSetView: View {
    @ObservedObject var model: EditorSetViewModel

    @State private var headerMinimizedSize = CGSize.zero
    @State private var tableHeaderSize = CGSize.zero
    @State private var offset = CGPoint.zero

    var body: some View {
        ZStack {
            SetTableView(
                tableHeaderSize: $tableHeaderSize,
                offset: $offset,
                headerMinimizedSize: headerMinimizedSize
            )
            SetMinimizedHeader(
                headerSize: tableHeaderSize,
                tableViewOffset: offset,
                headerMinimizedSize: $headerMinimizedSize
            )
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
