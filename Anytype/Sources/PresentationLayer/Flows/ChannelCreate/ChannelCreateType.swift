import Foundation

enum ChannelCreateType: String, Identifiable {
    case personal
    case group

    var id: String { rawValue }
}
