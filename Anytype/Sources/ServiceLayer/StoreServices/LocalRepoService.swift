import UIKit


/// Protocol provides local paths where user data stored
protocol LocalRepoServiceProtocol {
    /// Returns local path to middleware files
    var middlewareRepoPath: String { get }
    
    /// Returns path to dir with cashed images (for example user avatar)
    var imagePath: String { get }
    
    /// Check if file exists on path
    /// - Parameter path: path where file should be
    func fileExists(on path: String) -> Bool
}


class LocalRepoService: LocalRepoServiceProtocol {
    
    var middlewareRepoPath: String {
        return getDocumentsDirectory().appendingPathComponent("middleware-go").path
    }
    
    var imagePath: String {
        return getDocumentsDirectory().appendingPathComponent("images").path
    }
    
    func fileExists(on path: String) -> Bool {
       return FileManager.default.fileExists(atPath: path)
    }
}
