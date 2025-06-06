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

extension Anytype_Rpc.Chat {
    public struct SubscribeToMessagePreviews: Sendable {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request: Sendable {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var subID: String = String()

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {}
      }

      public struct Response: Sendable {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response.Error {
          get {return _error ?? Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response.Error()}
          set {_error = newValue}
        }
        /// Returns true if `error` has been explicitly set.
        public var hasError: Bool {return self._error != nil}
        /// Clears the value of `error`. Subsequent reads from it will return its default value.
        public mutating func clearError() {self._error = nil}

        public var previews: [Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response.ChatPreview] = []

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct ChatPreview: @unchecked Sendable {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var spaceID: String {
            get {return _storage._spaceID}
            set {_uniqueStorage()._spaceID = newValue}
          }

          public var chatObjectID: String {
            get {return _storage._chatObjectID}
            set {_uniqueStorage()._chatObjectID = newValue}
          }

          public var message: Anytype_Model_ChatMessage {
            get {return _storage._message ?? Anytype_Model_ChatMessage()}
            set {_uniqueStorage()._message = newValue}
          }
          /// Returns true if `message` has been explicitly set.
          public var hasMessage: Bool {return _storage._message != nil}
          /// Clears the value of `message`. Subsequent reads from it will return its default value.
          public mutating func clearMessage() {_uniqueStorage()._message = nil}

          public var state: Anytype_Model_ChatState {
            get {return _storage._state ?? Anytype_Model_ChatState()}
            set {_uniqueStorage()._state = newValue}
          }
          /// Returns true if `state` has been explicitly set.
          public var hasState: Bool {return _storage._state != nil}
          /// Clears the value of `state`. Subsequent reads from it will return its default value.
          public mutating func clearState() {_uniqueStorage()._state = nil}

          public var dependencies: [SwiftProtobuf.Google_Protobuf_Struct] {
            get {return _storage._dependencies}
            set {_uniqueStorage()._dependencies = newValue}
          }

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public init() {}

          fileprivate var _storage = _StorageClass.defaultInstance
        }

        public struct Error: Sendable {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var code: Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response.Error.Code = .null

          public var description_p: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public enum Code: SwiftProtobuf.Enum, Swift.CaseIterable {
            public typealias RawValue = Int
            case null // = 0
            case unknownError // = 1

            /// ...
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
            public static let allCases: [Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response.Error.Code] = [
              .null,
              .unknownError,
              .badInput,
            ]

          }

          public init() {}
        }

        public init() {}

        fileprivate var _error: Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response.Error? = nil
      }

      public init() {}
    }    
}

extension Anytype_Rpc.Chat.SubscribeToMessagePreviews: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Rpc.Chat.protoMessageName + ".SubscribeToMessagePreviews"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    // Load everything into unknown fields
    while try decoder.nextFieldNumber() != nil {}
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Rpc.Chat.SubscribeToMessagePreviews, rhs: Anytype_Rpc.Chat.SubscribeToMessagePreviews) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Rpc.Chat.SubscribeToMessagePreviews.Request: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Rpc.Chat.SubscribeToMessagePreviews.protoMessageName + ".Request"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "subId"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.subID) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.subID.isEmpty {
      try visitor.visitSingularStringField(value: self.subID, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Rpc.Chat.SubscribeToMessagePreviews.Request, rhs: Anytype_Rpc.Chat.SubscribeToMessagePreviews.Request) -> Bool {
    if lhs.subID != rhs.subID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Rpc.Chat.SubscribeToMessagePreviews.protoMessageName + ".Response"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "error"),
    2: .same(proto: "previews"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._error) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.previews) }()
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
    if !self.previews.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.previews, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response, rhs: Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response) -> Bool {
    if lhs._error != rhs._error {return false}
    if lhs.previews != rhs.previews {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response.ChatPreview: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response.protoMessageName + ".ChatPreview"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "spaceId"),
    2: .same(proto: "chatObjectId"),
    3: .same(proto: "message"),
    4: .same(proto: "state"),
    5: .same(proto: "dependencies"),
  ]

  fileprivate class _StorageClass {
    var _spaceID: String = String()
    var _chatObjectID: String = String()
    var _message: Anytype_Model_ChatMessage? = nil
    var _state: Anytype_Model_ChatState? = nil
    var _dependencies: [SwiftProtobuf.Google_Protobuf_Struct] = []

    #if swift(>=5.10)
      // This property is used as the initial default value for new instances of the type.
      // The type itself is protecting the reference to its storage via CoW semantics.
      // This will force a copy to be made of this reference when the first mutation occurs;
      // hence, it is safe to mark this as `nonisolated(unsafe)`.
      static nonisolated(unsafe) let defaultInstance = _StorageClass()
    #else
      static let defaultInstance = _StorageClass()
    #endif

    private init() {}

    init(copying source: _StorageClass) {
      _spaceID = source._spaceID
      _chatObjectID = source._chatObjectID
      _message = source._message
      _state = source._state
      _dependencies = source._dependencies
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        // The use of inline closures is to circumvent an issue where the compiler
        // allocates stack space for every case branch when no optimizations are
        // enabled. https://github.com/apple/swift-protobuf/issues/1034
        switch fieldNumber {
        case 1: try { try decoder.decodeSingularStringField(value: &_storage._spaceID) }()
        case 2: try { try decoder.decodeSingularStringField(value: &_storage._chatObjectID) }()
        case 3: try { try decoder.decodeSingularMessageField(value: &_storage._message) }()
        case 4: try { try decoder.decodeSingularMessageField(value: &_storage._state) }()
        case 5: try { try decoder.decodeRepeatedMessageField(value: &_storage._dependencies) }()
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every if/case branch local when no optimizations
      // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
      // https://github.com/apple/swift-protobuf/issues/1182
      if !_storage._spaceID.isEmpty {
        try visitor.visitSingularStringField(value: _storage._spaceID, fieldNumber: 1)
      }
      if !_storage._chatObjectID.isEmpty {
        try visitor.visitSingularStringField(value: _storage._chatObjectID, fieldNumber: 2)
      }
      try { if let v = _storage._message {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
      } }()
      try { if let v = _storage._state {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
      } }()
      if !_storage._dependencies.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._dependencies, fieldNumber: 5)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response.ChatPreview, rhs: Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response.ChatPreview) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._spaceID != rhs_storage._spaceID {return false}
        if _storage._chatObjectID != rhs_storage._chatObjectID {return false}
        if _storage._message != rhs_storage._message {return false}
        if _storage._state != rhs_storage._state {return false}
        if _storage._dependencies != rhs_storage._dependencies {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response.Error: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response.protoMessageName + ".Error"
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

  public static func ==(lhs: Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response.Error, rhs: Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response.Error) -> Bool {
    if lhs.code != rhs.code {return false}
    if lhs.description_p != rhs.description_p {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response.Error.Code: SwiftProtobuf._ProtoNameProviding {
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
