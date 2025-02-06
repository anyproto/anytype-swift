public extension Anytype_Rpc.Account {
    public struct Recover {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      ///*
      /// Front end to middleware request-to-start-search of an accounts for a recovered mnemonic.
      /// Each of an account that would be found will come with an AccountAdd event
      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {
            }
      }

      ///*
      /// Middleware-to-front-end response to an account recover request, that can contain a NULL error and created account or a non-NULL error and an empty account
      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        /// Error while trying to recover an account
        public var error: Anytype_Rpc.Account.Recover.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Account.Recover.Response.Error()
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

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Error {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var code: Anytype_Rpc.Account.Recover.Response.Error.Code = .null

          public var description_p: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public enum Code: SwiftProtobuf.Enum {
            public typealias RawValue = Int

            /// No error;
            case null // = 0

            /// Any other errors
            case unknownError // = 1
            case badInput // = 2
            case needToRecoverWalletFirst // = 102
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
              case 102:
                      self = .needToRecoverWalletFirst
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
              case .needToRecoverWalletFirst:
                      return 102
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

        fileprivate var _error: Anytype_Rpc.Account.Recover.Response.Error? = nil
      }

      public init() {
          }
    }
}