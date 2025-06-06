// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: pkg/lib/pb/model/protos/models.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

extension Anytype_Model_Account {
    public struct Config: Sendable {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    public var enableDataview: Bool = false

    public var enableDebug: Bool = false

    public var enablePrereleaseChannel: Bool = false

    public var enableSpaces: Bool = false

    public var extra: SwiftProtobuf.Google_Protobuf_Struct {
      get {return _extra ?? SwiftProtobuf.Google_Protobuf_Struct()}
      set {_extra = newValue}
    }
    /// Returns true if `extra` has been explicitly set.
    public var hasExtra: Bool {return self._extra != nil}
    /// Clears the value of `extra`. Subsequent reads from it will return its default value.
    public mutating func clearExtra() {self._extra = nil}

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}

    fileprivate var _extra: SwiftProtobuf.Google_Protobuf_Struct? = nil
  }    
}

extension Anytype_Model_Account.Config: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Model_Account.protoMessageName + ".Config"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "enableDataview"),
    2: .same(proto: "enableDebug"),
    3: .same(proto: "enablePrereleaseChannel"),
    4: .same(proto: "enableSpaces"),
    100: .same(proto: "extra"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBoolField(value: &self.enableDataview) }()
      case 2: try { try decoder.decodeSingularBoolField(value: &self.enableDebug) }()
      case 3: try { try decoder.decodeSingularBoolField(value: &self.enablePrereleaseChannel) }()
      case 4: try { try decoder.decodeSingularBoolField(value: &self.enableSpaces) }()
      case 100: try { try decoder.decodeSingularMessageField(value: &self._extra) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.enableDataview != false {
      try visitor.visitSingularBoolField(value: self.enableDataview, fieldNumber: 1)
    }
    if self.enableDebug != false {
      try visitor.visitSingularBoolField(value: self.enableDebug, fieldNumber: 2)
    }
    if self.enablePrereleaseChannel != false {
      try visitor.visitSingularBoolField(value: self.enablePrereleaseChannel, fieldNumber: 3)
    }
    if self.enableSpaces != false {
      try visitor.visitSingularBoolField(value: self.enableSpaces, fieldNumber: 4)
    }
    try { if let v = self._extra {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 100)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Model_Account.Config, rhs: Anytype_Model_Account.Config) -> Bool {
    if lhs.enableDataview != rhs.enableDataview {return false}
    if lhs.enableDebug != rhs.enableDebug {return false}
    if lhs.enablePrereleaseChannel != rhs.enablePrereleaseChannel {return false}
    if lhs.enableSpaces != rhs.enableSpaces {return false}
    if lhs._extra != rhs._extra {return false}
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

fileprivate let _protobuf_package = "anytype.model"
