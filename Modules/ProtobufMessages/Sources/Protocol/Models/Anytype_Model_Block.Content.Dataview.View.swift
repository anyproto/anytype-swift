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
    public struct View: Sendable {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var id: String = String()

        public var type: Anytype_Model_Block.Content.Dataview.View.TypeEnum = .table

        public var name: String = String()

        public var sorts: [Anytype_Model_Block.Content.Dataview.Sort] = []

        public var filters: [Anytype_Model_Block.Content.Dataview.Filter] = []

        /// relations fields/columns options, also used to provide the order
        public var relations: [Anytype_Model_Block.Content.Dataview.Relation] = []

        /// Relation used for cover in gallery
        public var coverRelationKey: String = String()

        /// Hide icon near name
        public var hideIcon: Bool = false

        /// Gallery card size
        public var cardSize: Anytype_Model_Block.Content.Dataview.View.Size = .small

        /// Image fits container
        public var coverFit: Bool = false

        /// Group view by this relationKey
        public var groupRelationKey: String = String()

        /// Enable backgrounds in groups
        public var groupBackgroundColors: Bool = false

        /// Limit of objects shown in widget
        public var pageLimit: Int32 = 0

        /// Default template that is chosen for new object created within the view
        public var defaultTemplateID: String = String()

        /// Default object type that is chosen for new object created within the view
        public var defaultObjectTypeID: String = String()

        /// Group view by this relationKey
        public var endRelationKey: String = String()

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public enum TypeEnum: SwiftProtobuf.Enum, Swift.CaseIterable {
          public typealias RawValue = Int
          case table // = 0
          case list // = 1
          case gallery // = 2
          case kanban // = 3
          case calendar // = 4
          case graph // = 5
          case UNRECOGNIZED(Int)

          public init() {
            self = .table
          }

          public init?(rawValue: Int) {
            switch rawValue {
            case 0: self = .table
            case 1: self = .list
            case 2: self = .gallery
            case 3: self = .kanban
            case 4: self = .calendar
            case 5: self = .graph
            default: self = .UNRECOGNIZED(rawValue)
            }
          }

          public var rawValue: Int {
            switch self {
            case .table: return 0
            case .list: return 1
            case .gallery: return 2
            case .kanban: return 3
            case .calendar: return 4
            case .graph: return 5
            case .UNRECOGNIZED(let i): return i
            }
          }

          // The compiler won't synthesize support with the UNRECOGNIZED case.
          public static let allCases: [Anytype_Model_Block.Content.Dataview.View.TypeEnum] = [
            .table,
            .list,
            .gallery,
            .kanban,
            .calendar,
            .graph,
          ]

        }

        public enum Size: SwiftProtobuf.Enum, Swift.CaseIterable {
          public typealias RawValue = Int
          case small // = 0
          case medium // = 1
          case large // = 2
          case UNRECOGNIZED(Int)

          public init() {
            self = .small
          }

          public init?(rawValue: Int) {
            switch rawValue {
            case 0: self = .small
            case 1: self = .medium
            case 2: self = .large
            default: self = .UNRECOGNIZED(rawValue)
            }
          }

          public var rawValue: Int {
            switch self {
            case .small: return 0
            case .medium: return 1
            case .large: return 2
            case .UNRECOGNIZED(let i): return i
            }
          }

          // The compiler won't synthesize support with the UNRECOGNIZED case.
          public static let allCases: [Anytype_Model_Block.Content.Dataview.View.Size] = [
            .small,
            .medium,
            .large,
          ]

        }

        public init() {}
      }    
}

extension Anytype_Model_Block.Content.Dataview.View: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Model_Block.Content.Dataview.protoMessageName + ".View"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "type"),
    3: .same(proto: "name"),
    4: .same(proto: "sorts"),
    5: .same(proto: "filters"),
    6: .same(proto: "relations"),
    7: .same(proto: "coverRelationKey"),
    8: .same(proto: "hideIcon"),
    9: .same(proto: "cardSize"),
    10: .same(proto: "coverFit"),
    11: .same(proto: "groupRelationKey"),
    12: .same(proto: "groupBackgroundColors"),
    13: .same(proto: "pageLimit"),
    14: .same(proto: "defaultTemplateId"),
    15: .same(proto: "defaultObjectTypeId"),
    16: .same(proto: "endRelationKey"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.id) }()
      case 2: try { try decoder.decodeSingularEnumField(value: &self.type) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 4: try { try decoder.decodeRepeatedMessageField(value: &self.sorts) }()
      case 5: try { try decoder.decodeRepeatedMessageField(value: &self.filters) }()
      case 6: try { try decoder.decodeRepeatedMessageField(value: &self.relations) }()
      case 7: try { try decoder.decodeSingularStringField(value: &self.coverRelationKey) }()
      case 8: try { try decoder.decodeSingularBoolField(value: &self.hideIcon) }()
      case 9: try { try decoder.decodeSingularEnumField(value: &self.cardSize) }()
      case 10: try { try decoder.decodeSingularBoolField(value: &self.coverFit) }()
      case 11: try { try decoder.decodeSingularStringField(value: &self.groupRelationKey) }()
      case 12: try { try decoder.decodeSingularBoolField(value: &self.groupBackgroundColors) }()
      case 13: try { try decoder.decodeSingularInt32Field(value: &self.pageLimit) }()
      case 14: try { try decoder.decodeSingularStringField(value: &self.defaultTemplateID) }()
      case 15: try { try decoder.decodeSingularStringField(value: &self.defaultObjectTypeID) }()
      case 16: try { try decoder.decodeSingularStringField(value: &self.endRelationKey) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.id.isEmpty {
      try visitor.visitSingularStringField(value: self.id, fieldNumber: 1)
    }
    if self.type != .table {
      try visitor.visitSingularEnumField(value: self.type, fieldNumber: 2)
    }
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 3)
    }
    if !self.sorts.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.sorts, fieldNumber: 4)
    }
    if !self.filters.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.filters, fieldNumber: 5)
    }
    if !self.relations.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.relations, fieldNumber: 6)
    }
    if !self.coverRelationKey.isEmpty {
      try visitor.visitSingularStringField(value: self.coverRelationKey, fieldNumber: 7)
    }
    if self.hideIcon != false {
      try visitor.visitSingularBoolField(value: self.hideIcon, fieldNumber: 8)
    }
    if self.cardSize != .small {
      try visitor.visitSingularEnumField(value: self.cardSize, fieldNumber: 9)
    }
    if self.coverFit != false {
      try visitor.visitSingularBoolField(value: self.coverFit, fieldNumber: 10)
    }
    if !self.groupRelationKey.isEmpty {
      try visitor.visitSingularStringField(value: self.groupRelationKey, fieldNumber: 11)
    }
    if self.groupBackgroundColors != false {
      try visitor.visitSingularBoolField(value: self.groupBackgroundColors, fieldNumber: 12)
    }
    if self.pageLimit != 0 {
      try visitor.visitSingularInt32Field(value: self.pageLimit, fieldNumber: 13)
    }
    if !self.defaultTemplateID.isEmpty {
      try visitor.visitSingularStringField(value: self.defaultTemplateID, fieldNumber: 14)
    }
    if !self.defaultObjectTypeID.isEmpty {
      try visitor.visitSingularStringField(value: self.defaultObjectTypeID, fieldNumber: 15)
    }
    if !self.endRelationKey.isEmpty {
      try visitor.visitSingularStringField(value: self.endRelationKey, fieldNumber: 16)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Model_Block.Content.Dataview.View, rhs: Anytype_Model_Block.Content.Dataview.View) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.type != rhs.type {return false}
    if lhs.name != rhs.name {return false}
    if lhs.sorts != rhs.sorts {return false}
    if lhs.filters != rhs.filters {return false}
    if lhs.relations != rhs.relations {return false}
    if lhs.coverRelationKey != rhs.coverRelationKey {return false}
    if lhs.hideIcon != rhs.hideIcon {return false}
    if lhs.cardSize != rhs.cardSize {return false}
    if lhs.coverFit != rhs.coverFit {return false}
    if lhs.groupRelationKey != rhs.groupRelationKey {return false}
    if lhs.groupBackgroundColors != rhs.groupBackgroundColors {return false}
    if lhs.pageLimit != rhs.pageLimit {return false}
    if lhs.defaultTemplateID != rhs.defaultTemplateID {return false}
    if lhs.defaultObjectTypeID != rhs.defaultObjectTypeID {return false}
    if lhs.endRelationKey != rhs.endRelationKey {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Model_Block.Content.Dataview.View.TypeEnum: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "Table"),
    1: .same(proto: "List"),
    2: .same(proto: "Gallery"),
    3: .same(proto: "Kanban"),
    4: .same(proto: "Calendar"),
    5: .same(proto: "Graph"),
  ]
}

extension Anytype_Model_Block.Content.Dataview.View.Size: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "Small"),
    1: .same(proto: "Medium"),
    2: .same(proto: "Large"),
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

fileprivate let _protobuf_package = "anytype.model"
