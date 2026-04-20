import Foundation
import SwiftUI
import Services
import AnytypeCore

struct HomeWidgetsView: View {
    let info: AccountInfo
    let context: WidgetScreenContext
    let output: (any HomeWidgetsModuleOutput & HomeBottomNavigationPanelModuleOutput)?

    var body: some View {
        HomeWidgetsInternalView(info: info, context: context, output: output)
            .id(info.hashValue)
    }
}

private struct HomeWidgetsInternalView: View {
    @State private var model: HomeWidgetsViewModel
    @State var widgetsDndState = DragState()

    let context: WidgetScreenContext
    weak var panelOutput: (any HomeBottomNavigationPanelModuleOutput)?

    init(info: AccountInfo, context: WidgetScreenContext, output: (any HomeWidgetsModuleOutput & HomeBottomNavigationPanelModuleOutput)?) {
        self._model = State(wrappedValue: HomeWidgetsViewModel(info: info, output: output))
        self.context = context
        self.panelOutput = output
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            HomeWallpaperView(spaceId: model.spaceId)

            content
                .animation(.default, value: model.widgetBlocks.count)

            if context.showEmbeddedBottomPanel {
                HomeBottomNavigationPanelView(
                    homePath: HomePath(),
                    info: model.info,
                    output: panelOutput
                )
            }
        }
        .task {
            await model.startSubscriptions()
        }
        .onAppear {
            model.onAppear()
        }
        .safeAreaInset(edge: .top) {
            WidgetsHeaderView(
                spaceId: model.spaceId,
                context: context,
                onSpaceSelected: {
                    model.onSpaceSelected()
                },
                onMembersSelected: { spaceId, route in
                    model.onMembersSelected(spaceId: spaceId, route: route)
                },
                onQrCodeSelected: { url in
                    model.onQrCodeSelected(url: url)
                }
            )
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .homeBottomPanelHidden(context.showEmbeddedBottomPanel)
    }
    
    private var content: some View {
        ZStack {
            if model.widgetsDataLoaded && model.objectTypesDataLoaded {
                widgets
            }
        }
    }
    
    private var widgets: some View {
        ScrollView {
            VStack(spacing: 0) {
                SpaceInfoView(spaceId: model.spaceId)
                InviteMembersStubWidgetView(spaceId: model.spaceId, output: model.output)
                if FeatureFlags.personalFavorites {
                    homeWidget
                    blockWidgets
                    unreadWidget
                    myFavoritesWidget
                } else {
                    topWidgets
                    blockWidgets
                }
                objectTypeWidgets
                AnytypeNavigationSpacer(minHeight: context.showEmbeddedBottomPanel ? 72 : 0)
            }
            .padding(.horizontal, 20)
            .fitIPadToReadableContentGuide()
            .shouldHideChatBadges(model.shouldHideChatBadges)
        }
    }

    @ViewBuilder
    private var topWidgets: some View {
        if context == .overlay, let data = model.homeWidgetData {
            HomeWidgetView(data: data)
                .id("\(data.objectId)-\(data.canSetHomepage)")
        } else if model.shouldShowUnreadSection {
            HomeWidgetsGroupView(title: Loc.unread) {
                model.onTapUnreadHeader()
            }
            if model.unreadSectionIsExpanded {
                UnreadChatsGroupedView(chats: model.unreadChats)
            }
        }
    }

    @ViewBuilder
    private var homeWidget: some View {
        if context == .overlay, let data = model.homeWidgetData {
            HomeWidgetView(data: data)
                .id("\(data.objectId)-\(data.canSetHomepage)")
                // 8pt gap to the channel-pins section that follows. Lives on
                // the home widget itself so the spacing only applies when home
                // is visible — no extra view needed otherwise.
                .padding(.bottom, 8)
        }
    }

    @ViewBuilder
    private var unreadWidget: some View {
        // No `context == .overlay` gate — unread is global to the space and
        // should be visible in both navigation and overlay contexts. The legacy
        // `topWidgets` (flag-off branch) only suppressed unread in overlay as a
        // side effect of sharing the slot with the home widget via `else if`;
        // that constraint doesn't carry over now that home and unread are
        // dedicated sections.
        if model.shouldShowUnreadSection {
            HomeWidgetsGroupView(title: Loc.unread) {
                model.onTapUnreadHeader()
            }
            if model.unreadSectionIsExpanded {
                UnreadChatsGroupedView(chats: model.unreadChats)
            }
        }
    }

    @ViewBuilder
    private var blockWidgets: some View {
        if FeatureFlags.personalFavorites {
            if model.widgetBlocks.isNotEmpty {
                VStack(spacing: 12) {
                    WidgetSwipeTipView()
                    ForEach(model.widgetBlocks) { widgetInfo in
                        HomeWidgetSubmoduleView(
                            widgetInfo: widgetInfo,
                            channelWidgetsObject: model.channelWidgetsObject,
                            personalWidgetsObject: model.personalWidgetsObject,
                            workspaceInfo: model.info,
                            homeState: $model.homeState,
                            output: model.output
                        )
                    }
                }
                .anytypeVerticalDrop(data: model.widgetBlocks, state: $widgetsDndState) { from, to in
                    model.widgetsDropUpdate(from: from, to: to)
                } dropFinish: { from, to in
                    model.widgetsDropFinish(from: from, to: to)
                }
            }
        } else {
            if model.widgetBlocks.isNotEmpty {
                HomeWidgetsGroupView(title: Loc.pinned) {
                    model.onTapPinnedHeader()
                }
                if model.pinnedSectionIsExpanded {
                    VStack(spacing: 12) {
                        WidgetSwipeTipView()
                        ForEach(model.widgetBlocks) { widgetInfo in
                            HomeWidgetSubmoduleView(
                                widgetInfo: widgetInfo,
                                channelWidgetsObject: model.channelWidgetsObject,
                                personalWidgetsObject: model.personalWidgetsObject,
                                workspaceInfo: model.info,
                                homeState: $model.homeState,
                                output: model.output
                            )
                        }
                    }
                    .anytypeVerticalDrop(data: model.widgetBlocks, state: $widgetsDndState) { from, to in
                        model.widgetsDropUpdate(from: from, to: to)
                    } dropFinish: { from, to in
                        model.widgetsDropFinish(from: from, to: to)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var myFavoritesWidget: some View {
        if FeatureFlags.personalFavorites,
           let myFavoritesViewModel = model.myFavoritesViewModel,
           let personalWidgetsObject = model.personalWidgetsObject,
           myFavoritesViewModel.rows.isNotEmpty {
            HomeWidgetsGroupView(title: Loc.myFavorites) {
                model.onTapMyFavoritesHeader()
            }
            if model.myFavoritesSectionIsExpanded {
                MyFavoritesListView(
                    rows: myFavoritesViewModel.rows,
                    // Each row's long-press menu reads the current pinned state from the
                    // shared channel widgets document and toggles against it.
                    channelWidgetsObject: model.channelWidgetsObject,
                    personalWidgetsObject: personalWidgetsObject,
                    canManageChannelPins: model.canManageChannelPins,
                    pinnedToChannelByObjectId: myFavoritesViewModel.pinnedToChannelByObjectId,
                    dropUpdate: { from, to in
                        myFavoritesViewModel.dropUpdate(from: from, to: to)
                    },
                    dropFinish: { from, to in
                        myFavoritesViewModel.dropFinish(from: from, to: to)
                    }
                )
            }
        }
    }

    @ViewBuilder
    private var objectTypeWidgets: some View {
        HomeWidgetsGroupView(title: Loc.objects, onTap: {
            model.onTapObjectTypeHeader()
        }, onCreate: nil)
        if model.objectTypeSectionIsExpanded {
            VStack(spacing: 12) {
                ObjectTypesUnifiedWidgetView(
                    typeInfos: model.objectTypeWidgets,
                    canCreateType: model.canCreateObjectType,
                    onCreateType: { model.onCreateObjectType() },
                    output: model.output
                )
                BinLinkWidgetView(spaceId: model.spaceId, homeState: $model.homeState, output: model.output)
            }
        }
    }
}
