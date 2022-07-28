import Foundation

extension HomeViewModel {
    static func makeForPreview() -> HomeViewModel {
        return HomeViewModel(
            homeBlockId: UUID().uuidString,
            editorBrowserAssembly: CoordinatorsAssembly.makeForPreview().browser
        )
    }
}
