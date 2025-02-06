public extension Anytype_Rpc.Object {
    public struct Undo {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Request {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        /// id of the context object
        public var contextID: String = String()

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public init() {
            }
      }

      public struct Response {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var error: Anytype_Rpc.Object.Undo.Response.Error {
          get {
                  return _error ?? Anytype_Rpc.Object.Undo.Response.Error()
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

        public var counters: Anytype_Rpc.Object.UndoRedoCounter {
          get {
                  return _counters ?? Anytype_Rpc.Object.UndoRedoCounter()
              }
          set {
                  _counters = newValue
              }
        }
        /// Returns true if `counters` has been explicitly set.
        public var hasCounters: Bool {
                return self._counters != nil
            }
        /// Clears the value of `counters`. Subsequent reads from it will return its default value.
        public mutating func clearCounters() {
                self._counters = nil
            }

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

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Error {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var code: Anytype_Rpc.Object.Undo.Response.Error.Code = .null

          public var description_p: String = String()

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public enum Code: SwiftProtobuf.Enum {
            public typealias RawValue = Int
            case null // = 0
            case unknownError // = 1
            case badInput // = 2

            /// ...
            case canNotMove // = 3
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
                      self = .canNotMove
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
              case .canNotMove:
                      return 3
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

        fileprivate var _error: Anytype_Rpc.Object.Undo.Response.Error? = nil
        fileprivate var _event: Anytype_ResponseEvent? = nil
        fileprivate var _counters: Anytype_Rpc.Object.UndoRedoCounter? = nil
        fileprivate var _range: Anytype_Model_Range? = nil
      }

      public init() {
          }
    }
}