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

extension Anytype_Model_Block.Content.Link {

      public enum Style: SwiftProtobuf.Enum, Swift.CaseIterable {
        public typealias RawValue = Int
        case page // = 0
        case dataview // = 1
        case dashboard // = 2

        /// ...
        case archive // = 3
        case UNRECOGNIZED(Int)

        public init() {
          self = .page
        }

        public init?(rawValue: Int) {
          switch rawValue {
          case 0: self = .page
          case 1: self = .dataview
          case 2: self = .dashboard
          case 3: self = .archive
          default: self = .UNRECOGNIZED(rawValue)
          }
        }

        public var rawValue: Int {
          switch self {
          case .page: return 0
          case .dataview: return 1
          case .dashboard: return 2
          case .archive: return 3
          case .UNRECOGNIZED(let i): return i
          }
        }

        // The compiler won't synthesize support with the UNRECOGNIZED case.
        public static let allCases: [Anytype_Model_Block.Content.Link.Style] = [
          .page,
          .dataview,
          .dashboard,
          .archive,
        ]

      }}

extension Anytype_Model_Block.Content.Link.Style: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "Page"),
    1: .same(proto: "Dataview"),
    2: .same(proto: "Dashboard"),
    3: .same(proto: "Archive"),
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
