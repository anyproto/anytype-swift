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

extension Anytype_Model_Block.Content.Layout {

      public enum Style: SwiftProtobuf.Enum, Swift.CaseIterable {
        public typealias RawValue = Int
        case row // = 0
        case column // = 1
        case div // = 2
        case header // = 3
        case tableRows // = 4
        case tableColumns // = 5
        case UNRECOGNIZED(Int)

        public init() {
          self = .row
        }

        public init?(rawValue: Int) {
          switch rawValue {
          case 0: self = .row
          case 1: self = .column
          case 2: self = .div
          case 3: self = .header
          case 4: self = .tableRows
          case 5: self = .tableColumns
          default: self = .UNRECOGNIZED(rawValue)
          }
        }

        public var rawValue: Int {
          switch self {
          case .row: return 0
          case .column: return 1
          case .div: return 2
          case .header: return 3
          case .tableRows: return 4
          case .tableColumns: return 5
          case .UNRECOGNIZED(let i): return i
          }
        }

        // The compiler won't synthesize support with the UNRECOGNIZED case.
        public static let allCases: [Anytype_Model_Block.Content.Layout.Style] = [
          .row,
          .column,
          .div,
          .header,
          .tableRows,
          .tableColumns,
        ]

      }}

extension Anytype_Model_Block.Content.Layout.Style: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "Row"),
    1: .same(proto: "Column"),
    2: .same(proto: "Div"),
    3: .same(proto: "Header"),
    4: .same(proto: "TableRows"),
    5: .same(proto: "TableColumns"),
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
