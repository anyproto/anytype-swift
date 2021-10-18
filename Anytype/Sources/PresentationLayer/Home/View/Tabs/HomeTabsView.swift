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
        
    private let blurStyle = UIBlurEffect.Style.systemMaterial
    
    var body: some View {
        VStack(spacing: 0) {
            tabHeaders
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
        }
    }
    
    private var tabs: some View {
        TabView(selection: $tabSelection) {
            HomeCollectionView(cellData: model.nonArchivedFavoritesCellData, coordinator: model.coordinator, dragAndDropDelegate: model, offsetChanged: offsetChanged)
            .tag(Tab.favourites)
            HomeCollectionView(cellData: model.historyCellData, coordinator: model.coordinator, dragAndDropDelegate: nil, offsetChanged: offsetChanged)
                .tag(Tab.history)
            HomeCollectionView(cellData: model.binCellData, coordinator: model.coordinator, dragAndDropDelegate: nil, offsetChanged: offsetChanged)
                .tag(Tab.bin)
        }
        .background(BlurEffect())
        .blurEffectStyle(blurStyle)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        
        .onChange(of: tabSelection) { tab in
            UserDefaultsConfig.selectedTab = tab
            onTabSelection()
        }
    }
    
    
    private var tabHeaders: some View {
        // Scroll view hack, vibrancy effect do not work without it
        ScrollView([]) {
            HStack(spacing: 20) {
                tabButton(text: "Favorites".localized, tab: .favourites)
                tabButton(text: "History".localized, tab: .history) {
                    if tabSelection == .history { onTabSelection() } // reload data on button tap
                }
                tabButton(text: "Bin".localized, tab: .bin) {
                    if tabSelection == .bin { onTabSelection() } // reload data on button tap
                }
                Spacer()
            }
            .padding(.leading, 20)
            .frame(height: 72, alignment: .center)
            .background(BlurEffect())
            .blurEffectStyle(blurStyle)
        }
        .frame(height: 72, alignment: .center)
    }
    
    private func tabButton(text: String, tab: Tab, action: (() -> ())? = nil) -> some View {
        Button(
            action: {
                withAnimation(.spring()) {
                    tabSelection = tab
                    action?()
                }
            }
        ) {
            HomeTabsHeaderText(text: text, isSelected: tabSelection == tab)
        }
    }
    
    private func onTabSelection() {
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
