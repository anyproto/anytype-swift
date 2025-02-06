public extension Anytype_Rpc.Relation {
    public struct ListWithValue {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var spaceID: String = String()

        public var value: SwiftProtobuf.Google_Protobuf_Value {
          get {
                  return _value ?? SwiftProtobuf.Google_Protobuf_Value()
              }
          set {
                  _value = newValue
              }
        }
        /// Returns true if `value` has been explicitly set.
        public var hasValue: Bool {
                return self._value != nil
            }
        /// Clears the value of `value`. Subsequent reads from it will return its default value.
        public mutating func clearValue() {
                self._value = nil
            }

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {
            }

        fileprivate var _value: SwiftProtobuf.Google_Protobuf_Value? = nil
      }

      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Relation.ListWithValue.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Relation.ListWithValue.Response.Error()
              }
          set {
                  _error = newValue
              }
        }
        /// Returns true if `error` has been explicitly set.
        public var hasError: Bool {
                return self._error != nil
            }
        /// Clears the value of `error`. Subsequent reads from it will return its default value.
        public mutating func clearError() {
                self._error = nil
            }

        public var list: [Anytype_Rpc.Relation.ListWithValue.Response.ResponseItem] = []

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct ResponseItem {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var relationKey: String = String()

          public var counter: Int64 = 0

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public init() {
              }
        }

        public struct Error {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var code: Anytype_Rpc.Relation.ListWithValue.Response.Error.Code = .null

          public var description_p: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public enum Code: SwiftProtobuf.Enum {
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
              case 0:
                      self = .null
              case 1:
                      self = .unknownError
              case 2:
                      self = .badInput
              default:
                      self = .UNRECOGNIZED(rawValue)
              }
            }

            public var rawValue: Int {
              switch self {
              case .null:
                      return 0
              case .unknownError:
                      return 1
              case .badInput:
                      return 2
              case .UNRECOGNIZED(let i):
                      return i
              }
            }

          }

          public init() {
              }
        }

        public init() {
            }

        fileprivate var _error: Anytype_Rpc.Relation.ListWithValue.Response.Error? = nil
      }

      public init() {
          }
    }
}