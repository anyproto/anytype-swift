import Foundation

struct ListWidgetRowModel: Identifiable {
    let objectId: String
    let icon: Icon?
    let title: String
    let description: String?
    let onTap: () -> Void
    
    var id: String { objectId }
}
