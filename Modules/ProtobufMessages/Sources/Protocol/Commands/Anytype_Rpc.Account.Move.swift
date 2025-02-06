public extension Anytype_Rpc.Account {
    public struct Move {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      ///*
      /// Front-end-to-middleware request to move a account to a new disk location
      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var newPath: String = String()

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {
            }
      }

      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Account.Move.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Account.Move.Response.Error()
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

          public var code: Anytype_Rpc.Account.Move.Response.Error.Code = .null

          public var description_p: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public enum Code: SwiftProtobuf.Enum {
            public typealias RawValue = Int
            case null // = 0
            case unknownError // = 1
            case badInput // = 2
            case failedToStopNode // = 101
            case failedToIdentifyAccountDir // = 102
            case failedToRemoveAccountData // = 103
            case failedToCreateLocalRepo // = 104
            case failedToWriteConfig // = 105
            case failedToGetConfig // = 106
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
                      self = .failedToStopNode
              case 102:
                      self = .failedToIdentifyAccountDir
              case 103:
                      self = .failedToRemoveAccountData
              case 104:
                      self = .failedToCreateLocalRepo
              case 105:
                      self = .failedToWriteConfig
              case 106:
                      self = .failedToGetConfig
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
              case .failedToStopNode:
                      return 101
              case .failedToIdentifyAccountDir:
                      return 102
              case .failedToRemoveAccountData:
                      return 103
              case .failedToCreateLocalRepo:
                      return 104
              case .failedToWriteConfig:
                      return 105
              case .failedToGetConfig:
                      return 106
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

        fileprivate var _error: Anytype_Rpc.Account.Move.Response.Error? = nil
      }

      public init() {
          }
    }
}