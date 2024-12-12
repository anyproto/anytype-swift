import Foundation

extension ByteCountFormatter: @unchecked @retroactive Sendable {
    static let fileFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter.init()
        formatter.allowedUnits = .useAll
        formatter.allowsNonnumericFormatting = true
        formatter.countStyle = .binary
        return formatter
    }()
}
