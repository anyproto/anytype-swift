import SwiftUI


struct SetKanbanColumn: View {
    let groupId: String
    let headerType: SetKanbanColumnHeaderType
    let count: Int
    let configurations: [SetContentViewItemConfiguration]
    let isGroupBackgroundColors: Bool
    let backgroundColor: BlockBackgroundColor
    let showPagingView: Bool
    // The first `collapseDistance` points of this column's scroll collapse the shared object
    // header instead of moving cards: a same-height top spacer reserves that travel, and the
    // coordinator mirrors the offset into the header overlays.
    let collapseDistance: CGFloat
    // Viewport height + collapseDistance, so even a short column can always scroll far enough
    // to fully collapse the header.
    let minContentHeight: CGFloat
    let collapseCoordinator: KanbanCollapseCoordinator

    let dragAndDropDelegate: any SetDragAndDropDelegate
    @Binding var dropData: SetCardDropData

    let onShowMoreTap: () -> Void
    let onSettingsTap: () -> Void
    let onCreateTap: (() -> Void)?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer.fixedHeight(collapseDistance)
                LazyVStack(spacing: 8, pinnedViews: [.sectionHeaders]) {
                    Section(header: pinnedHeader) {
                        cards
                    }
                }
                .padding(.bottom, configurations.isEmpty ? 0 : Constants.contentInset)
                .background(columnBackgroundColor, in: .rect(cornerRadius: 4))
                if configurations.isEmpty {
                    emptyDroppableArea
                }
                // Room to scroll the last card and the create button clear of the floating
                // home panel, whose blur intercepts touches across the full width.
                AnytypeNavigationSpacer()
            }
            .frame(minHeight: minContentHeight, alignment: .top)
            .scrollAxisLock(.vertical)
            .kanbanCollapseSync(collapseCoordinator)
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(width: 270)
    }

    // Stays inside the scroll view so drags starting on it still drive the collapse, and pins to
    // the column viewport top once the header travel is consumed.
    private var pinnedHeader: some View {
        header
            .padding(.horizontal, 8)
            .background {
                // Opaque even when the group tint is translucent - cards scroll under the
                // pinned header.
                ZStack {
                    headerBackgroundShape.fill(Color.Background.primary)
                    headerBackgroundShape.fill(columnBackgroundColor)
                }
            }
            .overlay(alignment: .bottom) {
                topFade.offset(y: Constants.contentInset)
            }
    }

    private var headerBackgroundShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(topLeadingRadius: 4, topTrailingRadius: 4)
    }

    private var columnBackgroundColor: Color {
        isGroupBackgroundColors ?
        backgroundColor.swiftColor.opacity(0.5) :
        Color.Background.primary
    }

    // Softens the hard clip under the pinned header: cards dissolve into the column's own color
    // instead of being cut off. The group tint is translucent, so the fade has to be its
    // composite over the board background - fading to the tint alone would leave cards showing
    // through it.
    private var topFade: some View {
        ZStack {
            Color.Background.primary
            columnBackgroundColor
        }
        .frame(height: Constants.contentInset)
        .mask(
            LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
        )
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var cards: some View {
        ForEach(configurations) { configuration in
            SetDragAndDropView(
                dropData: $dropData,
                configuration: configuration,
                groupId: groupId,
                dragAndDropDelegate: dragAndDropDelegate,
                content: {
                    SetGalleryViewCell(configuration: configuration)
                }
            )
            .padding(.horizontal, 8)
        }
        if showPagingView {
            pagingView
                .padding(.horizontal, 8)
        }
        if let onCreateTap {
            createView(onCreateTap)
                .padding(.horizontal, 8)
        }
    }

    private func createView(_ onTap: @escaping () -> Void) -> some View {
        SetDragAndDropView(
            dropData: $dropData,
            configuration: nil,
            groupId: groupId,
            dragAndDropDelegate: dragAndDropDelegate,
            content: {
                Button {
                    onTap()
                } label: {
                    HStack(spacing: 6) {
                        Image(asset: .X24.plus)
                            .foregroundStyle(Color.Control.secondary)
                        AnytypeText(Loc.new, style: .caption1Medium)
                            .foregroundStyle(Color.Text.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .fixTappableArea()
                }
                .buttonStyle(LightDimmingButtonStyle())
            }
        )
    }

    private var header: some View {
        Button {
            onSettingsTap()
        } label: {
            headerContent
                .fixTappableArea()
        }
        .frame(height: 44)
        .buttonStyle(LightDimmingButtonStyle())
    }

    private var headerContent: some View {
        HStack(spacing: 0) {
            switch headerType {
            case .uncategorized:
                AnytypeText(
                    Loc.Set.View.Kanban.Column.Title.uncategorized,
                    style: .relation2Regular
                )
                .foregroundStyle(Color.Text.secondary)
            case let .status(options):
                StatusPropertyView(options: options, hint: "", style: .kanbanHeader)
            case let .tag(options):
                TagPropertyView(tags: options, hint: "", style: .kanbanHeader)
            case let .checkbox(title, isChecked):
                HStack(spacing: 6) {
                    if isChecked {
                        Image(asset: .TextEditor.Text.checked)
                    } else {
                        Image(asset: .TextEditor.Text.unchecked)
                            .foregroundStyle(Color.Control.secondary)
                    }
                    let text = isChecked ?
                    Loc.Set.View.Kanban.Column.Title.checked(title) :
                    Loc.Set.View.Kanban.Column.Title.unchecked(title)
                    AnytypeText(
                        text,
                        style: .relation2Regular
                    )
                    .foregroundStyle(Color.Text.secondary)
                }
            }

            Spacer.fixedWidth(8)
            AnytypeText("\(count)", style: .relation2Regular)
                .foregroundStyle(Color.Text.secondary)

            Spacer()

            Image(asset: .X24.more).foregroundStyle(Color.Control.secondary)
        }
        .padding(.horizontal, 10)
    }

    private var pagingView: some View {
        Button {
            onShowMoreTap()
        } label: {
            VStack(spacing: 0) {
                Spacer.fixedHeight(4)
                HStack(spacing: 0) {
                    Spacer.fixedWidth(3)
                    Image(asset: .arrowDown)
                        .foregroundStyle(Color.Text.secondary)
                        .frame(width: 18, height: 18)
                    Spacer.fixedWidth(7)
                    AnytypeText(
                        Loc.Set.View.Kanban.Column.Paging.Title.showMore,
                        style: .caption1Medium
                    )
                    .foregroundStyle(Color.Text.secondary)
                    Spacer()
                }
                Spacer.fixedHeight(4)
            }
        }
    }

    private var emptyDroppableArea: some View {
        SetDragAndDropView(
            dropData: $dropData,
            configuration: nil,
            groupId: groupId,
            dragAndDropDelegate: dragAndDropDelegate,
            content: {
                Rectangle()
                    .fill(Color.Background.primary)
                    .frame(height: 44)
            }
        )
    }
}

extension SetKanbanColumn {
    enum Constants {
        // Doubles as the fade height, so at rest the fade covers only the inset and is fully
        // transparent by the first card's top edge.
        static let contentInset: CGFloat = 8
    }
}
