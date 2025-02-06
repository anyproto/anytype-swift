public extension Anytype_Rpc.Workspace {
    public struct Create {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        /// object details
        public var details: SwiftProtobuf.Google_Protobuf_Struct {
          get {
                  return _details ?? SwiftProtobuf.Google_Protobuf_Struct()
              }
          set {
                  _details = newValue
              }
        }
        /// Returns true if `details` has been explicitly set.
        public var hasDetails: Bool {
                return self._details != nil
            }
        /// Clears the value of `details`. Subsequent reads from it will return its default value.
        public mutating func clearDetails() {
                self._details = nil
            }

        /// use case
        public var useCase: Anytype_Rpc.Object.ImportUseCase.Request.UseCase = .none

        /// create space-level chat; temporary solution, should be removed after chats released for all users
        public var withChat: Bool = false

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {
            }

        fileprivate var _details: SwiftProtobuf.Google_Protobuf_Struct? = nil
      }

      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Workspace.Create.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Workspace.Create.Response.Error()
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

        public var spaceID: String = String()

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Error {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var code: Anytype_Rpc.Workspace.Create.Response.Error.Code = .null

          public var description_p: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public enum Code: SwiftProtobuf.Enum {
            public typealias RawValue = Int
            case null // = 0
            case unknownError // = 1

            /// ...
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

        fileprivate var _error: Anytype_Rpc.Workspace.Create.Response.Error? = nil
      }

      public init() {
          }
    }
}