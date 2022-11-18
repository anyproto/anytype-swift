import Foundation

extension HomeViewModel {
    static func makeForPreview() -> HomeViewModel {
        return HomeViewModel(
            homeBlockId: UUID().uuidString,
            editorBrowserAssembly: DI.makeForPreview().coordinatorsDI.browser,
            tabsSubsciptionDataBuilder: TabsSubscriptionDataBuilder(),
            profileSubsciptionDataBuilder: ProfileSubscriptionDataBuilder(),
            windowManager: DI.makeForPreview().coordinatorsDI.windowManager
        )
    }
}
