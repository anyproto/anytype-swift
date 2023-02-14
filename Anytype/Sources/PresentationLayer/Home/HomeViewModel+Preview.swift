import Foundation

extension HomeViewModel {
    static func makeForPreview() -> HomeViewModel {
        return HomeViewModel(
            homeBlockId: UUID().uuidString,
            editorBrowserAssembly: DI.preview.coordinatorsDI.browser(),
            tabsSubsciptionDataBuilder: TabsSubscriptionDataBuilder(accountManager: DI.preview.serviceLocator.accountManager()),
            profileSubsciptionDataBuilder: ProfileSubscriptionDataBuilder(),
            newSearchModuleAssembly: DI.preview.modulesDI.newSearch(),
            applicationStateService: DI.preview.serviceLocator.applicationStateService(),
            accountManager: DI.preview.serviceLocator.accountManager(),
            middlewareConfigurationProvider: DI.preview.serviceLocator.middlewareConfigurationProvider()
        )
    }
}
