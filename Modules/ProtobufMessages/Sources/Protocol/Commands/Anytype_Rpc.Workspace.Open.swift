public extension Anytype_Rpc.Workspace {
    public struct Open {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var spaceID: String = String()

        /// create space-level chat if not exists; temporary solution, should be removed after chats released for all users
        public var withChat: Bool = false

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {
            }
      }

      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Workspace.Open.Response.Error {
          get {
                  return _storage._error ?? Anytype_Rpc.Workspace.Open.Response.Error()
              }
          set {
                  _uniqueStorage()._error = newValue
              }
        }
        /// Returns true if `error` has been explicitly set.
        public var hasError: Bool {
                return _storage._error != nil
            }
        /// Clears the value of `error`. Subsequent reads from it will return its default value.
        public mutating func clearError() {
                _uniqueStorage()._error = nil
            }

        public var info: Anytype_Model_Account.Info {
          get {
                  return _storage._info ?? Anytype_Model_Account.Info()
              }
          set {
                  _uniqueStorage()._info = newValue
              }
        }
        /// Returns true if `info` has been explicitly set.
        public var hasInfo: Bool {
                return _storage._info != nil
            }
        /// Clears the value of `info`. Subsequent reads from it will return its default value.
        public mutating func clearInfo() {
                _uniqueStorage()._info = nil
            }

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Error {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var code: Anytype_Rpc.Workspace.Open.Response.Error.Code = .null

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

        fileprivate var _storage = _StorageClass.defaultInstance
      }

      public init() {
          }
    }
}