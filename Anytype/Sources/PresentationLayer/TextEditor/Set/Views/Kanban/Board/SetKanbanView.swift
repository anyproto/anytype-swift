import SwiftUI
import Services
import DesignKit

struct SetKanbanView: View {
    @ObservedObject var model: EditorSetViewModel

    @Binding var tableHeaderSize: CGSize
    @Binding var offset: CGPoint

    @State private var dropData = SetCardDropData()

    var headerMinimizedSize: CGSize

    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(max(tableHeaderSize.height - headerMinimizedSize.height, 0))
            if !model.isEmptyViews {
                compoundHeader
                boardView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            // The board doesn't scroll vertically as a whole, so the shared
            // offset must be reset after switching from a scrolled view type.
            offset = .zero
        }
    }

    @ViewBuilder
    private var boardView: some View {
        switch model.boardState {
        case .loading:
            loadingView
        case .error:
            errorView
        case .ready:
            boardContent
        }
    }

    private var loadingView: some View {
        DotsView()
            .frame(width: 50, height: 6)
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
    }

    private var errorView: some View {
        EmptyStateView(
            title: Loc.Content.Common.error,
            style: .error,
            buttonData: EmptyStateView.ButtonData(title: Loc.tryAgain) {
                await model.onBoardErrorRetryTap()
            }
        )
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private var boardContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, spacing: 8) {
                ForEach(model.configurationsDict.keys, id: \.self) { groupId in
                    if let configurations = model.configurationsDict[groupId] {
                        SetKanbanColumn(
                            groupId: groupId,
                            headerType: model.headerType(for: groupId),
                            count: model.columnCount(for: groupId),
                            configurations: configurations,
                            isGroupBackgroundColors: model.isGroupBackgroundColors,
                            backgroundColor: model.groupBackgroundColor(for: groupId),
                            showPagingView: model.pagitationData(by: groupId).pageCount > 1,
                            dragAndDropDelegate: model,
                            dropData: $dropData,
                            onShowMoreTap: {
                                model.showMore(groupId: groupId)
                            },
                            onSettingsTap: {
                                model.showKanbanColumnSettings(for: groupId)
                            },
                            onCreateTap: model.canCreateCardInColumn ? {
                                model.onCreateObjectInColumnTap(groupId)
                            } : nil
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .scrollAxisLock(.horizontal)
        }
    }

    private var compoundHeader: some View {
        VStack(spacing: 0) {
            headerSettingsView
            Spacer.fixedHeight(16)
        }
        .background(Color.Background.primary)
    }

    private var headerSettingsView: some View {
        HStack {
            SetHeaderSettingsView(model: model.headerSettingsViewModel)
            .frame(width: tableHeaderSize.width)
            .offset(x: 4, y: 8)
            Spacer()
        }
    }
}
