// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: pb/protos/events.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import SwiftProtobuf

extension Anytype_Event.Chat {
    public struct Add: @unchecked Sendable {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var id: String {
        get {return _storage._id}
        set {_uniqueStorage()._id = newValue}
      }

      public var orderID: String {
        get {return _storage._orderID}
        set {_uniqueStorage()._orderID = newValue}
      }

      public var afterOrderID: String {
        get {return _storage._afterOrderID}
        set {_uniqueStorage()._afterOrderID = newValue}
      }

      public var message: Anytype_Model_ChatMessage {
        get {return _storage._message ?? Anytype_Model_ChatMessage()}
        set {_uniqueStorage()._message = newValue}
      }
      /// Returns true if `message` has been explicitly set.
      public var hasMessage: Bool {return _storage._message != nil}
      /// Clears the value of `message`. Subsequent reads from it will return its default value.
      public mutating func clearMessage() {_uniqueStorage()._message = nil}

      public var subIds: [String] {
        get {return _storage._subIds}
        set {_uniqueStorage()._subIds = newValue}
      }

      public var dependencies: [SwiftProtobuf.Google_Protobuf_Struct] {
        get {return _storage._dependencies}
        set {_uniqueStorage()._dependencies = newValue}
      }

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public init() {}

      fileprivate var _storage = _StorageClass.defaultInstance
    }    
}

extension Anytype_Event.Chat.Add: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Event.Chat.protoMessageName + ".Add"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "orderId"),
    6: .same(proto: "afterOrderId"),
    3: .same(proto: "message"),
    4: .same(proto: "subIds"),
    5: .same(proto: "dependencies"),
  ]

  fileprivate class _StorageClass {
    var _id: String = String()
    var _orderID: String = String()
    var _afterOrderID: String = String()
    var _message: Anytype_Model_ChatMessage? = nil
    var _subIds: [String] = []
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
      _id = source._id
      _orderID = source._orderID
      _afterOrderID = source._afterOrderID
      _message = source._message
      _subIds = source._subIds
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
        case 1: try { try decoder.decodeSingularStringField(value: &_storage._id) }()
        case 2: try { try decoder.decodeSingularStringField(value: &_storage._orderID) }()
        case 3: try { try decoder.decodeSingularMessageField(value: &_storage._message) }()
        case 4: try { try decoder.decodeRepeatedStringField(value: &_storage._subIds) }()
        case 5: try { try decoder.decodeRepeatedMessageField(value: &_storage._dependencies) }()
        case 6: try { try decoder.decodeSingularStringField(value: &_storage._afterOrderID) }()
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
      if !_storage._id.isEmpty {
        try visitor.visitSingularStringField(value: _storage._id, fieldNumber: 1)
      }
      if !_storage._orderID.isEmpty {
        try visitor.visitSingularStringField(value: _storage._orderID, fieldNumber: 2)
      }
      try { if let v = _storage._message {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
      } }()
      if !_storage._subIds.isEmpty {
        try visitor.visitRepeatedStringField(value: _storage._subIds, fieldNumber: 4)
      }
      if !_storage._dependencies.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._dependencies, fieldNumber: 5)
      }
      if !_storage._afterOrderID.isEmpty {
        try visitor.visitSingularStringField(value: _storage._afterOrderID, fieldNumber: 6)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Event.Chat.Add, rhs: Anytype_Event.Chat.Add) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._id != rhs_storage._id {return false}
        if _storage._orderID != rhs_storage._orderID {return false}
        if _storage._afterOrderID != rhs_storage._afterOrderID {return false}
        if _storage._message != rhs_storage._message {return false}
        if _storage._subIds != rhs_storage._subIds {return false}
        if _storage._dependencies != rhs_storage._dependencies {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
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
