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

extension Anytype_Model_Notification.Export {

    public enum Code: SwiftProtobuf.Enum, Swift.CaseIterable {
      public typealias RawValue = Int
      case null // = 0
      case unknownError // = 1
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
      public static let allCases: [Anytype_Model_Notification.Export.Code] = [
        .null,
        .unknownError,
        .badInput,
      ]

    }}

extension Anytype_Model_Notification.Export.Code: SwiftProtobuf._ProtoNameProviding {
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

fileprivate let _protobuf_package = "anytype.model"
