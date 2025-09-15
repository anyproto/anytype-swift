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
            await model.startSubscriptions()
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
                if model.widgetBlocks.isNotEmpty {
                    widgets
                } else {
                    emptyState
                }
            }
        }
    }
    
    private var widgets: some View {
        ScrollView {
            VStack(spacing: 0) {
                blockWidgets
                if FeatureFlags.homeObjectTypeWidgets {
                    objectTypeWidgets
                } else {
                    editButtons
                }
                AnytypeNavigationSpacer()
            }
            .padding(.horizontal, 20)
            .fitIPadToReadableContentGuide()
        }
    }
    
    @ViewBuilder
    private var blockWidgets: some View {
        if FeatureFlags.homeObjectTypeWidgets {
            HomeWidgetsGroupView(title: Loc.pinned)
        }
        VStack(spacing: 12) {
            if #available(iOS 17.0, *) {
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
        }
    }
    
    @ViewBuilder
    private var objectTypeWidgets: some View {
        HomeWidgetsGroupView(title: Loc.objectTypes) {
            model.onCreateObjectType()
        }
        VStack(spacing: 12) {
            ForEach(model.objectTypeWidgets) { info in
                ObjectTypeWidgetView(info: info, output: model.output)
            }
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
