import Foundation

struct FileSizeConverter {
    private static var formatter: ByteCountFormatter = {
       let formatter = ByteCountFormatter.init()
       formatter.allowedUnits = .useAll
       formatter.allowsNonnumericFormatting = true
       formatter.countStyle = .file
       return formatter
    }()
    
    private init() {}
    
    static func convert(size: Int64) -> String {
        self.formatter.string(fromByteCount: size)
    }
}
