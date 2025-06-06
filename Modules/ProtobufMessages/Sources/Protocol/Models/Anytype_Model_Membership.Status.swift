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

  public enum Status: SwiftProtobuf.Enum, Swift.CaseIterable {
    public typealias RawValue = Int
    case unknown // = 0

    /// please wait a bit more, we are still processing your request
    /// the payment is confirmed, but we need more time to do some side-effects:
    /// - increase limits
    /// - send emails
    /// - allocate names
    case pending // = 1

    /// the membership is active, ready to use!
    case active // = 2

    /// in some cases we need to finalize the process:
    /// - if user has bought membership directly without first calling
    /// the BuySubscription method
    /// in this case please call Finalize to finish the process
    case pendingRequiresFinalization // = 3
    case UNRECOGNIZED(Int)

    public init() {
      self = .unknown
    }

    public init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .unknown
      case 1: self = .pending
      case 2: self = .active
      case 3: self = .pendingRequiresFinalization
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    public var rawValue: Int {
      switch self {
      case .unknown: return 0
      case .pending: return 1
      case .active: return 2
      case .pendingRequiresFinalization: return 3
      case .UNRECOGNIZED(let i): return i
      }
    }

    // The compiler won't synthesize support with the UNRECOGNIZED case.
    public static let allCases: [Anytype_Model_Membership.Status] = [
      .unknown,
      .pending,
      .active,
      .pendingRequiresFinalization,
    ]

  }}

extension Anytype_Model_Membership.Status: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "StatusUnknown"),
    1: .same(proto: "StatusPending"),
    2: .same(proto: "StatusActive"),
    3: .same(proto: "StatusPendingRequiresFinalization"),
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
