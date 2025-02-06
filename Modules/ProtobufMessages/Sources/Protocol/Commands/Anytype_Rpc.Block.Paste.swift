public extension Anytype_Rpc.Block {
    public struct Paste {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var contextID: String = String()

        public var focusedBlockID: String = String()

        public var selectedTextRange: Anytype_Model_Range {
          get {
                  return _selectedTextRange ?? Anytype_Model_Range()
              }
          set {
                  _selectedTextRange = newValue
              }
        }
        /// Returns true if `selectedTextRange` has been explicitly set.
        public var hasSelectedTextRange: Bool {
                return self._selectedTextRange != nil
            }
        /// Clears the value of `selectedTextRange`. Subsequent reads from it will return its default value.
        public mutating func clearSelectedTextRange() {
                self._selectedTextRange = nil
            }

        public var selectedBlockIds: [String] = []

        public var isPartOfBlock: Bool = false

        public var textSlot: String = String()

        public var htmlSlot: String = String()

        public var anySlot: [Anytype_Model_Block] = []

        public var fileSlot: [Anytype_Rpc.Block.Paste.Request.File] = []

        public var url: String = String()

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct File {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var name: String = String()

          public var data: Data = Data()

          public var localPath: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public init() {
              }
        }

        public init() {
            }

        fileprivate var _selectedTextRange: Anytype_Model_Range? = nil
      }

      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Block.Paste.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Block.Paste.Response.Error()
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

        public var blockIds: [String] = []

        public var caretPosition: Int32 = 0

        public var isSameBlockCaret: Bool = false

        public var event: Anytype_ResponseEvent {
          get {
                  return _event ?? Anytype_ResponseEvent()
              }
          set {
                  _event = newValue
              }
        }
        /// Returns true if `event` has been explicitly set.
        public var hasEvent: Bool {
                return self._event != nil
            }
        /// Clears the value of `event`. Subsequent reads from it will return its default value.
        public mutating func clearEvent() {
                self._event = nil
            }

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Error {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var code: Anytype_Rpc.Block.Paste.Response.Error.Code = .null

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

        fileprivate var _error: Anytype_Rpc.Block.Paste.Response.Error? = nil
        fileprivate var _event: Anytype_ResponseEvent? = nil
      }

      public init() {
          }
    }
}