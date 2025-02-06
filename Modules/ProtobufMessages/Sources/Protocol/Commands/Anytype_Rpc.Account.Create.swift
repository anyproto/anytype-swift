public extension Anytype_Rpc.Account {
    public struct Create {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      ///*
      /// Front end to middleware request-to-create-an account
      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        /// Account name
        public var name: String = String()

        ///TODO: Remove if not needed, GO-1926
        public var avatar: Anytype_Rpc.Account.Create.Request.OneOf_Avatar? = nil

        /// Path to an image, that will be used as an avatar of this account
        public var avatarLocalPath: String {
          get {
            if case .avatarLocalPath(let v)? = avatar {
                    return v
                }
            return String()
          }
          set {
                  avatar = .avatarLocalPath(newValue)
              }
        }

        /// Path to local storage
        public var storePath: String = String()

        /// Option of pre-installed icon
        public var icon: Int64 = 0

        /// Disable local network discovery
        public var disableLocalNetworkSync: Bool = false

        /// optional, default is DefaultConfig
        public var networkMode: Anytype_Rpc.Account.NetworkMode = .defaultConfig

        /// config path for the custom network mode            }
        public var networkCustomConfigFilePath: String = String()

        /// optional, default is false, recommended in case of problems with QUIC transport
        public var preferYamuxTransport: Bool = false

        /// optional, if empty json api will not be started; 127.0.0.1:31009 should be the default one
        public var jsonApiListenAddr: String = String()

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        ///TODO: Remove if not needed, GO-1926
        public enum OneOf_Avatar: Equatable {
          /// Path to an image, that will be used as an avatar of this account
          case avatarLocalPath(String)

        #if !swift(>=4.1)
          public static func ==(lhs: Anytype_Rpc.Account.Create.Request.OneOf_Avatar, rhs: Anytype_Rpc.Account.Create.Request.OneOf_Avatar) -> Bool {
            // The use of inline closures is to circumvent an issue where the compiler
            // allocates stack space for every case branch when no optimizations are
            // enabled. https://github.com/apple/swift-protobuf/issues/1034
            switch (lhs, rhs) {
            case (.avatarLocalPath, .avatarLocalPath):
                    return {
                                  guard case .avatarLocalPath(let l) = lhs, case .avatarLocalPath(let r) = rhs else {
                                      preconditionFailure()
                                  }
                                  return l == r
                                }()
            }
          }
        #endif
        }

        public init() {
            }
      }

      ///*
      /// Middleware-to-front-end response for an account creation request, that can contain a NULL error and created account or a non-NULL error and an empty account
      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        /// Error while trying to create an account
        public var error: Anytype_Rpc.Account.Create.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Account.Create.Response.Error()
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

        /// A newly created account; In case of a failure, i.e. error is non-NULL, the account model should contain empty/default-value fields
        public var account: Anytype_Model_Account {
          get {
                  return _account ?? Anytype_Model_Account()
              }
          set {
                  _account = newValue
              }
        }
        /// Returns true if `account` has been explicitly set.
        public var hasAccount: Bool {
                return self._account != nil
            }
        /// Clears the value of `account`. Subsequent reads from it will return its default value.
        public mutating func clearAccount() {
                self._account = nil
            }

        /// deprecated, use account, GO-1926
        public var config: Anytype_Rpc.Account.Config {
          get {
                  return _config ?? Anytype_Rpc.Account.Config()
              }
          set {
                  _config = newValue
              }
        }
        /// Returns true if `config` has been explicitly set.
        public var hasConfig: Bool {
                return self._config != nil
            }
        /// Clears the value of `config`. Subsequent reads from it will return its default value.
        public mutating func clearConfig() {
                self._config = nil
            }

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Error {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var code: Anytype_Rpc.Account.Create.Response.Error.Code = .null

          public var description_p: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public enum Code: SwiftProtobuf.Enum {
            public typealias RawValue = Int

            /// No error; Account should be non-empty
            case null // = 0

            /// Any other errors
            case unknownError // = 1

            /// Avatar or name is not correct
            case badInput // = 2
            case accountCreatedButFailedToStartNode // = 101
            case accountCreatedButFailedToSetName // = 102
            case failedToStopRunningNode // = 104
            case failedToWriteConfig // = 105
            case failedToCreateLocalRepo // = 106
            case accountCreationIsCanceled // = 107
            case configFileNotFound // = 200
            case configFileInvalid // = 201
            case configFileNetworkIDMismatch // = 202
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
                      self = .accountCreatedButFailedToStartNode
              case 102:
                      self = .accountCreatedButFailedToSetName
              case 104:
                      self = .failedToStopRunningNode
              case 105:
                      self = .failedToWriteConfig
              case 106:
                      self = .failedToCreateLocalRepo
              case 107:
                      self = .accountCreationIsCanceled
              case 200:
                      self = .configFileNotFound
              case 201:
                      self = .configFileInvalid
              case 202:
                      self = .configFileNetworkIDMismatch
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
              case .accountCreatedButFailedToStartNode:
                      return 101
              case .accountCreatedButFailedToSetName:
                      return 102
              case .failedToStopRunningNode:
                      return 104
              case .failedToWriteConfig:
                      return 105
              case .failedToCreateLocalRepo:
                      return 106
              case .accountCreationIsCanceled:
                      return 107
              case .configFileNotFound:
                      return 200
              case .configFileInvalid:
                      return 201
              case .configFileNetworkIDMismatch:
                      return 202
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

        fileprivate var _error: Anytype_Rpc.Account.Create.Response.Error? = nil
        fileprivate var _account: Anytype_Model_Account? = nil
        fileprivate var _config: Anytype_Rpc.Account.Config? = nil
      }

      public init() {
          }
    }
}