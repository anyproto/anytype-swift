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
    @State var widgetsDndState = DragState()
    @State var typesDndState = DragState()
    
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
                blockWidgets
                if FeatureFlags.homeObjectTypeWidgets {
                    objectTypeWidgets
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
            HomeWidgetsGroupView(title: Loc.pinned) {
                model.onTapPinnedHeader()
            }
        }
        if model.pinnedSectionIsExpanded {
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
                if FeatureFlags.homeObjectTypeWidgets {
                    BinLinkWidgetView(spaceId: model.spaceId, homeState: $model.homeState, output: model.output)
                } else {
                    editButtons
                }
            }
            .anytypeVerticalDrop(data: model.widgetBlocks, state: $widgetsDndState) { from, to in
                model.widgetsDropUpdate(from: from, to: to)
            } dropFinish: { from, to in
                model.widgetsDropFinish(from: from, to: to)
            }
        }
    }
    
    @ViewBuilder
    private var objectTypeWidgets: some View {
        HomeWidgetsGroupView(title: Loc.objectTypes) {
            model.onTapObjectTypeHeader()
        } onCreate: {
            model.onCreateObjectType()
        }
        if model.objectTypeSectionIsExpanded {
            VStack(spacing: 12) {
                ForEach(model.objectTypeWidgets) { info in
                    ObjectTypeWidgetView(info: info, output: model.output)
                }
            }
            .anytypeVerticalDrop(data: model.objectTypeWidgets, state: $typesDndState) { from, to in
                model.typesDropUpdate(from: from, to: to)
            } dropFinish: { from, to in
                model.typesDropFinish(from: from, to: to)
            }
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
