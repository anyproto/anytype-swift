import SwiftUI
import AnytypeCore

struct EditorSetView: View {
    @StateObject private var model: EditorSetViewModel

    @State private var headerMinimizedSize = CGSize.zero
    @State private var tableHeaderFullSize = CGSize.zero
    @State private var tableHeaderSize = CGSize.zero
    @State private var safeAreaInsets = EdgeInsets()
    @State private var offset = CGPoint.zero
    @Environment(\.dismiss) private var dismiss
    
    init(data: EditorListObject, showHeader: Bool, output: (any EditorSetModuleOutput)?) {
        self._model = StateObject(wrappedValue: EditorSetViewModel(data: data, showHeader: showHeader, output: output))
    }
    
    var body: some View {
        Group {
            if model.loadingDocument {
                Spacer()
            } else {
                content
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            model.onAppear()
        }
        .task {
            await model.startSubscriptions()
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
        ZStack(alignment: .top) {
            contentView
                .keyboardToolbar()
            
            SetFullHeader(model: model)
                .readSize {
                    tableHeaderFullSize = $0
                    updateHeaderSize()
                }
                .offset(x: 0, y: offset.y)
                .ignoresSafeArea(edges: .top)
            
            if model.showHeader {
                SetMinimizedHeader(
                    model: model,
                    headerSize: tableHeaderSize,
                    tableViewOffset: offset,
                    headerMinimizedSize: $headerMinimizedSize
                )
            }
        }
        .readSafeArea {
            safeAreaInsets = $0
            updateHeaderSize()
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if model.showEmptyState {
            emptyStateView
        } else {
            VStack(spacing: 0) {
                Spacer.fixedHeight(headerMinimizedSize.height)
                contentTypeView
                    .background(Color.Background.primary)
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
    
    private func updateHeaderSize() {
        tableHeaderSize = CGSize(width: tableHeaderFullSize.width, height: tableHeaderFullSize.height - safeAreaInsets.top)
    }
}
