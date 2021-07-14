import SwiftProtobuf

/// Normalized field type from Google_Protobuf_Value
public enum BlockFieldType: Hashable, Equatable {
  case stringType(String)
  case doubleType(Double)
  case boolType(Bool)
  case mapType([String: BlockFieldType])
  case arrayType([BlockFieldType])

  public var stringValue: String? {
    guard case let .stringType(value) = self else { return nil }
    return value
  }
}

extension Google_Protobuf_Struct {

  public func toFieldTypeMap() -> [String: BlockFieldType] {
    fields.compactMapValues { googleProtobufValue in
      googleProtobufValue.convertToFieldType()
    }
  }
}

extension Google_Protobuf_Value {
  func convertToFieldType() -> BlockFieldType? {
    guard let kind = kind else { return nil }

    switch kind {
    case let .boolValue(value):
      return .boolType(value)
    case let .numberValue(value):
      return .doubleType(value)
    case let .stringValue(value):
      return .stringType(value)
    case let .structValue(googleProtobufStruct):
      return .mapType(googleProtobufStruct.toFieldTypeMap())
    case let .listValue(googleProtobufListValue):
      let normalizedType = googleProtobufListValue.values.compactMap { googleProtobufValue in
        googleProtobufValue.convertToFieldType()
      }
      return .arrayType(normalizedType)
    case .nullValue(_):
      return nil
    }
  }
}
