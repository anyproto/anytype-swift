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
        .task {
            await model.startSpaceTask()
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
        ZStack {
            if model.dataLoaded {
                if model.widgetBlocks.isNotEmpty || model.showSpaceChat || !FeatureFlags.binWidgetFromLibrary {
                    widgets
                } else {
                    emptyState
                }
            }
        }
    }
    
    private var widgets: some View {
        ScrollView {
            VStack(spacing: 12) {
                if #available(iOS 17.0, *) {
                    WidgetSwipeTipView()
                }
                if model.showSpaceChat {
                    SpaceChatWidgetView(spaceId: model.spaceId, homeState: $model.homeState, output: model.output)
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
                if !FeatureFlags.binWidgetFromLibrary {
                    BinLinkWidgetView(spaceId: model.spaceId, homeState: $model.homeState, output: model.submoduleOutput())
                }
                editButtons
                AnytypeNavigationSpacer()
            }
            .padding(.horizontal, 20)
            .fitIPadToReadableContentGuide()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Text(Loc.Widgets.List.empty)
                .anytypeStyle(.bodyRegular)
            StandardButton(Loc.Widgets.Actions.addWidget, style: .transparentXSmall) {
                model.onCreateWidgetFromMainMode()
            }
            AnytypeNavigationSpacer()
            Spacer()
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
