public extension Anytype_Rpc.Block {
    public struct Split {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var contextID: String = String()

        public var blockID: String = String()

        public var range: Anytype_Model_Range {
          get {
                  return _range ?? Anytype_Model_Range()
              }
          set {
                  _range = newValue
              }
        }
        /// Returns true if `range` has been explicitly set.
        public var hasRange: Bool {
                return self._range != nil
            }
        /// Clears the value of `range`. Subsequent reads from it will return its default value.
        public mutating func clearRange() {
                self._range = nil
            }

        public var style: Anytype_Model_Block.Content.Text.Style = .paragraph

        public var mode: Anytype_Rpc.Block.Split.Request.Mode = .bottom

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public enum Mode: SwiftProtobuf.Enum {
          public typealias RawValue = Int

          /// new block will be created under existing
          case bottom // = 0

          /// new block will be created above existing
          case top // = 1

          /// new block will be created as the first children of existing
          case inner // = 2

          /// new block will be created after header (not required for set at client side, will auto set for title block)
          case title // = 3
          case UNRECOGNIZED(Int)

          public init() {
            self = .bottom
          }

          public init?(rawValue: Int) {
            switch rawValue {
            case 0:
                    self = .bottom
            case 1:
                    self = .top
            case 2:
                    self = .inner
            case 3:
                    self = .title
            default:
                    self = .UNRECOGNIZED(rawValue)
            }
          }

          public var rawValue: Int {
            switch self {
            case .bottom:
                    return 0
            case .top:
                    return 1
            case .inner:
                    return 2
            case .title:
                    return 3
            case .UNRECOGNIZED(let i):
                    return i
            }
          }

        }

        public init() {
            }

        fileprivate var _range: Anytype_Model_Range? = nil
      }

      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Block.Split.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Block.Split.Response.Error()
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

        public var blockID: String = String()

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

          public var code: Anytype_Rpc.Block.Split.Response.Error.Code = .null

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

        fileprivate var _error: Anytype_Rpc.Block.Split.Response.Error? = nil
        fileprivate var _event: Anytype_ResponseEvent? = nil
      }

      public init() {
          }
    }
}