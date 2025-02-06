public extension Anytype_Rpc.Membership {
    public struct RegisterPaymentRequest {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var requestedTier: UInt32 = 0

        public var paymentMethod: Anytype_Model_Membership.PaymentMethod = .methodNone

        /// if empty - then no name requested
        /// if non-empty - PP node will register that name on behalf of the user
        public var nsName: String = String()

        public var nsNameType: Anytype_Model_NameserviceNameType = .anyName

        /// for some tiers and payment methods (like crypto) we need an e-mail
        /// please get if either from:
        /// 1. Membership.GetStatus() -> anytype.model.Membership.userEmail field
        /// 2. Ask user from the UI
        public var userEmail: String = String()

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {
            }
      }

      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Membership.RegisterPaymentRequest.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Membership.RegisterPaymentRequest.Response.Error()
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

        /// will feature current billing ID
        /// stripe.com/?client_reference_id=1234
        public var paymentURL: String = String()

        /// billingID is only needed for mobile clients
        public var billingID: String = String()

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Error {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var code: Anytype_Rpc.Membership.RegisterPaymentRequest.Response.Error.Code = .null

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
            case tierNotFound // = 6
            case tierInvalid // = 7
            case paymentMethodInvalid // = 8
            case badAnyname // = 9
            case membershipAlreadyExists // = 10
            case canNotConnect // = 11

            /// for tiers and payment methods that require that
            case emailWrongFormat // = 12
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
                      self = .tierNotFound
              case 7:
                      self = .tierInvalid
              case 8:
                      self = .paymentMethodInvalid
              case 9:
                      self = .badAnyname
              case 10:
                      self = .membershipAlreadyExists
              case 11:
                      self = .canNotConnect
              case 12:
                      self = .emailWrongFormat
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
              case .tierNotFound:
                      return 6
              case .tierInvalid:
                      return 7
              case .paymentMethodInvalid:
                      return 8
              case .badAnyname:
                      return 9
              case .membershipAlreadyExists:
                      return 10
              case .canNotConnect:
                      return 11
              case .emailWrongFormat:
                      return 12
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

        fileprivate var _error: Anytype_Rpc.Membership.RegisterPaymentRequest.Response.Error? = nil
      }

      public init() {
          }
    }
}