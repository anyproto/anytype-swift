import Foundation

struct GroupChannelCreateData: Identifiable, Equatable, Hashable {
    let contacts: [Contact]
    let writersLimit: Int?
    var id: Int { hashValue }
}
