import Foundation
import SwiftUI
import Services
import AnytypeCore

struct HomeWidgetsView: View {
    let info: AccountInfo
    let output: (any HomeWidgetsModuleOutput)?
    
    var body: some View {
        HomeWidgetsInternalView(info: info, output: output)
            .id(info.hashValue)
    }
}

private struct HomeWidgetsInternalView: View {
    @StateObject private var model: HomeWidgetsViewModel
    @State var dndState = DragState()
    
    init(info: AccountInfo, output: (any HomeWidgetsModuleOutput)?) {
        self._model = StateObject(wrappedValue: HomeWidgetsViewModel(info: info, output: output))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HomeWallpaperView(spaceId: model.spaceId)
            
            content
                .animation(.default, value: model.widgetBlocks.count)
            
            HomeBottomPanelView(homeState: $model.homeState) {
                model.onCreateWidgetFromEditMode()
            }
        }
        .task {
            await model.startWidgetObjectTask()
        }
        .task {
            await model.startParticipantTask()
        }
        .onAppear {
            model.onAppear()
        }
        .safeAreaInset(edge: .top) {
            WidgetsHeaderView(spaceId: model.spaceId) {
                model.onSpaceSelected()
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .homeBottomPanelHidden(model.homeState.isEditWidgets)
        .anytypeVerticalDrop(data: model.widgetBlocks, state: $dndState) { from, to in
            model.dropUpdate(from: from, to: to)
        } dropFinish: { from, to in
            model.dropFinish(from: from, to: to)
        }
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 12) {
                if model.dataLoaded {
                    if FeatureFlags.allContent {
                        AllContentWidgetView(
                            spaceId: model.spaceId,
                            homeState: $model.homeState,
                            output: model.output
                        )
                    }
                    if #available(iOS 17.0, *) {
                        if FeatureFlags.anyAppBetaTip {
                            HomeAnyAppWidgetTipView()
                        }
                        WidgetSwipeTipView()
                    }
                    ForEach(model.widgetBlocks) { widgetInfo in
                        HomeWidgetSubmoduleView(
                            widgetInfo: widgetInfo,
                            widgetObject: model.widgetObject,
                            workspaceInfo: model.info,
                            homeState: $model.homeState,
                            output: model.output
                        )
                    }
                    BinLinkWidgetView(spaceId: model.spaceId, homeState: $model.homeState, output: model.submoduleOutput())
                    editButtons
                }
                AnytypeNavigationSpacer()
            }
            .padding(.horizontal, 20)
            .fitIPadToReadableContentGuide()
        }
    }
    
    private var editButtons: some View {
        EqualFitWidthHStack(spacing: 12) {
            HomeEditButton(text: Loc.Widgets.Actions.addWidget, homeState: model.homeState) {
                model.onCreateWidgetFromMainMode()
            }
            HomeEditButton(text: Loc.Widgets.Actions.editWidgets, homeState: model.homeState) {
                model.onEditButtonTap()
            }
        }
    }
}
