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

extension Anytype_Model_Membership {

  public enum PaymentMethod: SwiftProtobuf.Enum, Swift.CaseIterable {
    public typealias RawValue = Int
    case methodNone // = 0
    case methodStripe // = 1
    case methodCrypto // = 2
    case methodInappApple // = 3
    case methodInappGoogle // = 4
    case UNRECOGNIZED(Int)

    public init() {
      self = .methodNone
    }

    public init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .methodNone
      case 1: self = .methodStripe
      case 2: self = .methodCrypto
      case 3: self = .methodInappApple
      case 4: self = .methodInappGoogle
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    public var rawValue: Int {
      switch self {
      case .methodNone: return 0
      case .methodStripe: return 1
      case .methodCrypto: return 2
      case .methodInappApple: return 3
      case .methodInappGoogle: return 4
      case .UNRECOGNIZED(let i): return i
      }
    }

    // The compiler won't synthesize support with the UNRECOGNIZED case.
    public static let allCases: [Anytype_Model_Membership.PaymentMethod] = [
      .methodNone,
      .methodStripe,
      .methodCrypto,
      .methodInappApple,
      .methodInappGoogle,
    ]

  }}

extension Anytype_Model_Membership.PaymentMethod: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "MethodNone"),
    1: .same(proto: "MethodStripe"),
    2: .same(proto: "MethodCrypto"),
    3: .same(proto: "MethodInappApple"),
    4: .same(proto: "MethodInappGoogle"),
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
