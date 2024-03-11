import Foundation

extension FileManager {
    
    func createTempDirectory() -> URL {
        let path = temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? createDirectory(at: path, withIntermediateDirectories: true)
        return path
    }
}
