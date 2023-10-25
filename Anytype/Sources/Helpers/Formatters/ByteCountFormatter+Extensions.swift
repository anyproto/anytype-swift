import Foundation

extension ByteCountFormatter {
    static var fileFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter.init()
        formatter.allowedUnits = .useAll
        formatter.allowsNonnumericFormatting = true
        formatter.countStyle = .decimal
        return formatter
    }()
}
