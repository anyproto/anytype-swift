import Foundation
import SwiftUI
import Services
import AnytypeCore

struct HomeWidgetsView: View {
    let info: AccountInfo
    let context: WidgetScreenContext
    let output: (any HomeWidgetsModuleOutput & HomeBottomNavigationPanelModuleOutput)?

    var body: some View {
        HomeWidgetsInternalView(
            info: info,
            context: context,
            output: output
        )
        .id(info.hashValue)
    }
}

private struct HomeWidgetsInternalView: View {
    @State private var model: HomeWidgetsViewModel
    // Hide pinned-widget badges by default; UnreadSectionViewModel releases them on first tick.
    @State private var shouldHideChatBadges: Bool = true

    let context: WidgetScreenContext
    weak var panelOutput: (any HomeBottomNavigationPanelModuleOutput)?

    init(
        info: AccountInfo,
        context: WidgetScreenContext,
        output: (any HomeWidgetsModuleOutput & HomeBottomNavigationPanelModuleOutput)?
    ) {
        self._model = State(wrappedValue: HomeWidgetsViewModel(
            info: info,
            output: output
        ))
        self.context = context
        self.panelOutput = output
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            HomeWallpaperView(spaceId: model.spaceId)

            widgets

            if context.showEmbeddedBottomPanel {
                HomeBottomNavigationPanelView(
                    homePath: HomePath(),
                    info: model.info,
                    output: panelOutput
                )
            }
        }
        .task(priority: .high) {
            await model.openWidgetObjects()
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
            LazyVStack(spacing: 0) {
                SpaceInfoView(spaceId: model.spaceId)
                InviteMembersStubWidgetView(spaceId: model.spaceId, output: model.output)
                if let channelWidgetsObject = model.channelWidgetsObject,
                   let personalWidgetsObject = model.personalWidgetsObject {
                    homeWidget
                    ForEach(model.visibleSections, id: \.self) { section in
                        manageableSection(
                            section,
                            channelWidgetsObject: channelWidgetsObject,
                            personalWidgetsObject: personalWidgetsObject
                        )
                    }
                }
                AnytypeNavigationSpacer(minHeight: context.showEmbeddedBottomPanel ? 72 : 0)
            }
            .padding(.horizontal, 20)
            .fitIPadToReadableContentGuide()
            .shouldHideChatBadges(model.hasUnreadSection && shouldHideChatBadges)
        }
    }

    @ViewBuilder
    private func manageableSection(
        _ section: HomeSection,
        channelWidgetsObject: any BaseDocumentProtocol,
        personalWidgetsObject: any BaseDocumentProtocol
    ) -> some View {
        switch section {
        case .pinned:
            PinnedSectionView(
                info: model.info,
                channelWidgetsObject: channelWidgetsObject,
                personalWidgetsObject: personalWidgetsObject,
                prefetchedSetSubscriptions: model.prefetchedSetSubscriptions,
                output: model.output
            )
        case .unread:
            UnreadSectionView(
                spaceId: model.spaceId,
                output: model.output,
                onShouldHideBadgesChange: { shouldHideChatBadges = $0 }
            )
        case .myFavorites:
            MyFavoritesSectionView(
                spaceId: model.spaceId,
                personalWidgetsObject: personalWidgetsObject,
                channelWidgetsObject: channelWidgetsObject,
                output: model.output
            )
        case .recentlyEdited:
            RecentlyEditedSectionView(
                spaceId: model.spaceId,
                output: model.output
            )
        case .objects:
            ObjectTypesSectionView(
                spaceId: model.spaceId,
                output: model.output,
                onCreateObjectType: { model.output?.onCreateObjectType() }
            )
        case .bin:
            BinLinkWidgetView(spaceId: model.spaceId, output: model.output)
                .padding(.top, 24)
        }
    }

    @ViewBuilder
    private var homeWidget: some View {
        if context == .overlay, let data = model.homeWidgetData {
            HomeWidgetView(data: data)
                .id("\(data.objectId)-\(data.canSetHomepage)")
                .padding(.bottom, 12)
        }
    }
}
