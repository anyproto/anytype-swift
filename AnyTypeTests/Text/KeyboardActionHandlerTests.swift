import XCTest
@testable import Anytype
@testable import BlocksModels

class KeyboardActionHandlerTests: XCTestCase {
    private var handler: KeyboardActionHandler!
    private var service: BlockActionServiceMock!
    private var toggleStorage: ToggleStorage!

    override func setUpWithError() throws {
        service = BlockActionServiceMock()
        toggleStorage = ToggleStorage()
        handler = KeyboardActionHandler(service: service, toggleStorage: toggleStorage)
    }

    override func tearDownWithError() throws {
        service = nil
        handler = nil
        toggleStorage = nil
    }

    // MARK: - enterInside
    func test_enterInside() throws {
        let info = info()
        service.splitStub = true
        
        handler.handle(info: info, action: .enterInside(string: .init(string: "123"), position: 2))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 2)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterInside_at_the_start() throws {
        let info = info()
        service.splitStub = true
        
        handler.handle(info: info, action: .enterInside(string: .init(string: "123"), position: 0))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 0)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterInside_with_children() throws {
        let info = info(hasChild: true)
        service.splitStub = true
        
        handler.handle(info: info, action: .enterInside(string: .init(string: "123"), position: 2))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 2)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .inner)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterInside_bullited() throws {
        let info = info(style: .bulleted)
        service.splitStub = true
        
        handler.handle(info: info, action: .enterInside(string: .init(string: "123"), position: 2))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 2)
        XCTAssertEqual(service.splitData!.newBlockContentType, .bulleted)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterInside_title() throws {
        let info = info(style: .title)
        service.splitStub = true
        
        handler.handle(info: info, action: .enterInside(string: .init(string: "123"), position: 2))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 2)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }

    func test_enterInside_toggle_open() throws {
        toggleStorage.toggle(blockId: "id")
        let info = info(style: .toggle)
        service.splitStub = true
        
        handler.handle(info: info, action: .enterInside(string: .init(string: "123"), position: 2))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 2)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .inner)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterInside_toggle_closed() throws {
        let info = info(style: .toggle)
        service.splitStub = true
        
        handler.handle(info: info, action: .enterInside(string: .init(string: "123"), position: 2))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 2)
        XCTAssertEqual(service.splitData!.newBlockContentType, .toggle)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    private func info(
        style: BlockText.Style = .text,
        hasChild: Bool = false
    ) -> BlockInformation {
        BlockInformation(
            id: "id",
            content: .text(.empty(contentType: style)),
            backgroundColor: nil,
            alignment: .center,
            childrenIds: hasChild ? ["childrenId"] : [],
            fields: [:]
        )
    }
}
