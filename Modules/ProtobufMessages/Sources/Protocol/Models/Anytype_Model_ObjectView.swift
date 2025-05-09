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
public struct Anytype_Model_ObjectView: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Root block id
  public var rootID: String = String()

  /// dependent simple blocks (descendants)
  public var blocks: [Anytype_Model_Block] = []

  /// details for the current and dependent objects
  public var details: [Anytype_Model_ObjectView.DetailsSet] = []

  public var type: Anytype_Model_SmartBlockType = .accountOld

  /// DEPRECATED, use relationLinks instead
  public var relations: [Anytype_Model_Relation] = []

  public var relationLinks: [Anytype_Model_RelationLink] = []

  /// object restrictions
  public var restrictions: Anytype_Model_Restrictions {
    get {return _restrictions ?? Anytype_Model_Restrictions()}
    set {_restrictions = newValue}
  }
  /// Returns true if `restrictions` has been explicitly set.
  public var hasRestrictions: Bool {return self._restrictions != nil}
  /// Clears the value of `restrictions`. Subsequent reads from it will return its default value.
  public mutating func clearRestrictions() {self._restrictions = nil}

  public var history: Anytype_Model_ObjectView.HistorySize {
    get {return _history ?? Anytype_Model_ObjectView.HistorySize()}
    set {_history = newValue}
  }
  /// Returns true if `history` has been explicitly set.
  public var hasHistory: Bool {return self._history != nil}
  /// Clears the value of `history`. Subsequent reads from it will return its default value.
  public mutating func clearHistory() {self._history = nil}

  public var blockParticipants: [Anytype_Model_ObjectView.BlockParticipant] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _restrictions: Anytype_Model_Restrictions? = nil
  fileprivate var _history: Anytype_Model_ObjectView.HistorySize? = nil
}

extension Anytype_Model_ObjectView: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ObjectView"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "rootId"),
    2: .same(proto: "blocks"),
    3: .same(proto: "details"),
    4: .same(proto: "type"),
    7: .same(proto: "relations"),
    10: .same(proto: "relationLinks"),
    8: .same(proto: "restrictions"),
    9: .same(proto: "history"),
    11: .same(proto: "blockParticipants"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.rootID) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.blocks) }()
      case 3: try { try decoder.decodeRepeatedMessageField(value: &self.details) }()
      case 4: try { try decoder.decodeSingularEnumField(value: &self.type) }()
      case 7: try { try decoder.decodeRepeatedMessageField(value: &self.relations) }()
      case 8: try { try decoder.decodeSingularMessageField(value: &self._restrictions) }()
      case 9: try { try decoder.decodeSingularMessageField(value: &self._history) }()
      case 10: try { try decoder.decodeRepeatedMessageField(value: &self.relationLinks) }()
      case 11: try { try decoder.decodeRepeatedMessageField(value: &self.blockParticipants) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.rootID.isEmpty {
      try visitor.visitSingularStringField(value: self.rootID, fieldNumber: 1)
    }
    if !self.blocks.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.blocks, fieldNumber: 2)
    }
    if !self.details.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.details, fieldNumber: 3)
    }
    if self.type != .accountOld {
      try visitor.visitSingularEnumField(value: self.type, fieldNumber: 4)
    }
    if !self.relations.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.relations, fieldNumber: 7)
    }
    try { if let v = self._restrictions {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 8)
    } }()
    try { if let v = self._history {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 9)
    } }()
    if !self.relationLinks.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.relationLinks, fieldNumber: 10)
    }
    if !self.blockParticipants.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.blockParticipants, fieldNumber: 11)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Model_ObjectView, rhs: Anytype_Model_ObjectView) -> Bool {
    if lhs.rootID != rhs.rootID {return false}
    if lhs.blocks != rhs.blocks {return false}
    if lhs.details != rhs.details {return false}
    if lhs.type != rhs.type {return false}
    if lhs.relations != rhs.relations {return false}
    if lhs.relationLinks != rhs.relationLinks {return false}
    if lhs._restrictions != rhs._restrictions {return false}
    if lhs._history != rhs._history {return false}
    if lhs.blockParticipants != rhs.blockParticipants {return false}
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
