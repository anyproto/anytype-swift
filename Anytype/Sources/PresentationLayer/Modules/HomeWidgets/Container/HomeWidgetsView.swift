import Foundation
import SwiftUI

struct HomeWidgetsView: View {    
    @StateObject var model: HomeWidgetsViewModel
    @State var dndState = DragState()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            DashboardWallpaper(wallpaper: model.wallpaper)
            VerticalScrollViewWithOverlayHeader {
                HomeTopShadow()
            } content: {
                VStack(spacing: 12) {
                    if #available(iOS 17.0, *) {
                        WidgetSwipeTipView()
                    }
                    ForEach(model.models) { rowModel in
                        rowModel.provider.view
                    }
                    if model.dataLoaded {
                        HomeEditButton(text: Loc.Widgets.Actions.editWidgets) {
                            model.onEditButtonTap()
                        }
                        .opacity(model.hideEditButton ? 0 : 1)
                        .animation(.default, value: model.hideEditButton)
                    }
                    AnytypeNavigationSpacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .opacity(model.dataLoaded ? 1 : 0)
                .fitIPadToReadableContentGuide()
            }
            .animation(.default, value: model.models.count)
            model.bottomPanelProvider.view
                .fitIPadToReadableContentGuide()
        }
        .onAppear {
            model.onAppear()
        }
        .onDisappear {
            model.onDisappear()
        }
        .navigationBarHidden(true)
        .anytypeStatusBar(style: .lightContent)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .homeBottomPanelHidden(model.hideEditButton)
        .anytypeVerticalDrop(data: model.models, state: $dndState) { from, to in
            model.dropUpdate(from: from, to: to)
        } dropFinish: { from, to in
            model.dropFinish(from: from, to: to)
        }
    }
}
