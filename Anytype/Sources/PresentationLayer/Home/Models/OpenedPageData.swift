import AnytypeCore

extension HomeViewModel {
    struct OpenedPageData {
        var pageId: String
        var showingNewPage: Bool
        
        static var cached: OpenedPageData = {
            OpenedPageData(
                pageId: UserDefaultsConfig.pageIdFromLastSession ?? "",
                showingNewPage: UserDefaultsConfig.pageIdFromLastSession != nil
            )
        }()
    }
}

