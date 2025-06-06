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
public struct Anytype_Model_Block: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var id: String {
    get {return _storage._id}
    set {_uniqueStorage()._id = newValue}
  }

  public var fields: SwiftProtobuf.Google_Protobuf_Struct {
    get {return _storage._fields ?? SwiftProtobuf.Google_Protobuf_Struct()}
    set {_uniqueStorage()._fields = newValue}
  }
  /// Returns true if `fields` has been explicitly set.
  public var hasFields: Bool {return _storage._fields != nil}
  /// Clears the value of `fields`. Subsequent reads from it will return its default value.
  public mutating func clearFields() {_uniqueStorage()._fields = nil}

  public var restrictions: Anytype_Model_Block.Restrictions {
    get {return _storage._restrictions ?? Anytype_Model_Block.Restrictions()}
    set {_uniqueStorage()._restrictions = newValue}
  }
  /// Returns true if `restrictions` has been explicitly set.
  public var hasRestrictions: Bool {return _storage._restrictions != nil}
  /// Clears the value of `restrictions`. Subsequent reads from it will return its default value.
  public mutating func clearRestrictions() {_uniqueStorage()._restrictions = nil}

  public var childrenIds: [String] {
    get {return _storage._childrenIds}
    set {_uniqueStorage()._childrenIds = newValue}
  }

  public var backgroundColor: String {
    get {return _storage._backgroundColor}
    set {_uniqueStorage()._backgroundColor = newValue}
  }

  public var align: Anytype_Model_Block.Align {
    get {return _storage._align}
    set {_uniqueStorage()._align = newValue}
  }

  public var verticalAlign: Anytype_Model_Block.VerticalAlign {
    get {return _storage._verticalAlign}
    set {_uniqueStorage()._verticalAlign = newValue}
  }

  public var content: OneOf_Content? {
    get {return _storage._content}
    set {_uniqueStorage()._content = newValue}
  }

  public var smartblock: Anytype_Model_Block.Content.Smartblock {
    get {
      if case .smartblock(let v)? = _storage._content {return v}
      return Anytype_Model_Block.Content.Smartblock()
    }
    set {_uniqueStorage()._content = .smartblock(newValue)}
  }

  public var text: Anytype_Model_Block.Content.Text {
    get {
      if case .text(let v)? = _storage._content {return v}
      return Anytype_Model_Block.Content.Text()
    }
    set {_uniqueStorage()._content = .text(newValue)}
  }

  public var file: Anytype_Model_Block.Content.File {
    get {
      if case .file(let v)? = _storage._content {return v}
      return Anytype_Model_Block.Content.File()
    }
    set {_uniqueStorage()._content = .file(newValue)}
  }

  public var layout: Anytype_Model_Block.Content.Layout {
    get {
      if case .layout(let v)? = _storage._content {return v}
      return Anytype_Model_Block.Content.Layout()
    }
    set {_uniqueStorage()._content = .layout(newValue)}
  }

  public var div: Anytype_Model_Block.Content.Div {
    get {
      if case .div(let v)? = _storage._content {return v}
      return Anytype_Model_Block.Content.Div()
    }
    set {_uniqueStorage()._content = .div(newValue)}
  }

  public var bookmark: Anytype_Model_Block.Content.Bookmark {
    get {
      if case .bookmark(let v)? = _storage._content {return v}
      return Anytype_Model_Block.Content.Bookmark()
    }
    set {_uniqueStorage()._content = .bookmark(newValue)}
  }

  public var icon: Anytype_Model_Block.Content.Icon {
    get {
      if case .icon(let v)? = _storage._content {return v}
      return Anytype_Model_Block.Content.Icon()
    }
    set {_uniqueStorage()._content = .icon(newValue)}
  }

  public var link: Anytype_Model_Block.Content.Link {
    get {
      if case .link(let v)? = _storage._content {return v}
      return Anytype_Model_Block.Content.Link()
    }
    set {_uniqueStorage()._content = .link(newValue)}
  }

  public var dataview: Anytype_Model_Block.Content.Dataview {
    get {
      if case .dataview(let v)? = _storage._content {return v}
      return Anytype_Model_Block.Content.Dataview()
    }
    set {_uniqueStorage()._content = .dataview(newValue)}
  }

  public var relation: Anytype_Model_Block.Content.Relation {
    get {
      if case .relation(let v)? = _storage._content {return v}
      return Anytype_Model_Block.Content.Relation()
    }
    set {_uniqueStorage()._content = .relation(newValue)}
  }

  public var featuredRelations: Anytype_Model_Block.Content.FeaturedRelations {
    get {
      if case .featuredRelations(let v)? = _storage._content {return v}
      return Anytype_Model_Block.Content.FeaturedRelations()
    }
    set {_uniqueStorage()._content = .featuredRelations(newValue)}
  }

  public var latex: Anytype_Model_Block.Content.Latex {
    get {
      if case .latex(let v)? = _storage._content {return v}
      return Anytype_Model_Block.Content.Latex()
    }
    set {_uniqueStorage()._content = .latex(newValue)}
  }

  public var tableOfContents: Anytype_Model_Block.Content.TableOfContents {
    get {
      if case .tableOfContents(let v)? = _storage._content {return v}
      return Anytype_Model_Block.Content.TableOfContents()
    }
    set {_uniqueStorage()._content = .tableOfContents(newValue)}
  }

  public var table: Anytype_Model_Block.Content.Table {
    get {
      if case .table(let v)? = _storage._content {return v}
      return Anytype_Model_Block.Content.Table()
    }
    set {_uniqueStorage()._content = .table(newValue)}
  }

  public var tableColumn: Anytype_Model_Block.Content.TableColumn {
    get {
      if case .tableColumn(let v)? = _storage._content {return v}
      return Anytype_Model_Block.Content.TableColumn()
    }
    set {_uniqueStorage()._content = .tableColumn(newValue)}
  }

  public var tableRow: Anytype_Model_Block.Content.TableRow {
    get {
      if case .tableRow(let v)? = _storage._content {return v}
      return Anytype_Model_Block.Content.TableRow()
    }
    set {_uniqueStorage()._content = .tableRow(newValue)}
  }

  public var widget: Anytype_Model_Block.Content.Widget {
    get {
      if case .widget(let v)? = _storage._content {return v}
      return Anytype_Model_Block.Content.Widget()
    }
    set {_uniqueStorage()._content = .widget(newValue)}
  }

  public var chat: Anytype_Model_Block.Content.Chat {
    get {
      if case .chat(let v)? = _storage._content {return v}
      return Anytype_Model_Block.Content.Chat()
    }
    set {_uniqueStorage()._content = .chat(newValue)}
  }

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

extension Anytype_Model_Block: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".Block"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "fields"),
    3: .same(proto: "restrictions"),
    4: .same(proto: "childrenIds"),
    5: .same(proto: "backgroundColor"),
    6: .same(proto: "align"),
    7: .same(proto: "verticalAlign"),
    11: .same(proto: "smartblock"),
    14: .same(proto: "text"),
    15: .same(proto: "file"),
    16: .same(proto: "layout"),
    17: .same(proto: "div"),
    18: .same(proto: "bookmark"),
    19: .same(proto: "icon"),
    20: .same(proto: "link"),
    21: .same(proto: "dataview"),
    22: .same(proto: "relation"),
    23: .same(proto: "featuredRelations"),
    24: .same(proto: "latex"),
    25: .same(proto: "tableOfContents"),
    26: .same(proto: "table"),
    27: .same(proto: "tableColumn"),
    28: .same(proto: "tableRow"),
    29: .same(proto: "widget"),
    30: .same(proto: "chat"),
  ]

  fileprivate class _StorageClass {
    var _id: String = String()
    var _fields: SwiftProtobuf.Google_Protobuf_Struct? = nil
    var _restrictions: Anytype_Model_Block.Restrictions? = nil
    var _childrenIds: [String] = []
    var _backgroundColor: String = String()
    var _align: Anytype_Model_Block.Align = .left
    var _verticalAlign: Anytype_Model_Block.VerticalAlign = .top
    var _content: Anytype_Model_Block.OneOf_Content?

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
      _fields = source._fields
      _restrictions = source._restrictions
      _childrenIds = source._childrenIds
      _backgroundColor = source._backgroundColor
      _align = source._align
      _verticalAlign = source._verticalAlign
      _content = source._content
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
        case 2: try { try decoder.decodeSingularMessageField(value: &_storage._fields) }()
        case 3: try { try decoder.decodeSingularMessageField(value: &_storage._restrictions) }()
        case 4: try { try decoder.decodeRepeatedStringField(value: &_storage._childrenIds) }()
        case 5: try { try decoder.decodeSingularStringField(value: &_storage._backgroundColor) }()
        case 6: try { try decoder.decodeSingularEnumField(value: &_storage._align) }()
        case 7: try { try decoder.decodeSingularEnumField(value: &_storage._verticalAlign) }()
        case 11: try {
          var v: Anytype_Model_Block.Content.Smartblock?
          var hadOneofValue = false
          if let current = _storage._content {
            hadOneofValue = true
            if case .smartblock(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._content = .smartblock(v)
          }
        }()
        case 14: try {
          var v: Anytype_Model_Block.Content.Text?
          var hadOneofValue = false
          if let current = _storage._content {
            hadOneofValue = true
            if case .text(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._content = .text(v)
          }
        }()
        case 15: try {
          var v: Anytype_Model_Block.Content.File?
          var hadOneofValue = false
          if let current = _storage._content {
            hadOneofValue = true
            if case .file(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._content = .file(v)
          }
        }()
        case 16: try {
          var v: Anytype_Model_Block.Content.Layout?
          var hadOneofValue = false
          if let current = _storage._content {
            hadOneofValue = true
            if case .layout(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._content = .layout(v)
          }
        }()
        case 17: try {
          var v: Anytype_Model_Block.Content.Div?
          var hadOneofValue = false
          if let current = _storage._content {
            hadOneofValue = true
            if case .div(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._content = .div(v)
          }
        }()
        case 18: try {
          var v: Anytype_Model_Block.Content.Bookmark?
          var hadOneofValue = false
          if let current = _storage._content {
            hadOneofValue = true
            if case .bookmark(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._content = .bookmark(v)
          }
        }()
        case 19: try {
          var v: Anytype_Model_Block.Content.Icon?
          var hadOneofValue = false
          if let current = _storage._content {
            hadOneofValue = true
            if case .icon(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._content = .icon(v)
          }
        }()
        case 20: try {
          var v: Anytype_Model_Block.Content.Link?
          var hadOneofValue = false
          if let current = _storage._content {
            hadOneofValue = true
            if case .link(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._content = .link(v)
          }
        }()
        case 21: try {
          var v: Anytype_Model_Block.Content.Dataview?
          var hadOneofValue = false
          if let current = _storage._content {
            hadOneofValue = true
            if case .dataview(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._content = .dataview(v)
          }
        }()
        case 22: try {
          var v: Anytype_Model_Block.Content.Relation?
          var hadOneofValue = false
          if let current = _storage._content {
            hadOneofValue = true
            if case .relation(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._content = .relation(v)
          }
        }()
        case 23: try {
          var v: Anytype_Model_Block.Content.FeaturedRelations?
          var hadOneofValue = false
          if let current = _storage._content {
            hadOneofValue = true
            if case .featuredRelations(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._content = .featuredRelations(v)
          }
        }()
        case 24: try {
          var v: Anytype_Model_Block.Content.Latex?
          var hadOneofValue = false
          if let current = _storage._content {
            hadOneofValue = true
            if case .latex(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._content = .latex(v)
          }
        }()
        case 25: try {
          var v: Anytype_Model_Block.Content.TableOfContents?
          var hadOneofValue = false
          if let current = _storage._content {
            hadOneofValue = true
            if case .tableOfContents(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._content = .tableOfContents(v)
          }
        }()
        case 26: try {
          var v: Anytype_Model_Block.Content.Table?
          var hadOneofValue = false
          if let current = _storage._content {
            hadOneofValue = true
            if case .table(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._content = .table(v)
          }
        }()
        case 27: try {
          var v: Anytype_Model_Block.Content.TableColumn?
          var hadOneofValue = false
          if let current = _storage._content {
            hadOneofValue = true
            if case .tableColumn(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._content = .tableColumn(v)
          }
        }()
        case 28: try {
          var v: Anytype_Model_Block.Content.TableRow?
          var hadOneofValue = false
          if let current = _storage._content {
            hadOneofValue = true
            if case .tableRow(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._content = .tableRow(v)
          }
        }()
        case 29: try {
          var v: Anytype_Model_Block.Content.Widget?
          var hadOneofValue = false
          if let current = _storage._content {
            hadOneofValue = true
            if case .widget(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._content = .widget(v)
          }
        }()
        case 30: try {
          var v: Anytype_Model_Block.Content.Chat?
          var hadOneofValue = false
          if let current = _storage._content {
            hadOneofValue = true
            if case .chat(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._content = .chat(v)
          }
        }()
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
      try { if let v = _storage._fields {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      } }()
      try { if let v = _storage._restrictions {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
      } }()
      if !_storage._childrenIds.isEmpty {
        try visitor.visitRepeatedStringField(value: _storage._childrenIds, fieldNumber: 4)
      }
      if !_storage._backgroundColor.isEmpty {
        try visitor.visitSingularStringField(value: _storage._backgroundColor, fieldNumber: 5)
      }
      if _storage._align != .left {
        try visitor.visitSingularEnumField(value: _storage._align, fieldNumber: 6)
      }
      if _storage._verticalAlign != .top {
        try visitor.visitSingularEnumField(value: _storage._verticalAlign, fieldNumber: 7)
      }
      switch _storage._content {
      case .smartblock?: try {
        guard case .smartblock(let v)? = _storage._content else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 11)
      }()
      case .text?: try {
        guard case .text(let v)? = _storage._content else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 14)
      }()
      case .file?: try {
        guard case .file(let v)? = _storage._content else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 15)
      }()
      case .layout?: try {
        guard case .layout(let v)? = _storage._content else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 16)
      }()
      case .div?: try {
        guard case .div(let v)? = _storage._content else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 17)
      }()
      case .bookmark?: try {
        guard case .bookmark(let v)? = _storage._content else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 18)
      }()
      case .icon?: try {
        guard case .icon(let v)? = _storage._content else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 19)
      }()
      case .link?: try {
        guard case .link(let v)? = _storage._content else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 20)
      }()
      case .dataview?: try {
        guard case .dataview(let v)? = _storage._content else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 21)
      }()
      case .relation?: try {
        guard case .relation(let v)? = _storage._content else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 22)
      }()
      case .featuredRelations?: try {
        guard case .featuredRelations(let v)? = _storage._content else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 23)
      }()
      case .latex?: try {
        guard case .latex(let v)? = _storage._content else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 24)
      }()
      case .tableOfContents?: try {
        guard case .tableOfContents(let v)? = _storage._content else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 25)
      }()
      case .table?: try {
        guard case .table(let v)? = _storage._content else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 26)
      }()
      case .tableColumn?: try {
        guard case .tableColumn(let v)? = _storage._content else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 27)
      }()
      case .tableRow?: try {
        guard case .tableRow(let v)? = _storage._content else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 28)
      }()
      case .widget?: try {
        guard case .widget(let v)? = _storage._content else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 29)
      }()
      case .chat?: try {
        guard case .chat(let v)? = _storage._content else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 30)
      }()
      case nil: break
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Model_Block, rhs: Anytype_Model_Block) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._id != rhs_storage._id {return false}
        if _storage._fields != rhs_storage._fields {return false}
        if _storage._restrictions != rhs_storage._restrictions {return false}
        if _storage._childrenIds != rhs_storage._childrenIds {return false}
        if _storage._backgroundColor != rhs_storage._backgroundColor {return false}
        if _storage._align != rhs_storage._align {return false}
        if _storage._verticalAlign != rhs_storage._verticalAlign {return false}
        if _storage._content != rhs_storage._content {return false}
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

fileprivate let _protobuf_package = "anytype.model"
