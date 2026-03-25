import Foundation

struct GroupChannelCreateData: Identifiable, Equatable, Hashable {
    let contacts: [Contact]
    var id: Int { hashValue }
}
