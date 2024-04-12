import SwiftUI
import AnytypeCore

struct EditorSetView: View {
    @StateObject var model: EditorSetViewModel

    @State private var headerMinimizedSize = CGSize.zero
    @State private var tableHeaderSize = CGSize.zero
    @State private var offset = CGPoint.zero
    @Environment(\.dismiss) private var dismiss
    
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
        .onAppear {
            model.onAppear()
        }
        .onDisappear {
            model.onDisappear()
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
        .anytypeStatusBar(style: .default)
        .anytypeSheet(isPresented: $model.showUpdateAlert, onDismiss: { dismiss() }) {
            DocumentUpdateAlertView { dismiss() }
        }
        .anytypeSheet(isPresented: $model.showCommonOpenError, onDismiss: { dismiss() }) {
            DocumentCommonOpenErrorView { dismiss() }
        }
    }
    
    private var content: some View {
        contentView
            .overlay(
                ZStack(alignment: .topLeading, content: {
                    SetFullHeader(model: model)
                        .readSize { tableHeaderSize = $0 }
                        .offset(x: 0, y: offset.y)
                    SetMinimizedHeader(
                        model: model,
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
                    mode: model.emptyStateMode,
                    allowTap: model.setDocument.isCollection() ? model.setDocument.setPermissions.canCreateObject : model.setDocument.setPermissions.canChangeQuery,
                    onTap: { model.onEmptyStateButtonTap() }
                )
            )
            .frame(width: tableHeaderSize.width)
        }
    }
    
    private var headerSettingsView: some View {
        SetHeaderSettingsView(model: model.headerSettingsViewModel)
            .frame(width: tableHeaderSize.width)
    }
}
