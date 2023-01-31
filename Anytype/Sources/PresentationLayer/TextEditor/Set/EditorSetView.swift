import SwiftUI

struct EditorSetView: View {
    @ObservedObject var model: EditorSetViewModel

    @State private var headerMinimizedSize = CGSize.zero
    @State private var tableHeaderSize = CGSize.zero
    @State private var offset = CGPoint.zero

    var body: some View {
        Group {
            if model.loadingDocument {
                EmptyView()
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
                Group {
                    if model.showSetEmptyState {
                        emptySetView
                    } else {
                        contentTypeView
                    }
                }
                .overlay(
                    SetFullHeader()
                        .readSize { tableHeaderSize = $0 }
                        .offset(x: 0, y: offset.y)
                    , alignment: .topLeading
                )
                SetMinimizedHeader(
                    headerSize: tableHeaderSize,
                    tableViewOffset: offset,
                    headerMinimizedSize: $headerMinimizedSize
                )
            }
            Rectangle().frame(height: 40).foregroundColor(.Background.primary) // Navigation view stub
        }
        .ignoresSafeArea(edges: .top)
    }
    
    @ViewBuilder
    private var contentTypeView: some View {
        switch model.contentViewType {
        case .table:
            SetTableView(
                model: model,
                tableHeaderSize: $tableHeaderSize,
                offset: $offset,
                headerMinimizedSize: headerMinimizedSize
            )
        case .collection(let viewType):
            SetCollectionView(
                model: model,
                tableHeaderSize: $tableHeaderSize,
                offset: $offset,
                headerMinimizedSize: headerMinimizedSize,
                viewType: viewType
            )
        case .kanban:
            SetKanbanView(
                model: model,
                tableHeaderSize: $tableHeaderSize,
                offset: $offset,
                headerMinimizedSize: headerMinimizedSize
            )
        }
    }
    
    private var emptySetView: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(tableHeaderSize.height + 90)
            
            EditorSetEmptyView(
                model: .init(
                    title: Loc.Set.View.Empty.title,
                    subtitle: Loc.Set.View.Empty.subtitle,
                    buttonTitle: Loc.Set.View.Empty.Button.title,
                    onTap: {
                        model.showSetOfTypeSelection()
                    }
                )
            )
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
