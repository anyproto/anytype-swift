import Foundation

struct SearchModuleModel: Identifiable, Hashable {
    let spaceId: String
    let title: String?
    @EquatableNoop var onSelect: (ObjectSearchData) -> Void
    
    var id: Int { hashValue }
}
