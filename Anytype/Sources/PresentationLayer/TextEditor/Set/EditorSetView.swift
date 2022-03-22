import SwiftUI

struct EditorSetView: View {
    @ObservedObject var model: EditorSetViewModel

    @State private var headerMinimizedSize = CGSize.zero
    @State private var tableHeaderSize = CGSize.zero
    @State private var offset = CGPoint.zero

    var body: some View {
        content
            .environmentObject(model)
            .onAppear {
                model.onAppear()
            }
            .onDisappear {
                model.onDisappear()
            }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
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
            Rectangle().frame(height: 40).foregroundColor(.backgroundPrimary) // Navigation view stub
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }
}
