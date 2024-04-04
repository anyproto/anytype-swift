import Foundation

struct SpaceSearchData: Identifiable, Hashable {
    var id: Int { hashValue }
    
    @EquatableNoop var onSelect: (SpaceView) -> Void
}
