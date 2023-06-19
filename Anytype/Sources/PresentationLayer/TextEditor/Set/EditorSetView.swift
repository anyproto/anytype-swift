import SwiftUI
import AnytypeCore

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
        contentView
            .overlay(
                ZStack(alignment: .topLeading, content: {
                    SetFullHeader()
                        .readSize { tableHeaderSize = $0 }
                        .offset(x: 0, y: offset.y)
                    SetMinimizedHeader(
                        headerSize: tableHeaderSize,
                        tableViewOffset: offset,
                        headerMinimizedSize: $headerMinimizedSize
                    )
                })
                , alignment: .topLeading
            )
            .ignoresSafeArea(edges: .top)
            .keyboardToolbar()
    }
    
    @ViewBuilder
    private var contentView: some View {
        if model.showEmptyState {
            emptyStateView
        } else {
            VStack(spacing: 0) {
                Spacer.fixedHeight(headerMinimizedSize.height)
                contentTypeView
            }
        }
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
    
    private var emptyStateView: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(tableHeaderSize.height + 8)
            headerSettingsView
            AnytypeDivider()
            Spacer.fixedHeight(48)
            EditorSetEmptyView(
                model: EditorSetEmptyViewModel(
                    mode: model.setDocument.isCollection() ? .collection : .set,
                    onTap: model.onEmptyStateButtonTap
                )
            )
            .frame(width: tableHeaderSize.width)
        }
    }
    
    private var headerSettingsView: some View {
        SetHeaderSettingsView(
            model: SetHeaderSettingsViewModel(
                setDocument: model.setDocument,
                isActive: model.isActiveHeader,
                onViewTap: model.showViewPicker,
                onSettingsTap: model.showSetSettings,
                onCreateTap: model.createObject
            )
        )
        .frame(width: tableHeaderSize.width)
    }
}
