import Foundation

struct FileSizeConverter {
    private static var formatter: ByteCountFormatter = {
       let formatter = ByteCountFormatter.init()
       formatter.allowedUnits = .useAll
       formatter.allowsNonnumericFormatting = true
       formatter.countStyle = .file
       return formatter
    }()
    
    static func convert(size: Int) -> String {
        self.formatter.string(fromByteCount: Int64(size))
    }
}
