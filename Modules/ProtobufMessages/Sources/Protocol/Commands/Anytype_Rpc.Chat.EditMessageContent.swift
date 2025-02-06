public extension Anytype_Rpc.Chat {
    public struct EditMessageContent {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var chatObjectID: String = String()

        public var messageID: String = String()

        public var editedMessage: Anytype_Model_ChatMessage {
          get {
                  return _editedMessage ?? Anytype_Model_ChatMessage()
              }
          set {
                  _editedMessage = newValue
              }
        }
        /// Returns true if `editedMessage` has been explicitly set.
        public var hasEditedMessage: Bool {
                return self._editedMessage != nil
            }
        /// Clears the value of `editedMessage`. Subsequent reads from it will return its default value.
        public mutating func clearEditedMessage() {
                self._editedMessage = nil
            }

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {
            }

        fileprivate var _editedMessage: Anytype_Model_ChatMessage? = nil
      }

      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Chat.EditMessageContent.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Chat.EditMessageContent.Response.Error()
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

          public var code: Anytype_Rpc.Chat.EditMessageContent.Response.Error.Code = .null

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

        fileprivate var _error: Anytype_Rpc.Chat.EditMessageContent.Response.Error? = nil
      }

      public init() {
          }
    }
}