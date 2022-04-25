import Foundation

protocol FileDownloadingModuleOutput: AnyObject {
 
    func didDownloadFileTo(_ url: URL)
    
}
