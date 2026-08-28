import Foundation

@MainActor
protocol SpaceHubModuleOutput: AnyObject {
    func onSelectCreatePersonalChannel()
    func onSelectCreateGroupChannel()
    func onSelectQrCodeJoin()
    func onSelectSpace(spaceId: String)
    func onOpenSpaceSettings(spaceId: String)
    func onSelectAppSettings()
    func vaultSearchModuleData(onClose: @escaping () -> Void) -> UnifiedSearchModuleData
}
