import Foundation

final class FileDownloader {
    let session = URLSession.shared

    func downloadData(url: URL) async throws -> Data {
        let (data, _) = try await session.data(from: url)

        return data
    }
}
