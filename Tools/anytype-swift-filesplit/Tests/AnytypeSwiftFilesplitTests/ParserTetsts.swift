import Foundation
@testable import AnytypeSwiftFilesplit
import Testing

@Test
func testParser() {
    
    let source = """
    public struct Anytype_Rpc {
        // SwiftProtobuf.Message conformance is added in an extension below. See the
        // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
        // methods supported on all messages.

        public var unknownFields = SwiftProtobuf.UnknownStorage()

        public struct App {
            // SwiftProtobuf.Message conformance is added in an extension below. See the
            // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
            // methods supported on all messages.

            public var unknownFields = SwiftProtobuf.UnknownStorage()

            public struct GetVersion: Protocol {
    
                public struct Request {
                }
            }
        }
    }
    """
    
    let expectedResult = [
        SplitResult(
            source: """
            public struct Anytype_Rpc {
                // SwiftProtobuf.Message conformance is added in an extension below. See the
                // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
                // methods supported on all messages.

                public var unknownFields = SwiftProtobuf.UnknownStorage()
            }
            """,
            fileName: "Anytype_Rpc.swift"
        ),
        SplitResult(
            source: """
            extension Anytype_Rpc {
                public struct App {
                    // SwiftProtobuf.Message conformance is added in an extension below. See the
                    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
                    // methods supported on all messages.

                    public var unknownFields = SwiftProtobuf.UnknownStorage()
                }
            }
            """,
            fileName: "Anytype_Rpc.App.swift"
        ),
        SplitResult(
            source: """
            extension Anytype_Rpc.App {
                public struct GetVersion: Protocol {
                }
            }
            """,
            fileName: "Anytype_Rpc.App.GetVersion.swift"
        ),
        SplitResult(
            source: """
            extension Anytype_Rpc.App.GetVersion {
                public struct Request {
                }
            }
            """,
            fileName: "Anytype_Rpc.App.GetVersion.Request.swift"
        ),
    ]
    
    let splitter = FileSplitrer(source: source)
    let result = splitter.split()
    #expect(result == expectedResult)
}

