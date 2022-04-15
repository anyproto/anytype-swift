import AnytypeCore

extension HomeViewModel {
    
    struct OpenedPageData {
        var data: EditorScreenData?
        var showing: Bool
        
        static var cached: OpenedPageData = {
            OpenedPageData(
                data: UserDefaultsConfig.screenDataFromLastSession,
                showing: UserDefaultsConfig.screenDataFromLastSession != nil
            )
        }()
    }
    
}

