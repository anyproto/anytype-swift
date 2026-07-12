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
        OffsetAwareScrollView(
            axes: [.vertical],
            showsIndicators: false,
            offsetChanged: { offset.y = $0.y }
        ) {
            Spacer.fixedHeight(tableHeaderSize.height)
            content
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: List view
    
    private var content: some View {
        LazyVStack(
            alignment: .center,
            spacing: 0,
            pinnedViews: [.sectionHeaders]
        ) {
            boardView
        }
        .padding(.top, -headerMinimizedSize.height)
    }
    
    @ViewBuilder
    private var boardView: some View {
        if model.isEmptyViews {
            EmptyView()
        } else {
            Section(header: compoundHeader) {
                switch model.boardState {
                case .loading:
                    loadingView
                case .error:
                    errorView
                case .ready:
                    boardContent
                }
            }
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
            HStack(alignment: .top, spacing: 8) {
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
