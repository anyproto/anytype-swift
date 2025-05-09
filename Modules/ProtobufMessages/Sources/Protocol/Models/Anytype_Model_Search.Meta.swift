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

extension Anytype_Model_Search {
    public struct Meta: Sendable {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    /// truncated text with highlights
    public var highlight: String = String()

    /// ranges of the highlight in the text (using utf-16 runes)
    public var highlightRanges: [Anytype_Model_Range] = []

    /// block id where the highlight has been found
    public var blockID: String = String()

    /// relation key of the block where the highlight has been found
    public var relationKey: String = String()

    /// contains details for dependent object. E.g. relation option or type. todo: rename to dependantDetails
    public var relationDetails: SwiftProtobuf.Google_Protobuf_Struct {
      get {return _relationDetails ?? SwiftProtobuf.Google_Protobuf_Struct()}
      set {_relationDetails = newValue}
    }
    /// Returns true if `relationDetails` has been explicitly set.
    public var hasRelationDetails: Bool {return self._relationDetails != nil}
    /// Clears the value of `relationDetails`. Subsequent reads from it will return its default value.
    public mutating func clearRelationDetails() {self._relationDetails = nil}

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}

    fileprivate var _relationDetails: SwiftProtobuf.Google_Protobuf_Struct? = nil
  }    
}

extension Anytype_Model_Search.Meta: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Model_Search.protoMessageName + ".Meta"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "highlight"),
    2: .same(proto: "highlightRanges"),
    3: .same(proto: "blockId"),
    4: .same(proto: "relationKey"),
    5: .same(proto: "relationDetails"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.highlight) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.highlightRanges) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.blockID) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.relationKey) }()
      case 5: try { try decoder.decodeSingularMessageField(value: &self._relationDetails) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.highlight.isEmpty {
      try visitor.visitSingularStringField(value: self.highlight, fieldNumber: 1)
    }
    if !self.highlightRanges.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.highlightRanges, fieldNumber: 2)
    }
    if !self.blockID.isEmpty {
      try visitor.visitSingularStringField(value: self.blockID, fieldNumber: 3)
    }
    if !self.relationKey.isEmpty {
      try visitor.visitSingularStringField(value: self.relationKey, fieldNumber: 4)
    }
    try { if let v = self._relationDetails {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Model_Search.Meta, rhs: Anytype_Model_Search.Meta) -> Bool {
    if lhs.highlight != rhs.highlight {return false}
    if lhs.highlightRanges != rhs.highlightRanges {return false}
    if lhs.blockID != rhs.blockID {return false}
    if lhs.relationKey != rhs.relationKey {return false}
    if lhs._relationDetails != rhs._relationDetails {return false}
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
