import Foundation

struct HomeWidgetsBottomPanelViewModel {
    
    struct Button: Identifiable {
        let id: String
        let image: ImageAsset
        let onTap: () -> Void
    }
    
    let buttons: [Button]
}
