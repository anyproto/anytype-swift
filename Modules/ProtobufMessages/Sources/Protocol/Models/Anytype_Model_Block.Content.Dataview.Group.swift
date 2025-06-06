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

extension Anytype_Model_Block.Content.Dataview {
    public struct Group: Sendable {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var id: String = String()

        public var value: Anytype_Model_Block.Content.Dataview.Group.OneOf_Value? = nil

        public var status: Anytype_Model_Block.Content.Dataview.Status {
          get {
            if case .status(let v)? = value {return v}
            return Anytype_Model_Block.Content.Dataview.Status()
          }
          set {value = .status(newValue)}
        }

        public var tag: Anytype_Model_Block.Content.Dataview.Tag {
          get {
            if case .tag(let v)? = value {return v}
            return Anytype_Model_Block.Content.Dataview.Tag()
          }
          set {value = .tag(newValue)}
        }

        public var checkbox: Anytype_Model_Block.Content.Dataview.Checkbox {
          get {
            if case .checkbox(let v)? = value {return v}
            return Anytype_Model_Block.Content.Dataview.Checkbox()
          }
          set {value = .checkbox(newValue)}
        }

        public var date: Anytype_Model_Block.Content.Dataview.Date {
          get {
            if case .date(let v)? = value {return v}
            return Anytype_Model_Block.Content.Dataview.Date()
          }
          set {value = .date(newValue)}
        }

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public enum OneOf_Value: Equatable, Sendable {
          case status(Anytype_Model_Block.Content.Dataview.Status)
          case tag(Anytype_Model_Block.Content.Dataview.Tag)
          case checkbox(Anytype_Model_Block.Content.Dataview.Checkbox)
          case date(Anytype_Model_Block.Content.Dataview.Date)

        }

        public init() {}
      }    
}

extension Anytype_Model_Block.Content.Dataview.Group: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Model_Block.Content.Dataview.protoMessageName + ".Group"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "status"),
    3: .same(proto: "tag"),
    4: .same(proto: "checkbox"),
    5: .same(proto: "date"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.id) }()
      case 2: try {
        var v: Anytype_Model_Block.Content.Dataview.Status?
        var hadOneofValue = false
        if let current = self.value {
          hadOneofValue = true
          if case .status(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.value = .status(v)
        }
      }()
      case 3: try {
        var v: Anytype_Model_Block.Content.Dataview.Tag?
        var hadOneofValue = false
        if let current = self.value {
          hadOneofValue = true
          if case .tag(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.value = .tag(v)
        }
      }()
      case 4: try {
        var v: Anytype_Model_Block.Content.Dataview.Checkbox?
        var hadOneofValue = false
        if let current = self.value {
          hadOneofValue = true
          if case .checkbox(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.value = .checkbox(v)
        }
      }()
      case 5: try {
        var v: Anytype_Model_Block.Content.Dataview.Date?
        var hadOneofValue = false
        if let current = self.value {
          hadOneofValue = true
          if case .date(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.value = .date(v)
        }
      }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.id.isEmpty {
      try visitor.visitSingularStringField(value: self.id, fieldNumber: 1)
    }
    switch self.value {
    case .status?: try {
      guard case .status(let v)? = self.value else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    }()
    case .tag?: try {
      guard case .tag(let v)? = self.value else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    }()
    case .checkbox?: try {
      guard case .checkbox(let v)? = self.value else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
    }()
    case .date?: try {
      guard case .date(let v)? = self.value else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
    }()
    case nil: break
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Model_Block.Content.Dataview.Group, rhs: Anytype_Model_Block.Content.Dataview.Group) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.value != rhs.value {return false}
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
