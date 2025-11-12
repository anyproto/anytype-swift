import Foundation

struct ListWidgetRowModel: Identifiable {
    let objectId: String
    let icon: Icon
    let title: String
    let description: String?
    let chatPreview: MessagePreviewModel?
    let onTap: @MainActor () -> Void
    
    var id: String { objectId }
}
