public extension Anytype_Rpc.BlockDataview {
    public struct ViewRelation {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      public var unknownFields = SwiftProtobuf.UnknownStorage()

      public struct Add {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Request {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var contextID: String = String()

          /// id of dataview block to update
          public var blockID: String = String()

          /// id of view to update
          public var viewID: String = String()

          public var relation: Anytype_Model_Block.Content.Dataview.Relation {
            get {
                    return _relation ?? Anytype_Model_Block.Content.Dataview.Relation()
                }
            set {
                    _relation = newValue
                }
          }
          /// Returns true if `relation` has been explicitly set.
          public var hasRelation: Bool {
                  return self._relation != nil
              }
          /// Clears the value of `relation`. Subsequent reads from it will return its default value.
          public mutating func clearRelation() {
                  self._relation = nil
              }

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public init() {
              }

          fileprivate var _relation: Anytype_Model_Block.Content.Dataview.Relation? = nil
        }

        public struct Response {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var error: Anytype_Rpc.BlockDataview.ViewRelation.Add.Response.Error {
            get {
                    return _error ?? Anytype_Rpc.BlockDataview.ViewRelation.Add.Response.Error()
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

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public struct Error {
            // SwiftProtobuf.Message conformance is added in an extension below. See the
            // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
            // methods supported on all messages.

            public var code: Anytype_Rpc.BlockDataview.ViewRelation.Add.Response.Error.Code = .null

            public var description_p: String = String()

            public var unknownFields = SwiftProtobuf.UnknownStorage()

            public enum Code: SwiftProtobuf.Enum {
              public typealias RawValue = Int
              case null // = 0
              case unknownError // = 1
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

          fileprivate var _error: Anytype_Rpc.BlockDataview.ViewRelation.Add.Response.Error? = nil
          fileprivate var _event: Anytype_ResponseEvent? = nil
        }

        public init() {
            }
      }

      public struct Remove {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Request {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var contextID: String = String()

          /// id of dataview block to update
          public var blockID: String = String()

          /// id of view to update
          public var viewID: String = String()

          public var relationKeys: [String] = []

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public init() {
              }
        }

        public struct Response {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var error: Anytype_Rpc.BlockDataview.ViewRelation.Remove.Response.Error {
            get {
                    return _error ?? Anytype_Rpc.BlockDataview.ViewRelation.Remove.Response.Error()
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

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public struct Error {
            // SwiftProtobuf.Message conformance is added in an extension below. See the
            // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
            // methods supported on all messages.

            public var code: Anytype_Rpc.BlockDataview.ViewRelation.Remove.Response.Error.Code = .null

            public var description_p: String = String()

            public var unknownFields = SwiftProtobuf.UnknownStorage()

            public enum Code: SwiftProtobuf.Enum {
              public typealias RawValue = Int
              case null // = 0
              case unknownError // = 1
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

          fileprivate var _error: Anytype_Rpc.BlockDataview.ViewRelation.Remove.Response.Error? = nil
          fileprivate var _event: Anytype_ResponseEvent? = nil
        }

        public init() {
            }
      }

      public struct Replace {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Request {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var contextID: String = String()

          /// id of dataview block to update
          public var blockID: String = String()

          /// id of view to update
          public var viewID: String = String()

          public var relationKey: String = String()

          public var relation: Anytype_Model_Block.Content.Dataview.Relation {
            get {
                    return _relation ?? Anytype_Model_Block.Content.Dataview.Relation()
                }
            set {
                    _relation = newValue
                }
          }
          /// Returns true if `relation` has been explicitly set.
          public var hasRelation: Bool {
                  return self._relation != nil
              }
          /// Clears the value of `relation`. Subsequent reads from it will return its default value.
          public mutating func clearRelation() {
                  self._relation = nil
              }

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public init() {
              }

          fileprivate var _relation: Anytype_Model_Block.Content.Dataview.Relation? = nil
        }

        public struct Response {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var error: Anytype_Rpc.BlockDataview.ViewRelation.Replace.Response.Error {
            get {
                    return _error ?? Anytype_Rpc.BlockDataview.ViewRelation.Replace.Response.Error()
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

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public struct Error {
            // SwiftProtobuf.Message conformance is added in an extension below. See the
            // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
            // methods supported on all messages.

            public var code: Anytype_Rpc.BlockDataview.ViewRelation.Replace.Response.Error.Code = .null

            public var description_p: String = String()

            public var unknownFields = SwiftProtobuf.UnknownStorage()

            public enum Code: SwiftProtobuf.Enum {
              public typealias RawValue = Int
              case null // = 0
              case unknownError // = 1
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

          fileprivate var _error: Anytype_Rpc.BlockDataview.ViewRelation.Replace.Response.Error? = nil
          fileprivate var _event: Anytype_ResponseEvent? = nil
        }

        public init() {
            }
      }

      public struct Sort {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct Request {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var contextID: String = String()

          /// id of dataview block to update
          public var blockID: String = String()

          /// id of view to update
          public var viewID: String = String()

          /// new order of relations
          public var relationKeys: [String] = []

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public init() {
              }
        }

        public struct Response {
          // SwiftProtobuf.Message conformance is added in an extension below. See the
          // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
          // methods supported on all messages.

          public var error: Anytype_Rpc.BlockDataview.ViewRelation.Sort.Response.Error {
            get {
                    return _error ?? Anytype_Rpc.BlockDataview.ViewRelation.Sort.Response.Error()
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

          public var unknownFields = SwiftProtobuf.UnknownStorage()

          public struct Error {
            // SwiftProtobuf.Message conformance is added in an extension below. See the
            // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
            // methods supported on all messages.

            public var code: Anytype_Rpc.BlockDataview.ViewRelation.Sort.Response.Error.Code = .null

            public var description_p: String = String()

            public var unknownFields = SwiftProtobuf.UnknownStorage()

            public enum Code: SwiftProtobuf.Enum {
              public typealias RawValue = Int
              case null // = 0
              case unknownError // = 1
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

          fileprivate var _error: Anytype_Rpc.BlockDataview.ViewRelation.Sort.Response.Error? = nil
          fileprivate var _event: Anytype_ResponseEvent? = nil
        }

        public init() {
            }
      }

      public init() {
          }
    }
}