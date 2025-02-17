import SwiftUI
import UniformTypeIdentifiers

struct MessageLinkLocalBinaryFileView: View {
    
    let path: String
    let type: UTType
    let sizeInBytes: Int?
    let onTapRemove: () -> Void
    
    private var fileName: String { URL(fileURLWithPath: path).lastPathComponent }
    
    var body: some View {
        ChatInputObjectView(
            icon: .object(.file(mimeType: type.identifier, name: fileName)),
            title: fileName,
            description: Loc.file,
            size: size(),
            onTapRemove: onTapRemove
        )
    }
    
    private func size() -> String? {
        let sizeInBytes = Int64(sizeInBytes ?? 0)
        return sizeInBytes > 0 ? ByteCountFormatter.fileFormatter.string(fromByteCount: sizeInBytes) : nil
    }
}
