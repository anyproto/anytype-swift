import Foundation

extension NSItemProvider {
    
    private enum LoadFileRepresentationError: Error {
        case undefined
    }
    
    func loadFileRepresentation(forTypeIdentifier typeIdentifier: String, directory: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let url = url {
                    let destination = directory.appendingPathComponent(url.lastPathComponent, isDirectory: false)
                    do {
                        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
                        try FileManager.default.copyItem(at: url, to: destination)
                        continuation.resume(returning: destination)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                } else {
                    continuation.resume(throwing: LoadFileRepresentationError.undefined)
                }
            }
        }
    }
}
