import SwiftUI
import Amplitude


extension HomeTabsView {
    enum Tab {
        case favourites
        case recent
        case inbox
        case archive
    }
}

struct HomeTabsView: View {
    @EnvironmentObject var model: HomeViewModel
    @State private var tabSelection = Tab.favourites
    
    let offsetChanged: (CGPoint) -> Void
    
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
            HomeCollectionView(cellData: model.recentCellData, coordinator: model.coordinator, dragAndDropDelegate: nil, offsetChanged: offsetChanged)
                .tag(Tab.recent)
            HomeCollectionView(cellData: model.inboxCellData, coordinator: model.coordinator, dragAndDropDelegate: nil, offsetChanged: offsetChanged)
                .tag(Tab.inbox)
            HomeCollectionView(cellData: model.archiveCellData, coordinator: model.coordinator, dragAndDropDelegate: nil, offsetChanged: offsetChanged)
                .tag(Tab.archive)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onChange(of: tabSelection) { tab in
            switch tab {
            case .favourites:
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.favoritesPage)
                
                break // updates via subscriptions
            case .recent:
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.recentPage)

                model.updateRecentTab()
            case .inbox:
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.inboxPage)

                model.updateInboxTab()
            case .archive:
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.archivePage)

                model.updateArchiveTab()
            }
        }
    }
    
    
    private var tabHeaders: some View {
        HStack(){
            tabButton(text: "Favorites", tab: .favourites)
            tabButton(text: "Recent", tab: .recent)
            tabButton(text: "Inbox", tab: .inbox)
            tabButton(text: "Archive", tab: .archive)
        }
        .padding()
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
