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
    @State private var pinnedWidgetsCount: Int = 0

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

            widgets
                .animation(.default, value: pinnedWidgetsCount)
                .animation(.default, value: model.myFavoritesListViewModel.rows.count)
                .animation(.default, value: model.recentlyEditedListViewModel.rows.count)

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
                },
                onManageSectionsSelected: {
                    model.onManageSectionsSelected()
                }
            )
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .homeBottomPanelHidden(context.showEmbeddedBottomPanel)
    }
    
    private var widgets: some View {
        ScrollView {
            VStack(spacing: 0) {
                SpaceInfoView(spaceId: model.spaceId)
                InviteMembersStubWidgetView(spaceId: model.spaceId, output: model.output)
                homeWidget
                ForEach(model.sectionsConfiguration.visibleSections, id: \.self) { section in
                    manageableSection(section)
                }
                AnytypeNavigationSpacer(minHeight: context.showEmbeddedBottomPanel ? 72 : 0)
            }
            .padding(.horizontal, 20)
            .fitIPadToReadableContentGuide()
            .shouldHideChatBadges(model.shouldHideChatBadges)
        }
    }

    @ViewBuilder
    private func manageableSection(_ section: HomeSection) -> some View {
        switch section {
        case .pinned:
            PinnedSectionView(
                info: model.info,
                channelWidgetsObject: model.channelWidgetsObject,
                personalWidgetsObject: model.personalWidgetsObject,
                output: model.output,
                onWidgetsCountChange: { pinnedWidgetsCount = $0 }
            )
        case .unread: unreadWidget
        case .myFavorites: myFavoritesWidget
        case .recentlyEdited: recentlyEditedWidget
        case .objects: objectTypeWidgets
        case .bin: binWidget
        }
    }

    @ViewBuilder
    private var homeWidget: some View {
        if context == .overlay, let data = model.homeWidgetData {
            HomeWidgetView(data: data)
                .id("\(data.objectId)-\(data.canSetHomepage)")
                .padding(.bottom, 8)
        }
    }

    @ViewBuilder
    private var unreadWidget: some View {
        if model.shouldShowUnreadSection {
            HomeWidgetsGroupView(title: Loc.unread) {
                model.onTapUnreadHeader()
            }
            if model.unreadSectionIsExpanded {
                UnreadItemsGroupedView(items: model.unreadItems)
            }
        }
    }

    @ViewBuilder
    private var myFavoritesWidget: some View {
        if model.myFavoritesListViewModel.rows.isNotEmpty {
            HomeWidgetsGroupView(title: Loc.myFavorites) {
                model.onTapMyFavoritesHeader()
            }
            if model.myFavoritesSectionIsExpanded {
                MyFavoritesListView(model: model.myFavoritesListViewModel)
            }
        }
    }

    @ViewBuilder
    private var recentlyEditedWidget: some View {
        if model.recentlyEditedListViewModel.rows.isNotEmpty {
            HomeWidgetsGroupView(title: Loc.Widgets.Library.RecentlyEdited.name) {
                model.onTapRecentlyEditedHeader()
            }
            if model.recentlyEditedSectionIsExpanded {
                RecentlyEditedListView(model: model.recentlyEditedListViewModel)
            }
        }
    }

    @ViewBuilder
    private var objectTypeWidgets: some View {
        if model.objectTypesDataLoaded {
            HomeWidgetsGroupView(title: Loc.types, onTap: {
                model.onTapObjectTypeHeader()
            }, onCreate: nil)
            if model.objectTypeSectionIsExpanded {
                ObjectTypesUnifiedWidgetView(
                    typeInfos: model.objectTypeWidgets,
                    canCreateType: model.canCreateObjectType,
                    onCreateType: { model.onCreateObjectType() },
                    output: model.output
                )
            }
        }
    }

    @ViewBuilder
    private var binWidget: some View {
        if model.homeState.isReadWrite {
            BinLinkWidgetView(spaceId: model.spaceId, homeState: $model.homeState, output: model.output)
                .padding(.top, 24)
        }
    }
}
