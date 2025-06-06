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

extension Anytype_Model_ChatMessage.Attachment {

    public enum AttachmentType: SwiftProtobuf.Enum, Swift.CaseIterable {
      public typealias RawValue = Int

      /// File attachment
      case file // = 0

      /// Image attachment
      case image // = 1

      /// Link attachment
      case link // = 2
      case UNRECOGNIZED(Int)

      public init() {
        self = .file
      }

      public init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .file
        case 1: self = .image
        case 2: self = .link
        default: self = .UNRECOGNIZED(rawValue)
        }
      }

      public var rawValue: Int {
        switch self {
        case .file: return 0
        case .image: return 1
        case .link: return 2
        case .UNRECOGNIZED(let i): return i
        }
      }

      // The compiler won't synthesize support with the UNRECOGNIZED case.
      public static let allCases: [Anytype_Model_ChatMessage.Attachment.AttachmentType] = [
        .file,
        .image,
        .link,
      ]

    }}

extension Anytype_Model_ChatMessage.Attachment.AttachmentType: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "FILE"),
    1: .same(proto: "IMAGE"),
    2: .same(proto: "LINK"),
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
