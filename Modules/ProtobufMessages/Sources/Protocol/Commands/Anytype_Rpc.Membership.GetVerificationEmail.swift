public extension Anytype_Rpc.Membership {
    public struct GetVerificationEmail {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var email: String = String()

        public var subscribeToNewsletter: Bool = false

        public var insiderTipsAndTutorials: Bool = false

        /// if we are coming from the onboarding list
        public var isOnboardingList: Bool = false

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {
            }
      }

      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Membership.GetVerificationEmail.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Membership.GetVerificationEmail.Response.Error()
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

          public var code: Anytype_Rpc.Membership.GetVerificationEmail.Response.Error.Code = .null

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
            case emailWrongFormat // = 6
            case emailAlreadyVerified // = 7
            case emailAlredySent // = 8
            case emailFailedToSend // = 9
            case membershipAlreadyExists // = 10
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
                      self = .emailWrongFormat
              case 7:
                      self = .emailAlreadyVerified
              case 8:
                      self = .emailAlredySent
              case 9:
                      self = .emailFailedToSend
              case 10:
                      self = .membershipAlreadyExists
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
              case .emailWrongFormat:
                      return 6
              case .emailAlreadyVerified:
                      return 7
              case .emailAlredySent:
                      return 8
              case .emailFailedToSend:
                      return 9
              case .membershipAlreadyExists:
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

        fileprivate var _error: Anytype_Rpc.Membership.GetVerificationEmail.Response.Error? = nil
      }

      public init() {
          }
    }
}