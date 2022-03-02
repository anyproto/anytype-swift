import XCTest
@testable import Anytype
@testable import BlocksModels

class KeyboardActionHandlerTests: XCTestCase {
    private var handler: KeyboardActionHandler!
    private var service: BlockActionServiceMock!
    private var listService: BlockListServiceMock!
    private var toggleStorage: ToggleStorage!

    override func setUpWithError() throws {
        service = BlockActionServiceMock()
        toggleStorage = ToggleStorage()
        listService = BlockListServiceMock()
        handler = KeyboardActionHandler(
            service: service,
            listService: listService,
            toggleStorage: toggleStorage
        )
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
    
    func test_enterInside_quote() throws {
        let info = info(style: .quote)
        service.splitStub = true
        
        handler.handle(info: info, action: .enterInside(string: .init(string: "123"), position: 2))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 2)
        XCTAssertEqual(service.splitData!.newBlockContentType, .quote)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }

    func test_enterInside_header() throws {
        let info = info(style: .header)
        service.splitStub = true
        
        handler.handle(info: info, action: .enterInside(string: .init(string: "123"), position: 2))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 2)
        XCTAssertEqual(service.splitData!.newBlockContentType, .header)
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
    
    func test_enterInside_toggle_open_with_children() throws {
        toggleStorage.toggle(blockId: "id")
        let info = info(style: .toggle, hasChild: true)
        service.splitStub = true
        
        handler.handle(info: info, action: .enterInside(string: .init(string: "123"), position: 2))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 2)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .inner)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterInside_toggle_closed_with_children() throws {
        let info = info(style: .toggle, hasChild: true)
        service.splitStub = true
        
        handler.handle(info: info, action: .enterInside(string: .init(string: "123"), position: 2))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 2)
        XCTAssertEqual(service.splitData!.newBlockContentType, .toggle)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    // MARK: - enterAtTheEnd
    func test_enterAtTheEnd() throws {
        let info = info()
        service.splitStub = true

        handler.handle(info: info, action: .enterAtTheEnd(string: .init(string: "123")))

        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 3)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterAtTheEnd_title() throws {
        let info = info(style: .title)
        service.splitStub = true

        handler.handle(info: info, action: .enterAtTheEnd(string: .init(string: "123")))

        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 3)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterAtTheEnd_header() throws {
        let info = info(style: .header)
        service.splitStub = true

        handler.handle(info: info, action: .enterAtTheEnd(string: .init(string: "123")))

        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 3)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterAtTheEnd_callout() throws {
        let info = info(style: .callout)
        service.splitStub = true

        handler.handle(info: info, action: .enterAtTheEnd(string: .init(string: "123")))

        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 3)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterAtTheEnd_quote() throws {
        let info = info(style: .quote)
        service.splitStub = true

        handler.handle(info: info, action: .enterAtTheEnd(string: .init(string: "123")))

        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 3)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterAtTheEnd_bulleted() throws {
        let info = info(style: .bulleted)
        service.splitStub = true
        
        handler.handle(info: info, action: .enterAtTheEnd(string: .init(string: "123")))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 3)
        XCTAssertEqual(service.splitData!.newBlockContentType, .bulleted)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }

    func test_enterAtTheEnd_bulleted_with_children() throws {
        let info = info(style: .bulleted, hasChild: true)
        service.addStub = true
        let childInfo = BlockInformation.emptyText

        handler.handle(info: info, action: .enterAtTheEnd(string: .init(string: "123")))

        XCTAssertEqual(service.addNumberOfCalls, 1)
        XCTAssertEqual(service.addInfo!, childInfo)
        XCTAssertEqual(service.addTargetBlockId, "childId")
        XCTAssertEqual(service.addPosition, .top)
        XCTAssertEqual(service.addSetFocus, true)
    }
    
    func test_enterAtTheEnd_open_toggle() throws {
        toggleStorage.toggle(blockId: "id")
        let info = info(style: .toggle)
        service.addChildStub = true
        let childInfo = BlockInformation.emptyText

        handler.handle(info: info, action: .enterAtTheEnd(string: .init(string: "123")))

        XCTAssertEqual(service.addChildNumberOfCalls, 1)
        XCTAssertEqual(service.addChildInfo!, childInfo)
        XCTAssertEqual(service.addChildParentId, "id")
    }

    func test_enterAtTheEnd_closed_toggle() throws {
        let info = info(style: .toggle)
        service.splitStub = true
        
        handler.handle(info: info, action: .enterAtTheEnd(string: .init(string: "123")))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 3)
        XCTAssertEqual(service.splitData!.newBlockContentType, .toggle)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }

    func test_enterAtTheEnd_open_toggle_with_children() throws {
        toggleStorage.toggle(blockId: "id")
        let info = info(style: .toggle, hasChild: true)
        service.addStub = true
        let childInfo = BlockInformation.emptyText

        handler.handle(info: info, action: .enterAtTheEnd(string: .init(string: "123")))

        XCTAssertEqual(service.addNumberOfCalls, 1)
        XCTAssertEqual(service.addInfo!, childInfo)
        XCTAssertEqual(service.addTargetBlockId, "childId")
        XCTAssertEqual(service.addPosition, .top)
        XCTAssertEqual(service.addSetFocus, true)
    }

    func test_enterAtTheEnd_closed_toggle_with_children() throws {
        let info = info(style: .toggle, hasChild: true)
        service.splitStub = true
        
        handler.handle(info: info, action: .enterAtTheEnd(string: .init(string: "123")))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 3)
        XCTAssertEqual(service.splitData!.newBlockContentType, .toggle)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    // MARK: - enterOnEmpty
    func test_enterOnEmpty_text() throws {
        let info = info(style: .text)
        service.splitStub = true

        handler.handle(info: info, action: .enterForEmpty)

        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.position, 0)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: ""))
    }
    
    func test_enterOnEmpty_text_with_children() throws {
        let info = info(style: .text, hasChild: true)
        service.addStub = true

        handler.handle(info: info, action: .enterForEmpty)

        XCTAssertEqual(service.addNumberOfCalls, 1)
        XCTAssertEqual(service.addInfo!, .emptyText)
        XCTAssertEqual(service.addSetFocus, false)
        XCTAssertEqual(service.addPosition, .top)
        XCTAssertEqual(service.addTargetBlockId, "id")
    }
    
    func test_enterOnEmpty_bulleted() throws {
        let info = info(style: .bulleted)
        service.turnIntoStub = true

        handler.handle(info: info, action: .enterForEmpty)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle!, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }

    func test_enterOnEmpty_bulleted_with_children() throws {
        let info = info(style: .bulleted, hasChild: true)
        service.turnIntoStub = true

        handler.handle(info: info, action: .enterForEmpty)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle!, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }

    func test_enterOnEmpty_open_toggle() throws {
        toggleStorage.toggle(blockId: "id")
        let info = info(style: .toggle)
        service.turnIntoStub = true

        handler.handle(info: info, action: .enterForEmpty)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle!, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }

    func test_enterOnEmpty_closed_toggle() throws {
        let info = info(style: .toggle)
        service.turnIntoStub = true

        handler.handle(info: info, action: .enterForEmpty)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle!, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }

    func test_enterOnEmpty_open_toggle_with_children() throws {
        toggleStorage.toggle(blockId: "id")
        let info = info(style: .toggle, hasChild: true)
        service.turnIntoStub = true

        handler.handle(info: info, action: .enterForEmpty)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle!, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }

    func test_enterOnEmpty_closed_toggle_with_children() throws {
        let info = info(style: .toggle, hasChild: true)
        service.turnIntoStub = true

        handler.handle(info: info, action: .enterForEmpty)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle!, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }
    
    // MARK: - enterAtTheBegining
    func test_enterAtTheBegining() throws {
        let info = info(style: .text, hasChild: true)
        service.addStub = true
        let childInfo = BlockInformation.emptyText

        handler.handle(info: info, action: .enterAtTheBegining)

        XCTAssertEqual(service.addNumberOfCalls, 1)
        XCTAssertEqual(service.addInfo!, childInfo)
        XCTAssertEqual(service.addTargetBlockId, "id")
        XCTAssertEqual(service.addPosition, .top)
        XCTAssertEqual(service.addSetFocus, false)
    }
    
    func test_enterAtTheBegining_bulleted() throws {
        let info = info(style: .bulleted, hasChild: true)
        service.addStub = true
        let childInfo = BlockInformation.emptyText

        handler.handle(info: info, action: .enterAtTheBegining)

        XCTAssertEqual(service.addNumberOfCalls, 1)
        XCTAssertEqual(service.addInfo!, childInfo)
        XCTAssertEqual(service.addTargetBlockId, "id")
        XCTAssertEqual(service.addPosition, .top)
        XCTAssertEqual(service.addSetFocus, false)
    }
    
    func test_enterAtTheBegining_toggle() throws {
        let info = info(style: .toggle, hasChild: true)
        service.addStub = true
        let childInfo = BlockInformation.emptyText

        handler.handle(info: info, action: .enterAtTheBegining)

        XCTAssertEqual(service.addNumberOfCalls, 1)
        XCTAssertEqual(service.addInfo!, childInfo)
        XCTAssertEqual(service.addTargetBlockId, "id")
        XCTAssertEqual(service.addPosition, .top)
        XCTAssertEqual(service.addSetFocus, false)
    }
    
    func test_enterAtTheBegining_title() throws {
        let info = info(style: .title, hasChild: true)
        service.addStub = true
        let childInfo = BlockInformation.emptyText

        handler.handle(info: info, action: .enterAtTheBegining)

        XCTAssertEqual(service.addNumberOfCalls, 1)
        XCTAssertEqual(service.addInfo!, childInfo)
        XCTAssertEqual(service.addTargetBlockId, "id")
        XCTAssertEqual(service.addPosition, .top)
        XCTAssertEqual(service.addSetFocus, false)
    }
    
    // MARK: - deleteForEmpty
    
    func test_deleteForEmpty_text() throws {
        let info = info(style: .text)
        service.deleteStub = true

        handler.handle(info: info, action: .deleteForEmpty)

        XCTAssertEqual(service.deleteNumberOfCalls, 1)
        XCTAssertEqual(service.deleteBlockId, "id")
    }
    
    func test_deleteForEmpty_text_with_children() throws {
        let info = info(style: .text, hasChild: true)
        listService.replaceStub = true

        handler.handle(info: info, action: .deleteForEmpty)

        XCTAssertEqual(listService.replaceNumberOfCalls, 1)
        XCTAssertEqual(listService.replaceTargetId, "id")
        XCTAssertEqual(listService.replaceBlockIds, ["childId"])
    }
    
    func test_deleteForEmpty_description() throws {
        let info = info(style: .description)

        handler.handle(info: info, action: .deleteForEmpty)
    }
    
    func test_deleteForEmpty_bulleted() throws {
        let info = info(style: .bulleted)
        service.turnIntoStub = true

        handler.handle(info: info, action: .deleteForEmpty)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }
    
    func test_deleteForEmpty_bulleted_with_children() throws {
        let info = info(style: .bulleted, hasChild: true)
        service.turnIntoStub = true

        handler.handle(info: info, action: .deleteForEmpty)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }
    
    func test_deleteForEmpty_toggle() throws {
        let info = info(style: .toggle)
        service.turnIntoStub = true

        handler.handle(info: info, action: .deleteForEmpty)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }
    
    func test_deleteForEmpty_toggle_with_children() throws {
        let info = info(style: .toggle, hasChild: true)
        service.turnIntoStub = true

        handler.handle(info: info, action: .deleteForEmpty)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }
    
    // MARK: - deleteAtTheBegining
    
    func test_deleteAtTheBegining_text() throws {
        let info = info(style: .text)
        service.mergeStub = true

        handler.handle(info: info, action: .deleteAtTheBegining)

        XCTAssertEqual(service.mergeNumberOfCalls, 1)
        XCTAssertEqual(service.mergeSecondBlockId!, "id")
    }
    
    func test_deleteAtTheBegining_text_with_children() throws {
        let info = info(style: .text, hasChild: true)
        service.mergeStub = true

        handler.handle(info: info, action: .deleteAtTheBegining)

        XCTAssertEqual(service.mergeNumberOfCalls, 1)
        XCTAssertEqual(service.mergeSecondBlockId!, "id")
    }
    
    func test_deleteAtTheBegining_description() throws {
        let info = info(style: .description)

        handler.handle(info: info, action: .deleteAtTheBegining)
    }
    
    func test_deleteAtTheBegining_bulleted() throws {
        let info = info(style: .bulleted)
        service.turnIntoStub = true

        handler.handle(info: info, action: .deleteAtTheBegining)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }
    
    func test_deleteAtTheBegining_bulleted_with_children() throws {
        let info = info(style: .bulleted, hasChild: true)
        service.turnIntoStub = true

        handler.handle(info: info, action: .deleteAtTheBegining)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }
    
    func test_deleteAtTheBegining_toggle() throws {
        let info = info(style: .toggle)
        service.turnIntoStub = true

        handler.handle(info: info, action: .deleteAtTheBegining)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }
    
    func test_deleteAtTheBegining_toggle_with_children() throws {
        let info = info(style: .toggle, hasChild: true)
        service.turnIntoStub = true

        handler.handle(info: info, action: .deleteAtTheBegining)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }
    
    // MARK: - Private
    
    private func info(
        style: BlockText.Style = .text,
        hasChild: Bool = false
    ) -> BlockInformation {
        BlockInformation(
            id: "id",
            content: .text(.empty(contentType: style)),
            backgroundColor: nil,
            alignment: .center,
            childrenIds: hasChild ? ["childId"] : [],
            fields: [:]
        )
    }
}
