import SwiftUI
import Services
import DesignKit

struct SetKanbanView: View {
    @ObservedObject var model: EditorSetViewModel

    @Binding var tableHeaderSize: CGSize
    @Binding var offset: CGPoint

    @State private var dropData = SetCardDropData()
    @State private var headerTravel: CGFloat = 0
    @State private var settingsHeaderSize = CGSize.zero
    @State private var collapseCoordinator = KanbanCollapseCoordinator()

    var headerMinimizedSize: CGSize
    // Full object header height including the top safe area - the travel at which the header
    // has slid completely off-screen.
    var fullHeaderHeight: CGFloat

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onAppear {
                collapseCoordinator.onHeaderTravelChange = { travel in
                    headerTravel = travel
                    offset = CGPoint(x: 0, y: -travel)
                }
            }
            .onDisappear {
                // The closure captures the view, whose @State storage owns the coordinator -
                // break the cycle or the coordinator outlives the board.
                collapseCoordinator.onHeaderTravelChange = nil
            }
            .onChange(of: collapseDistance, initial: true) { _, _ in
                updateCoordinatorDistances()
            }
            .onChange(of: fullHeaderHeight) { _, _ in
                updateCoordinatorDistances()
            }
            .onChange(of: showsBoard, initial: true) { _, showsBoard in
                if showsBoard {
                    offset = CGPoint(x: 0, y: -headerTravel)
                } else {
                    collapseCoordinator.reset()
                    headerTravel = 0
                    offset = .zero
                }
            }
    }

    // The distance the page must scroll before the settings row rests at the top. The object
    // header keeps sliding past this point (up to fullHeaderHeight) as cards scroll on.
    private var collapseDistance: CGFloat {
        max(tableHeaderSize.height - headerMinimizedSize.height, 0)
    }

    private func updateCoordinatorDistances() {
        collapseCoordinator.setDistances(collapse: collapseDistance, headerTravel: fullHeaderHeight)
    }

    private var showsBoard: Bool {
        !model.isEmptyViews && model.boardState == .ready
    }

    @ViewBuilder
    private var content: some View {
        if showsBoard {
            board
        } else {
            staticHeader
        }
    }

    // Loading/error/empty states have no columns to drive the collapse, so the header stays
    // expanded and the settings row keeps its resting position below it.
    private var staticHeader: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(collapseDistance)
            if !model.isEmptyViews {
                compoundHeader
                switch model.boardState {
                case .loading:
                    loadingView
                case .error:
                    errorView
                case .ready:
                    EmptyView()
                }
            }
        }
    }

    // The board never scrolls vertically as a page. Each column reserves `collapseDistance`
    // points with a top spacer inside its own scroll content, the actively scrolled column
    // publishes the shared `headerTravel`, and the settings row + object header are overlays
    // slaved to it - so the whole page visually scrolls as one, like the other view types.
    private var board: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                boardContent(viewportHeight: geometry.size.height)
                    .padding(.top, settingsHeaderSize.height)

                compoundHeader
                    .readSize { settingsHeaderSize = $0 }
                    // Stops at the top once the collapse is consumed.
                    .offset(y: collapseDistance - min(headerTravel, collapseDistance))
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

    private func boardContent(viewportHeight: CGFloat) -> some View {
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
                            collapseDistance: collapseDistance,
                            minContentHeight: viewportHeight - settingsHeaderSize.height + collapseDistance,
                            collapseCoordinator: collapseCoordinator,
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
