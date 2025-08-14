import Services
import SwiftProtobuf

extension DataviewFilter {
    func updated(
        condition: DataviewFilter.Condition? = nil,
        value: SwiftProtobuf.Google_Protobuf_Value? = nil,
        quickOption: DataviewFilter.QuickOption? = nil,
        format: PropertyFormat? = nil
    ) -> DataviewFilter {
        DataviewFilter(
            relationKey: self.relationKey,
            condition: condition ?? self.condition,
            value: value ?? self.value,
            quickOption: quickOption ?? self.quickOption,
            format: format?.asMiddleware ?? self.format
        )
    }
}
