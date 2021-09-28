import AnytypeCore

extension HomeViewModel {
    struct OpenedPageData {
        var pageId: String
        var showingNewPage: Bool
        
        static var cached: OpenedPageData = {
            OpenedPageData(
                pageId: UserDefaultsConfig.lastOpenedPageId ?? "",
                showingNewPage: UserDefaultsConfig.lastOpenedPageId != nil
            )
        }()
    }
}
