import SwiftUI

struct EditorSetView: View {
    @ObservedObject var model: EditorSetViewModel

    @State private var headerMinimizedSize = CGSize.zero
    @State private var tableHeaderSize = CGSize.zero
    @State private var offset = CGPoint.zero

    var body: some View {
        Group {
            if model.loadingDocument {
                placeholder
            } else {
                content
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
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
                contentTypeView
                SetMinimizedHeader(
                    headerSize: tableHeaderSize,
                    tableViewOffset: offset,
                    headerMinimizedSize: $headerMinimizedSize
                )
            }
            Rectangle().frame(height: 40).foregroundColor(.backgroundPrimary) // Navigation view stub
        }
        .ignoresSafeArea(edges: .top)
    }
    
    private var contentTypeView: some View {
        Group {
            switch model.contentViewType {
            case .table:
                SetTableView(
                    model: model,
                    tableHeaderSize: $tableHeaderSize,
                    offset: $offset,
                    headerMinimizedSize: headerMinimizedSize
                )
            case .gallery, .list:
                SetCollectionView(
                    model: model,
                    tableHeaderSize: $tableHeaderSize,
                    offset: $offset,
                    headerMinimizedSize: headerMinimizedSize
                )
            }
        }
    }
    
    private var placeholder: some View {
        EmptyView()
    }
}
