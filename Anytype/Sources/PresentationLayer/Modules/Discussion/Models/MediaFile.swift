import Foundation
import CoreTransferable
import UniformTypeIdentifiers

struct MediaFileUrl: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .data) { data in
            SentTransferredFile(data.url)
        } importing: { received in
            
            let fileName = received.file.lastPathComponent
            let documentDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
            try? FileManager.default.createDirectory(at: documentDir, withIntermediateDirectories: true)
            
            let url = documentDir.appendingPathComponent(fileName, isDirectory: false)
            
            try FileManager.default.copyItem(at: received.file, to: url)
            
            return Self.init(url: url)
        }
    }
}
