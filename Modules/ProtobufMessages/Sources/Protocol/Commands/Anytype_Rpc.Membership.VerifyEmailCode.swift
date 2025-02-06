public extension Anytype_Rpc.Membership {
    public struct VerifyEmailCode {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var code: String = String()

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {
            }
      }

      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Membership.VerifyEmailCode.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Membership.VerifyEmailCode.Response.Error()
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

          public var code: Anytype_Rpc.Membership.VerifyEmailCode.Response.Error.Code = .null

          public var description_p: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public enum Code: SwiftProtobuf.Enum {
            public typealias RawValue = Int
            case null // = 0
            case unknownError // = 1
            case badInput // = 2
            case notLoggedIn // = 3
            case paymentNodeError // = 4
            case cacheError // = 5
            case emailAlreadyVerified // = 6
            case expired // = 7
            case wrong // = 8
            case membershipNotFound // = 9
            case membershipAlreadyActive // = 10
            case canNotConnect // = 11
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
              case 3:
                      self = .notLoggedIn
              case 4:
                      self = .paymentNodeError
              case 5:
                      self = .cacheError
              case 6:
                      self = .emailAlreadyVerified
              case 7:
                      self = .expired
              case 8:
                      self = .wrong
              case 9:
                      self = .membershipNotFound
              case 10:
                      self = .membershipAlreadyActive
              case 11:
                      self = .canNotConnect
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
              case .notLoggedIn:
                      return 3
              case .paymentNodeError:
                      return 4
              case .cacheError:
                      return 5
              case .emailAlreadyVerified:
                      return 6
              case .expired:
                      return 7
              case .wrong:
                      return 8
              case .membershipNotFound:
                      return 9
              case .membershipAlreadyActive:
                      return 10
              case .canNotConnect:
                      return 11
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

        fileprivate var _error: Anytype_Rpc.Membership.VerifyEmailCode.Response.Error? = nil
      }

      public init() {
          }
    }
}