import Foundation

extension HomeViewModel {
    static func makeForPreview() -> HomeViewModel {
        return HomeViewModel(
            homeBlockId: UUID().uuidString,
            editorBrowserAssembly: DI.makeForPreview().coordinatorsDI.browser,
            tabsSubsciptionDataBuilder: TabsSubscriptionDataBuilder(),
            profileSubsciptionDataBuilder: ProfileSubscriptionDataBuilder(),
            newSearchModuleAssembly: DI.makeForPreview().modulesDI.newSearch,
            windowManager: DI.makeForPreview().coordinatorsDI.windowManager
        )
    }
}
