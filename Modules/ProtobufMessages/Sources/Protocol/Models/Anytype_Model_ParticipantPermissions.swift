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

public enum Anytype_Model_ParticipantPermissions: SwiftProtobuf.Enum, Swift.CaseIterable {
  public typealias RawValue = Int
  case reader // = 0
  case writer // = 1
  case owner // = 2
  case noPermissions // = 3
  case UNRECOGNIZED(Int)

  public init() {
    self = .reader
  }

  public init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .reader
    case 1: self = .writer
    case 2: self = .owner
    case 3: self = .noPermissions
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  public var rawValue: Int {
    switch self {
    case .reader: return 0
    case .writer: return 1
    case .owner: return 2
    case .noPermissions: return 3
    case .UNRECOGNIZED(let i): return i
    }
  }

  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static let allCases: [Anytype_Model_ParticipantPermissions] = [
    .reader,
    .writer,
    .owner,
    .noPermissions,
  ]

}

extension Anytype_Model_ParticipantPermissions: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "Reader"),
    1: .same(proto: "Writer"),
    2: .same(proto: "Owner"),
    3: .same(proto: "NoPermissions"),
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
