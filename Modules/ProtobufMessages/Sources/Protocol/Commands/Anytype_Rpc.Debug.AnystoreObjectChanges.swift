// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: pb/protos/commands.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

extension Anytype_Rpc.Debug {
    public struct AnystoreObjectChanges: Sendable {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request: Sendable {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var objectID: String = String()

        public var orderBy: Anytype_Rpc.Debug.AnystoreObjectChanges.Request.OrderBy = .orderID

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public enum OrderBy: SwiftProtobuf.Enum, Swift.CaseIterable {
          public typealias RawValue = Int
          case orderID // = 0
          case iterationOrder // = 1
          case UNRECOGNIZED(Int)

          public init() {
            self = .orderID
          }

          public init?(rawValue: Int) {
            switch rawValue {
            case 0: self = .orderID
            case 1: self = .iterationOrder
            default: self = .UNRECOGNIZED(rawValue)
            }
          }

          public var rawValue: Int {
            switch self {
            case .orderID: return 0
            case .iterationOrder: return 1
            case .UNRECOGNIZED(let i): return i
            }
          }

          // The compiler won't synthesize support with the UNRECOGNIZED case.
          public static let allCases: [Anytype_Rpc.Debug.AnystoreObjectChanges.Request.OrderBy] = [
            .orderID,
            .iterationOrder,
          ]

        }

        public init() {}
      }

      public struct Response: Sendable {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Debug.AnystoreObjectChanges.Response.Error {
          get {return _error ?? Anytype_Rpc.Debug.AnystoreObjectChanges.Response.Error()}
          set {_error = newValue}
        }
        /// Returns true if `error` has been explicitly set.
        public var hasError: Bool {return self._error != nil}
        /// Clears the value of `error`. Subsequent reads from it will return its default value.
        public mutating func clearError() {self._error = nil}

        public var changes: [Anytype_Rpc.Debug.AnystoreObjectChanges.Response.Change] = []

        public var wrongOrder: Bool = false

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Change: Sendable {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var changeID: String = String()

          public var orderID: String = String()

          public var error: String = String()

          public var change: SwiftProtobuf.Google_Protobuf_Struct {
            get {return _change ?? SwiftProtobuf.Google_Protobuf_Struct()}
            set {_change = newValue}
          }
          /// Returns true if `change` has been explicitly set.
          public var hasChange: Bool {return self._change != nil}
          /// Clears the value of `change`. Subsequent reads from it will return its default value.
          public mutating func clearChange() {self._change = nil}

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public init() {}

          fileprivate var _change: SwiftProtobuf.Google_Protobuf_Struct? = nil
        }

        public struct Error: Sendable {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var code: Anytype_Rpc.Debug.AnystoreObjectChanges.Response.Error.Code = .null

          public var description_p: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public enum Code: SwiftProtobuf.Enum, Swift.CaseIterable {
            public typealias RawValue = Int
            case null // = 0
            case unknownError // = 1
            case badInput // = 2
            case UNRECOGNIZED(Int)

            public init() {
              self = .null
            }

            public init?(rawValue: Int) {
              switch rawValue {
              case 0: self = .null
              case 1: self = .unknownError
              case 2: self = .badInput
              default: self = .UNRECOGNIZED(rawValue)
              }
            }

            public var rawValue: Int {
              switch self {
              case .null: return 0
              case .unknownError: return 1
              case .badInput: return 2
              case .UNRECOGNIZED(let i): return i
              }
            }

            // The compiler won't synthesize support with the UNRECOGNIZED case.
            public static let allCases: [Anytype_Rpc.Debug.AnystoreObjectChanges.Response.Error.Code] = [
              .null,
              .unknownError,
              .badInput,
            ]

          }

          public init() {}
        }

        public init() {}

        fileprivate var _error: Anytype_Rpc.Debug.AnystoreObjectChanges.Response.Error? = nil
      }

      public init() {}
    }    
}

extension Anytype_Rpc.Debug.AnystoreObjectChanges: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Rpc.Debug.protoMessageName + ".AnystoreObjectChanges"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    // Load everything into unknown fields
    while try decoder.nextFieldNumber() != nil {}
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Rpc.Debug.AnystoreObjectChanges, rhs: Anytype_Rpc.Debug.AnystoreObjectChanges) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Rpc.Debug.AnystoreObjectChanges.Request: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Rpc.Debug.AnystoreObjectChanges.protoMessageName + ".Request"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "objectId"),
    2: .same(proto: "orderBy"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.objectID) }()
      case 2: try { try decoder.decodeSingularEnumField(value: &self.orderBy) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.objectID.isEmpty {
      try visitor.visitSingularStringField(value: self.objectID, fieldNumber: 1)
    }
    if self.orderBy != .orderID {
      try visitor.visitSingularEnumField(value: self.orderBy, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Rpc.Debug.AnystoreObjectChanges.Request, rhs: Anytype_Rpc.Debug.AnystoreObjectChanges.Request) -> Bool {
    if lhs.objectID != rhs.objectID {return false}
    if lhs.orderBy != rhs.orderBy {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Rpc.Debug.AnystoreObjectChanges.Request.OrderBy: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "ORDER_ID"),
    1: .same(proto: "ITERATION_ORDER"),
  ]
}

extension Anytype_Rpc.Debug.AnystoreObjectChanges.Response: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Rpc.Debug.AnystoreObjectChanges.protoMessageName + ".Response"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "error"),
    2: .same(proto: "changes"),
    3: .same(proto: "wrongOrder"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._error) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.changes) }()
      case 3: try { try decoder.decodeSingularBoolField(value: &self.wrongOrder) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._error {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if !self.changes.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.changes, fieldNumber: 2)
    }
    if self.wrongOrder != false {
      try visitor.visitSingularBoolField(value: self.wrongOrder, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Rpc.Debug.AnystoreObjectChanges.Response, rhs: Anytype_Rpc.Debug.AnystoreObjectChanges.Response) -> Bool {
    if lhs._error != rhs._error {return false}
    if lhs.changes != rhs.changes {return false}
    if lhs.wrongOrder != rhs.wrongOrder {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Rpc.Debug.AnystoreObjectChanges.Response.Change: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Rpc.Debug.AnystoreObjectChanges.Response.protoMessageName + ".Change"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "changeId"),
    2: .same(proto: "orderId"),
    3: .same(proto: "error"),
    4: .same(proto: "change"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.changeID) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.orderID) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.error) }()
      case 4: try { try decoder.decodeSingularMessageField(value: &self._change) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.changeID.isEmpty {
      try visitor.visitSingularStringField(value: self.changeID, fieldNumber: 1)
    }
    if !self.orderID.isEmpty {
      try visitor.visitSingularStringField(value: self.orderID, fieldNumber: 2)
    }
    if !self.error.isEmpty {
      try visitor.visitSingularStringField(value: self.error, fieldNumber: 3)
    }
    try { if let v = self._change {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Rpc.Debug.AnystoreObjectChanges.Response.Change, rhs: Anytype_Rpc.Debug.AnystoreObjectChanges.Response.Change) -> Bool {
    if lhs.changeID != rhs.changeID {return false}
    if lhs.orderID != rhs.orderID {return false}
    if lhs.error != rhs.error {return false}
    if lhs._change != rhs._change {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Rpc.Debug.AnystoreObjectChanges.Response.Error: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Rpc.Debug.AnystoreObjectChanges.Response.protoMessageName + ".Error"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "code"),
    2: .same(proto: "description"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularEnumField(value: &self.code) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.description_p) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.code != .null {
      try visitor.visitSingularEnumField(value: self.code, fieldNumber: 1)
    }
    if !self.description_p.isEmpty {
      try visitor.visitSingularStringField(value: self.description_p, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Rpc.Debug.AnystoreObjectChanges.Response.Error, rhs: Anytype_Rpc.Debug.AnystoreObjectChanges.Response.Error) -> Bool {
    if lhs.code != rhs.code {return false}
    if lhs.description_p != rhs.description_p {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Rpc.Debug.AnystoreObjectChanges.Response.Error.Code: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "NULL"),
    1: .same(proto: "UNKNOWN_ERROR"),
    2: .same(proto: "BAD_INPUT"),
  ]
}

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "anytype"
