public extension Anytype_Rpc.Membership {
    public struct VerifyAppStoreReceipt {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        /// receipt is a JWT-encoded string including info about subscription purchase
        public var receipt: String = String()

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {
            }
      }

      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Membership.VerifyAppStoreReceipt.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Membership.VerifyAppStoreReceipt.Response.Error()
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

          public var code: Anytype_Rpc.Membership.VerifyAppStoreReceipt.Response.Error.Code = .null

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
            case invalidReceipt // = 6
            case purchaseRegistrationError // = 7
            case subscriptionRenewError // = 8
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
                      self = .invalidReceipt
              case 7:
                      self = .purchaseRegistrationError
              case 8:
                      self = .subscriptionRenewError
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
              case .invalidReceipt:
                      return 6
              case .purchaseRegistrationError:
                      return 7
              case .subscriptionRenewError:
                      return 8
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

        fileprivate var _error: Anytype_Rpc.Membership.VerifyAppStoreReceipt.Response.Error? = nil
      }

      public init() {
          }
    }
}