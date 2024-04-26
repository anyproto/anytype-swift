import Foundation

@MainActor
protocol TextRelationActionButtonViewModelDelegate: AnyObject {
    
    func canOpenUrl(_ url: URL) -> Bool
    func openUrl(_ url: URL)
    
}
