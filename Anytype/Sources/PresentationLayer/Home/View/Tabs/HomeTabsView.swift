import SwiftUI
import Amplitude
import SwiftUIVisualEffects
import AnytypeCore

extension HomeTabsView {
    enum Tab: String {
        case favourites
        case history
        case bin
    }
}

struct HomeTabsView: View {
    @EnvironmentObject var model: HomeViewModel
    @State private var tabSelection = UserDefaultsConfig.selectedTab
    
    let offsetChanged: (CGPoint) -> Void
    let onDrag: (CGSize) -> Void
    let onDragEnd: (CGSize) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HomeTabsHeader(tabSelection: $tabSelection, onTabSelection: onTabSelection)
                .highPriorityGesture(
                    DragGesture(coordinateSpace: .named(model.bottomSheetCoordinateSpaceName))
                        .onChanged { gesture in
                            onDrag(gesture.translation)
                        }
                        .onEnded{ gesture in
                            onDragEnd(gesture.translation)
                        }
                )
            tabs
            selectionViewStub
        }
    }
    
    // stub for DashboardSelectionActionsView
    private var selectionViewStub: some View {
        Group {
            if model.isSelectionMode {
                Color.clear.frame(height: DashboardSelectionActionsView.height)
            } else {
                EmptyView()
            }
        }
    }
    
    private var tabs: some View {
        TabView(selection: $tabSelection) {
            HomeCollectionView(
                cellData: model.notDeletedFavoritesCellData,
                coordinator: model.coordinator,
                dragAndDropDelegate: model,
                offsetChanged: offsetChanged,
                onTap: { data in
                    model.showPage(pageId: data.destinationId)
                }
            )
            .tag(Tab.favourites)
            
            HomeCollectionView(
                cellData: model.historyCellData,
                coordinator: model.coordinator,
                dragAndDropDelegate: nil, // no dnd
                offsetChanged: offsetChanged,
                onTap: { data in
                    model.showPage(pageId: data.destinationId)
                }
            )
            .tag(Tab.history)
            
            HomeCollectionView(
                cellData: model.binCellData,
                coordinator: model.coordinator,
                dragAndDropDelegate: nil, // no dnd
                offsetChanged: offsetChanged,
                onTap: { data in
                    UISelectionFeedbackGenerator().selectionChanged()
                    model.select(data: data)
                }
            )
            .tag(Tab.bin)
        }
        .background(BlurEffect())
        .blurEffectStyle(UIBlurEffect.Style.systemMaterial)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        
        .onChange(of: tabSelection) { tab in
            UserDefaultsConfig.selectedTab = tab
            onTabSelection()
        }
    }
    
    private func onTabSelection() {
        model.selectAll(false)
        
        switch tabSelection {
        case .favourites:
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.favoritesTabSelected)
            
            break // updates via subscriptions
        case .history:
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.recentTabSelected)

            model.updateHistoryTab()
        case .bin:
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.archiveTabSelected)

            model.updateBinTab()
        }
    }
}

struct HomeTabsView_Previews: PreviewProvider {
    static var model: HomeViewModel {
        let model = HomeViewModel()
        return model
    }
    
    static var previews: some View {
        ZStack {
            Color.blue
            HomeTabsView(offsetChanged: { _ in }, onDrag: { _ in}, onDragEnd: { _ in })
                .environmentObject(model)
        }
    }
}
