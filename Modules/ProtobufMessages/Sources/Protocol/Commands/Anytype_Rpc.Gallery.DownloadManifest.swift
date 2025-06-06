// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: pb/protos/commands.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

extension Anytype_Rpc.Gallery {
    public struct DownloadManifest: Sendable {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request: Sendable {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var url: String = String()

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {}
      }

      public struct Response: Sendable {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Gallery.DownloadManifest.Response.Error {
          get {return _error ?? Anytype_Rpc.Gallery.DownloadManifest.Response.Error()}
          set {_error = newValue}
        }
        /// Returns true if `error` has been explicitly set.
        public var hasError: Bool {return self._error != nil}
        /// Clears the value of `error`. Subsequent reads from it will return its default value.
        public mutating func clearError() {self._error = nil}

        public var info: Anytype_Model_ManifestInfo {
          get {return _info ?? Anytype_Model_ManifestInfo()}
          set {_info = newValue}
        }
        /// Returns true if `info` has been explicitly set.
        public var hasInfo: Bool {return self._info != nil}
        /// Clears the value of `info`. Subsequent reads from it will return its default value.
        public mutating func clearInfo() {self._info = nil}

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Error: Sendable {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var code: Anytype_Rpc.Gallery.DownloadManifest.Response.Error.Code = .null

          public var description_p: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

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
            public static let allCases: [Anytype_Rpc.Gallery.DownloadManifest.Response.Error.Code] = [
              .null,
              .unknownError,
              .badInput,
            ]

          }

          public init() {}
        }

        public init() {}

        fileprivate var _error: Anytype_Rpc.Gallery.DownloadManifest.Response.Error? = nil
        fileprivate var _info: Anytype_Model_ManifestInfo? = nil
      }

      public init() {}
    }    
}

extension Anytype_Rpc.Gallery.DownloadManifest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Rpc.Gallery.protoMessageName + ".DownloadManifest"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    // Load everything into unknown fields
    while try decoder.nextFieldNumber() != nil {}
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Rpc.Gallery.DownloadManifest, rhs: Anytype_Rpc.Gallery.DownloadManifest) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Rpc.Gallery.DownloadManifest.Request: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Rpc.Gallery.DownloadManifest.protoMessageName + ".Request"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "url"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.url) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.url.isEmpty {
      try visitor.visitSingularStringField(value: self.url, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Rpc.Gallery.DownloadManifest.Request, rhs: Anytype_Rpc.Gallery.DownloadManifest.Request) -> Bool {
    if lhs.url != rhs.url {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Rpc.Gallery.DownloadManifest.Response: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Rpc.Gallery.DownloadManifest.protoMessageName + ".Response"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "error"),
    2: .same(proto: "info"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._error) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._info) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._error {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try { if let v = self._info {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Rpc.Gallery.DownloadManifest.Response, rhs: Anytype_Rpc.Gallery.DownloadManifest.Response) -> Bool {
    if lhs._error != rhs._error {return false}
    if lhs._info != rhs._info {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Rpc.Gallery.DownloadManifest.Response.Error: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Anytype_Rpc.Gallery.DownloadManifest.Response.protoMessageName + ".Error"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "code"),
    2: .same(proto: "description"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularEnumField(value: &self.code) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.description_p) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.code != .null {
      try visitor.visitSingularEnumField(value: self.code, fieldNumber: 1)
    }
    if !self.description_p.isEmpty {
      try visitor.visitSingularStringField(value: self.description_p, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Rpc.Gallery.DownloadManifest.Response.Error, rhs: Anytype_Rpc.Gallery.DownloadManifest.Response.Error) -> Bool {
    if lhs.code != rhs.code {return false}
    if lhs.description_p != rhs.description_p {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Rpc.Gallery.DownloadManifest.Response.Error.Code: SwiftProtobuf._ProtoNameProviding {
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

fileprivate let _protobuf_package = "anytype"
