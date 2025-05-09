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

extension Anytype_Rpc.AI {
    public struct Autofill: Sendable {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request: Sendable {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var config: Anytype_Rpc.AI.ProviderConfig {
          get {return _config ?? Anytype_Rpc.AI.ProviderConfig()}
          set {_config = newValue}
        }
        /// Returns true if `config` has been explicitly set.
        public var hasConfig: Bool {return self._config != nil}
        /// Clears the value of `config`. Subsequent reads from it will return its default value.
        public mutating func clearConfig() {self._config = nil}

        public var mode: Anytype_Rpc.AI.Autofill.Request.AutofillMode = .tag

        public var options: [String] = []

        public var context: [String] = []

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public enum AutofillMode: SwiftProtobuf.Enum, Swift.CaseIterable {
          public typealias RawValue = Int
          case tag // = 0
          case relation // = 1
          case type // = 2
          case title // = 3

          /// ...
          case description_ // = 4
          case UNRECOGNIZED(Int)

          public init() {
            self = .tag
          }

          public init?(rawValue: Int) {
            switch rawValue {
            case 0: self = .tag
            case 1: self = .relation
            case 2: self = .type
            case 3: self = .title
            case 4: self = .description_
            default: self = .UNRECOGNIZED(rawValue)
            }
          }

          public var rawValue: Int {
            switch self {
            case .tag: return 0
            case .relation: return 1
            case .type: return 2
            case .title: return 3
            case .description_: return 4
            case .UNRECOGNIZED(let i): return i
            }
          }

          // The compiler won't synthesize support with the UNRECOGNIZED case.
          public static let allCases: [Anytype_Rpc.AI.Autofill.Request.AutofillMode] = [
            .tag,
            .relation,
            .type,
            .title,
            .description_,
          ]

        }

        public init() {}

        fileprivate var _config: Anytype_Rpc.AI.ProviderConfig? = nil
      }

      public struct Response: Sendable {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.AI.Autofill.Response.Error {
          get {return _error ?? Anytype_Rpc.AI.Autofill.Response.Error()}
          set {_error = newValue}
        }
        /// Returns true if `error` has been explicitly set.
        public var hasError: Bool {return self._error != nil}
        /// Clears the value of `error`. Subsequent reads from it will return its default value.
        public mutating func clearError() {self._error = nil}

        public var text: String = String()

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Error: Sendable {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var code: Anytype_Rpc.AI.Autofill.Response.Error.Code = .null

          public var description_p: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public enum Code: SwiftProtobuf.Enum, Swift.CaseIterable {
            public typealias RawValue = Int
            case null // = 0
            case unknownError // = 1
            case badInput // = 2
            case rateLimitExceeded // = 100
            case endpointNotReachable // = 101
            case modelNotFound // = 102

            /// ...
            case authRequired // = 103
            case UNRECOGNIZED(Int)

            public init() {
              self = .null
            }

            public init?(rawValue: Int) {
              switch rawValue {
              case 0: self = .null
              case 1: self = .unknownError
              case 2: self = .badInput
              case 100: self = .rateLimitExceeded
              case 101: self = .endpointNotReachable
              case 102: self = .modelNotFound
              case 103: self = .authRequired
              default: self = .UNRECOGNIZED(rawValue)
              }
            }

            public var rawValue: Int {
              switch self {
              case .null: return 0
              case .unknownError: return 1
              case .badInput: return 2
              case .rateLimitExceeded: return 100
              case .endpointNotReachable: return 101
              case .modelNotFound: return 102
              case .authRequired: return 103
              case .UNRECOGNIZED(let i): return i
              }
            }

            // The compiler won't synthesize support with the UNRECOGNIZED case.
            public static let allCases: [Anytype_Rpc.AI.Autofill.Response.Error.Code] = [
              .null,
              .unknownError,
              .badInput,
              .rateLimitExceeded,
              .endpointNotReachable,
              .modelNotFound,
              .authRequired,
            ]

          }

          public init() {}
        }

        public init() {}

        fileprivate var _error: Anytype_Rpc.AI.Autofill.Response.Error? = nil
      }

      public init() {}
    }    
}

extension Anytype_Rpc.AI.Autofill: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Rpc.AI.protoMessageName + ".Autofill"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    // Load everything into unknown fields
    while try decoder.nextFieldNumber() != nil {}
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Rpc.AI.Autofill, rhs: Anytype_Rpc.AI.Autofill) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Rpc.AI.Autofill.Request: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Rpc.AI.Autofill.protoMessageName + ".Request"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "config"),
    2: .same(proto: "mode"),
    3: .same(proto: "options"),
    4: .same(proto: "context"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._config) }()
      case 2: try { try decoder.decodeSingularEnumField(value: &self.mode) }()
      case 3: try { try decoder.decodeRepeatedStringField(value: &self.options) }()
      case 4: try { try decoder.decodeRepeatedStringField(value: &self.context) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._config {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if self.mode != .tag {
      try visitor.visitSingularEnumField(value: self.mode, fieldNumber: 2)
    }
    if !self.options.isEmpty {
      try visitor.visitRepeatedStringField(value: self.options, fieldNumber: 3)
    }
    if !self.context.isEmpty {
      try visitor.visitRepeatedStringField(value: self.context, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Rpc.AI.Autofill.Request, rhs: Anytype_Rpc.AI.Autofill.Request) -> Bool {
    if lhs._config != rhs._config {return false}
    if lhs.mode != rhs.mode {return false}
    if lhs.options != rhs.options {return false}
    if lhs.context != rhs.context {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Rpc.AI.Autofill.Request.AutofillMode: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "TAG"),
    1: .same(proto: "RELATION"),
    2: .same(proto: "TYPE"),
    3: .same(proto: "TITLE"),
    4: .same(proto: "DESCRIPTION"),
  ]
}

extension Anytype_Rpc.AI.Autofill.Response: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Rpc.AI.Autofill.protoMessageName + ".Response"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "error"),
    2: .same(proto: "text"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._error) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.text) }()
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
    if !self.text.isEmpty {
      try visitor.visitSingularStringField(value: self.text, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Rpc.AI.Autofill.Response, rhs: Anytype_Rpc.AI.Autofill.Response) -> Bool {
    if lhs._error != rhs._error {return false}
    if lhs.text != rhs.text {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Rpc.AI.Autofill.Response.Error: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Rpc.AI.Autofill.Response.protoMessageName + ".Error"
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

  public static func ==(lhs: Anytype_Rpc.AI.Autofill.Response.Error, rhs: Anytype_Rpc.AI.Autofill.Response.Error) -> Bool {
    if lhs.code != rhs.code {return false}
    if lhs.description_p != rhs.description_p {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Rpc.AI.Autofill.Response.Error.Code: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "NULL"),
    1: .same(proto: "UNKNOWN_ERROR"),
    2: .same(proto: "BAD_INPUT"),
    100: .same(proto: "RATE_LIMIT_EXCEEDED"),
    101: .same(proto: "ENDPOINT_NOT_REACHABLE"),
    102: .same(proto: "MODEL_NOT_FOUND"),
    103: .same(proto: "AUTH_REQUIRED"),
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
