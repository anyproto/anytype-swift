public extension Anytype_Rpc.Account {
    public struct Config {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var enableDataview: Bool = false

      public var enableDebug: Bool = false

      public var enablePrereleaseChannel: Bool = false

      public var enableSpaces: Bool = false

      public var extra: SwiftProtobuf.Google_Protobuf_Struct {
        get {
                return _extra ?? SwiftProtobuf.Google_Protobuf_Struct()
            }
        set {
                _extra = newValue
            }
      }
      /// Returns true if `extra` has been explicitly set.
      public var hasExtra: Bool {
              return self._extra != nil
          }
      /// Clears the value of `extra`. Subsequent reads from it will return its default value.
      public mutating func clearExtra() {
              self._extra = nil
          }

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public init() {
          }

      fileprivate var _extra: SwiftProtobuf.Google_Protobuf_Struct? = nil
    }
}