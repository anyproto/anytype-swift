public extension Anytype_Rpc.Wallet {
    public struct CreateSession {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var auth: Anytype_Rpc.Wallet.CreateSession.Request.OneOf_Auth? = nil

        /// cold auth
        public var mnemonic: String {
          get {
            if case .mnemonic(let v)? = auth {
                    return v
                }
            return String()
          }
          set {
                  auth = .mnemonic(newValue)
              }
        }

        /// persistent app key, that can be used to restore session
        public var appKey: String {
          get {
            if case .appKey(let v)? = auth {
                    return v
                }
            return String()
          }
          set {
                  auth = .appKey(newValue)
              }
        }

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public enum OneOf_Auth: Equatable {
          /// cold auth
          case mnemonic(String)
          /// persistent app key, that can be used to restore session
          case appKey(String)

        #if !swift(>=4.1)
          public static func ==(lhs: Anytype_Rpc.Wallet.CreateSession.Request.OneOf_Auth, rhs: Anytype_Rpc.Wallet.CreateSession.Request.OneOf_Auth) -> Bool {
            // The use of inline closures is to circumvent an issue where the compiler
            // allocates stack space for every case branch when no optimizations are
            // enabled. https://github.com/apple/swift-protobuf/issues/1034
            switch (lhs, rhs) {
            case (.mnemonic, .mnemonic):
                    return {
                                  guard case .mnemonic(let l) = lhs, case .mnemonic(let r) = rhs else {
                                      preconditionFailure()
                                  }
                                  return l == r
                                }()
            case (.appKey, .appKey):
                    return {
                                  guard case .appKey(let l) = lhs, case .appKey(let r) = rhs else {
                                      preconditionFailure()
                                  }
                                  return l == r
                                }()
            default:
                    return false
            }
          }
        #endif
        }

        public init() {
            }
      }

      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Wallet.CreateSession.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Wallet.CreateSession.Response.Error()
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

        public var token: String = String()

        /// in case of mnemonic auth, need to be persisted by client
        public var appToken: String = String()

        /// temp, should be replaced with AccountInfo message
        public var accountID: String = String()

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Error {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var code: Anytype_Rpc.Wallet.CreateSession.Response.Error.Code = .null

          public var description_p: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public enum Code: SwiftProtobuf.Enum {
            public typealias RawValue = Int
            case null // = 0
            case unknownError // = 1
            case badInput // = 2

            /// means the client logged into another account or the account directory has been cleaned
            case appTokenNotFoundInTheCurrentAccount // = 101
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
              case 101:
                      self = .appTokenNotFoundInTheCurrentAccount
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
              case .appTokenNotFoundInTheCurrentAccount:
                      return 101
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

        fileprivate var _error: Anytype_Rpc.Wallet.CreateSession.Response.Error? = nil
      }

      public init() {
          }
    }
}