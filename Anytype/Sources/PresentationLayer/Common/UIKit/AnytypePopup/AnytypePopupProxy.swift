import Foundation

@MainActor
protocol AnytypePopupProxy: NSObject {
    func updateBottomInset()
    func updateLayout(_ animated: Bool)
    func close()
}
