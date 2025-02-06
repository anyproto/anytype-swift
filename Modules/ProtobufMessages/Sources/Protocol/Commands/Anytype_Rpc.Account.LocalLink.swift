public extension Anytype_Rpc.Account {
    public struct LocalLink {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct NewChallenge {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Request {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          /// just for info, not secure to rely on
          public var appName: String = String()

          public var scope: Anytype_Model_Account.Auth.LocalApiScope = .limited

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public init() {
              }
        }

        public struct Response {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var error: Anytype_Rpc.Account.LocalLink.NewChallenge.Response.Error {
            get {
                    return _error ?? Anytype_Rpc.Account.LocalLink.NewChallenge.Response.Error()
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

          public var challengeID: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public struct Error {
            // SwiftProtobuf.Message conformance is added in an extension below. See the
            // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
            // methods supported on all messages.

            public var code: Anytype_Rpc.Account.LocalLink.NewChallenge.Response.Error.Code = .null

            public var description_p: String = String()

            public var unknownFields = SwiftProtobuf.UnknownStorage()

            public enum Code: SwiftProtobuf.Enum {
              public typealias RawValue = Int
              case null // = 0
              case unknownError // = 1
              case badInput // = 2
              case accountIsNotRunning // = 101

              /// protection from overuse
              case tooManyRequests // = 102
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
                        self = .accountIsNotRunning
                case 102:
                        self = .tooManyRequests
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
                case .accountIsNotRunning:
                        return 101
                case .tooManyRequests:
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

          fileprivate var _error: Anytype_Rpc.Account.LocalLink.NewChallenge.Response.Error? = nil
        }

        public init() {
            }
      }

      public struct SolveChallenge {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Request {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var challengeID: String = String()

          public var answer: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public init() {
              }
        }

        public struct Response {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var error: Anytype_Rpc.Account.LocalLink.SolveChallenge.Response.Error {
            get {
                    return _error ?? Anytype_Rpc.Account.LocalLink.SolveChallenge.Response.Error()
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

          /// ephemeral token for the session
          public var sessionToken: String = String()

          /// persistent key, that can be used to restore session via CreateSession
          public var appKey: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public struct Error {
            // SwiftProtobuf.Message conformance is added in an extension below. See the
            // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
            // methods supported on all messages.

            public var code: Anytype_Rpc.Account.LocalLink.SolveChallenge.Response.Error.Code = .null

            public var description_p: String = String()

            public var unknownFields = SwiftProtobuf.UnknownStorage()

            public enum Code: SwiftProtobuf.Enum {
              public typealias RawValue = Int
              case null // = 0
              case unknownError // = 1
              case badInput // = 2
              case accountIsNotRunning // = 101
              case invalidChallengeID // = 102
              case challengeAttemptsExceeded // = 103
              case incorrectAnswer // = 104
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
                        self = .accountIsNotRunning
                case 102:
                        self = .invalidChallengeID
                case 103:
                        self = .challengeAttemptsExceeded
                case 104:
                        self = .incorrectAnswer
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
                case .accountIsNotRunning:
                        return 101
                case .invalidChallengeID:
                        return 102
                case .challengeAttemptsExceeded:
                        return 103
                case .incorrectAnswer:
                        return 104
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

          fileprivate var _error: Anytype_Rpc.Account.LocalLink.SolveChallenge.Response.Error? = nil
        }

        public init() {
            }
      }

      public init() {
          }
    }
}