import Foundation

@MainActor
protocol FileDownloadingModuleOutput: AnyObject {
 
    func didDownloadFileTo(_ url: URL)
    func didAskToClose()
    
}
