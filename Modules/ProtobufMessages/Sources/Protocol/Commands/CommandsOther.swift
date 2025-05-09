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

// MARK: - Extension support defined in commands.proto.

// MARK: - Extension Properties

// Swift Extensions on the extended Messages to add easy access to the declared
// extension fields. The names are based on the extension field name from the proto
// declaration. To avoid naming collisions, the names are prefixed with the name of
// the scope where the extend directive occurs.

extension SwiftProtobuf.Google_Protobuf_MessageOptions {

  public var Anytype_noAuth: Bool {
    get {return getExtensionValue(ext: Anytype_Extensions_no_auth) ?? false}
    set {setExtensionValue(ext: Anytype_Extensions_no_auth, value: newValue)}
  }
  /// Returns true if extension `Anytype_Extensions_no_auth`
  /// has been explicitly set.
  public var hasAnytype_noAuth: Bool {
    return hasExtensionValue(ext: Anytype_Extensions_no_auth)
  }
  /// Clears the value of extension `Anytype_Extensions_no_auth`.
  /// Subsequent reads from it will return its default value.
  public mutating func clearAnytype_noAuth() {
    clearExtensionValue(ext: Anytype_Extensions_no_auth)
  }

}

// MARK: - File's ExtensionMap: Anytype_Commands_Extensions

/// A `SwiftProtobuf.SimpleExtensionMap` that includes all of the extensions defined by
/// this .proto file. It can be used any place an `SwiftProtobuf.ExtensionMap` is needed
/// in parsing, or it can be combined with other `SwiftProtobuf.SimpleExtensionMap`s to create
/// a larger `SwiftProtobuf.SimpleExtensionMap`.
public let Anytype_Commands_Extensions: SwiftProtobuf.SimpleExtensionMap = [
  Anytype_Extensions_no_auth
]

// Extension Objects - The only reason these might be needed is when manually
// constructing a `SimpleExtensionMap`, otherwise, use the above _Extension Properties_
// accessors for the extension fields on the messages directly.

public let Anytype_Extensions_no_auth = SwiftProtobuf.MessageExtension<SwiftProtobuf.OptionalExtensionField<SwiftProtobuf.ProtobufBool>, SwiftProtobuf.Google_Protobuf_MessageOptions>(
  _protobuf_fieldNumber: 7777,
  fieldName: "anytype.no_auth"
)

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
