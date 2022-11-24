import Foundation

extension HomeViewModel {
    static func makeForPreview() -> HomeViewModel {
        return HomeViewModel(
            homeBlockId: UUID().uuidString,
            editorBrowserAssembly: CoordinatorsDI.makeForPreview().browser,
            tabsSubsciptionDataBuilder: TabsSubscriptionDataBuilder(),
            profileSubsciptionDataBuilder: ProfileSubscriptionDataBuilder()
        )
    }
}
