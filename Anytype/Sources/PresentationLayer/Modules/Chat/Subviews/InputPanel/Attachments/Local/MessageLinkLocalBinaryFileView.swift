import SwiftUI
import UniformTypeIdentifiers

struct MessageLinkLocalBinaryFileView: View {
    
    let path: String
    let type: UTType
    let sizeInBytes: Int?
    let onTapRemove: () -> Void
    
    private var fileName: String { URL(fileURLWithPath: path).lastPathComponent }
    
    var body: some View {
        MessageLinkObjectView(
            icon: .object(.file(mimeType: type.identifier, name: fileName)),
            title: fileName,
            description: Loc.file,
            size: size(),
            onTapRemove: onTapRemove
        )
    }
    
    private func size() -> String? {
        guard let sizeInBytes, sizeInBytes > 0 else { return nil }
        return ByteCountFormatter.fileFormatter.string(fromByteCount: Int64(sizeInBytes))
    }
}
