import Foundation
import SwiftProtobuf

enum RelationValueConverter {
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()
    
    static func dateString(from value: Google_Protobuf_Value?) -> String? {
        guard let number = value?.safeDoubleValue else { return nil }
        
        let date = Date(timeIntervalSince1970: number)
        
        return dateFormatter.string(from: date)
    }
    
}
