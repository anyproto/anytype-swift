import SwiftUI
import Amplitude
import SwiftUIVisualEffects
import AnytypeCore

extension HomeTabsView {
    enum Tab: String {
        case favourites
        case history
        case archive
    }
}

struct HomeTabsView: View {
    @EnvironmentObject var model: HomeViewModel
    @State private var tabSelection = UserDefaultsConfig.selectedTab
    
    let offsetChanged: (CGPoint) -> Void
    private let blurStyle = UIBlurEffect.Style.systemMaterial
    
    var body: some View {
        VStack(spacing: 0) {
            tabHeaders
            tabs
        }
    }
    
    private var tabs: some View {
        TabView(selection: $tabSelection) {
            HomeCollectionView(cellData: model.nonArchivedFavoritesCellData, coordinator: model.coordinator, dragAndDropDelegate: model, offsetChanged: offsetChanged)
            .tag(Tab.favourites)
            HomeCollectionView(cellData: model.historyCellData, coordinator: model.coordinator, dragAndDropDelegate: nil, offsetChanged: offsetChanged)
                .tag(Tab.history)
            HomeCollectionView(cellData: model.archiveCellData, coordinator: model.coordinator, dragAndDropDelegate: nil, offsetChanged: offsetChanged)
                .tag(Tab.archive)
        }
        .background(BlurEffect())
        .blurEffectStyle(blurStyle)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onChange(of: tabSelection) { tab in
            UserDefaultsConfig.selectedTab = tab
            
            switch tab {
            case .favourites:
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.favoritesTabSelected)
                
                break // updates via subscriptions
            case .history:
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.recentTabSelected)

                model.updateHistoryTab()
            case .archive:
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.archiveTabSelected)

                model.updateArchiveTab()
            }
        }
    }
    
    
    private var tabHeaders: some View {
        // Scroll view hack, vibrancy effect do not work without it
        ScrollView([]) {
            HStack(spacing: 20) {
                tabButton(text: "Favorites", tab: .favourites)
                tabButton(text: "History", tab: .history)
                tabButton(text: "Archive", tab: .archive)
                Spacer()
            }
            .padding(.leading, 20)
            .frame(height: 72, alignment: .center)
            .background(BlurEffect())
            .blurEffectStyle(blurStyle)
        }
        .frame(height: 72, alignment: .center)
    }
    
    private func tabButton(text: String, tab: Tab) -> some View {
        Button(
            action: {
                withAnimation(.spring()) {
                    tabSelection = tab
                }
            }
        ) {
            HomeTabsHeaderText(text: text, isSelected: tabSelection == tab)
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
            HomeTabsView(offsetChanged: { _ in })
                .environmentObject(model)
        }
    }
}
