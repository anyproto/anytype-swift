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
                StubWidgetsView(spaceId: model.spaceId, output: model.output)
                topWidgets
                blockWidgets
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
        if let data = model.chatWidgetData {
            SpaceChatWidgetView(data: data)
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
    private var blockWidgets: some View {
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
                            widgetObject: model.widgetObject,
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
