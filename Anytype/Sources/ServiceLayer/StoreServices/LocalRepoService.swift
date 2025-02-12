import UIKit


/// Protocol provides local paths where user data stored
protocol LocalRepoServiceProtocol: Sendable {
    /// Returns local path to middleware files
    var middlewareRepoPath: String { get }
    
    var middlewareRepoURL: URL { get }
    
    /// Check if file exists on path
    /// - Parameter path: path where file should be
    func fileExists(on path: String) -> Bool
}


final class LocalRepoService: LocalRepoServiceProtocol, Sendable {
    
    var middlewareRepoPath: String {
        return middlewareRepoURL.path
    }
    
    var middlewareRepoURL: URL {
        return applicationDirectory.appendingPathComponent(LocalRepoService.middlewareRepoName)
    }
    
    func fileExists(on path: String) -> Bool {
       return FileManager.default.fileExists(atPath: path)
    }
}

private extension LocalRepoService {
    func setExcludeFromiCloudBackup(_ fileOrDirectoryURL: inout URL, isExcluded: Bool) throws {
       var values = URLResourceValues()
       values.isExcludedFromBackup = isExcluded
       try fileOrDirectoryURL.setResourceValues(values)
    }

    func getExcludeFromiCloudBackup(_ fileOrDirectoryURL: URL) throws -> Bool {
       let keySet: Set<URLResourceKey> = [.isExcludedFromBackupKey]

       return try
          fileOrDirectoryURL.resourceValues(forKeys: keySet).isExcludedFromBackup ?? false
    }

    var applicationDirectory: URL {
        let applicationDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        var anytypeDirectory = applicationDirectory.appendingPathComponent(LocalRepoService.anytypeRepoName)

        try? FileManager.default.createDirectory(at: anytypeDirectory, withIntermediateDirectories: true, attributes: nil)

        let isExclude = try? getExcludeFromiCloudBackup(anytypeDirectory)

        if isExclude == false {
            try? setExcludeFromiCloudBackup(&anytypeDirectory, isExcluded: true)
        }
        return anytypeDirectory
    }

    static let middlewareRepoName = "middleware-go"
    static let anytypeRepoName = "Anytype"
}
