import XCTest
@testable import Anytype
@testable import BlocksModels

class KeyboardActionHandlerTests: XCTestCase {
    private var handler: KeyboardActionHandler!
    private var service: BlockActionServiceMock!
    private var listService: BlockListServiceMock!
    private var infoContainer: InfoContainerMock!
    private var toggleStorage: ToggleStorage!

    override func setUpWithError() throws {
        service = BlockActionServiceMock()
        toggleStorage = ToggleStorage()
        listService = BlockListServiceMock()
        infoContainer = InfoContainerMock()
        handler = KeyboardActionHandler(
            service: service,
            listService: listService,
            toggleStorage: toggleStorage,
            container: infoContainer
        )
    }

    override func tearDownWithError() throws {
        service = nil
        listService = nil
        handler = nil
        toggleStorage = nil
        infoContainer = nil
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
        service.mergeStub = true

        handler.handle(info: info, action: .deleteForEmpty)

        XCTAssertEqual(service.mergeNumberOfCalls, 1)
        XCTAssertEqual(service.mergeSecondBlockId, "id")
    }
    
    func test_deleteForEmpty_text_with_children() throws {
        let info = info(style: .text, hasChild: true)
        service.mergeStub = true

        handler.handle(info: info, action: .deleteForEmpty)

        XCTAssertEqual(service.mergeNumberOfCalls, 1)
        XCTAssertEqual(service.mergeSecondBlockId, "id")
    }
    
    func test_deleteForEmpty_description() throws {
        let info = info(style: .description)

        handler.handle(info: info, action: .deleteForEmpty)
    }
    
    func test_deleteForEmpty_bulleted() throws {
        let info = info(style: .bulleted)
        service.turnIntoStub = true

        handler.handle(info: info, action: .deleteForEmpty)

        validateTurnInto()
    }
    
    func test_deleteForEmpty_bulleted_with_children() throws {
        let info = info(style: .bulleted, hasChild: true)
        service.turnIntoStub = true

        handler.handle(info: info, action: .deleteForEmpty)

        validateTurnInto()
    }
    
    func test_deleteForEmpty_toggle() throws {
        let info = info(style: .toggle)
        service.turnIntoStub = true

        handler.handle(info: info, action: .deleteForEmpty)

        validateTurnInto()
    }
    
    func test_deleteForEmpty_toggle_with_children() throws {
        let info = info(style: .toggle, hasChild: true)
        service.turnIntoStub = true

        handler.handle(info: info, action: .deleteForEmpty)

        validateTurnInto()
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

        validateTurnInto()
    }
    
    func test_deleteAtTheBegining_bulleted_with_children() throws {
        let info = info(style: .bulleted, hasChild: true)
        service.turnIntoStub = true

        handler.handle(info: info, action: .deleteAtTheBegining)

        validateTurnInto()
    }
    
    func test_deleteAtTheBegining_toggle() throws {
        let info = info(style: .toggle)
        service.turnIntoStub = true

        handler.handle(info: info, action: .deleteAtTheBegining)

        validateTurnInto()
    }
    
    func test_deleteAtTheBegining_toggle_with_children() throws {
        let info = info(style: .toggle, hasChild: true)
        service.turnIntoStub = true

        handler.handle(info: info, action: .deleteAtTheBegining)

        validateTurnInto()
    }
    
    // MARK: - Nested blocks
    func test_deleteAtTheBegining_one_children() throws {
        let child = info(id: "childId", style: .text, parentId: "parentId")
        let parent = info(id: "parentId", style: .toggle, hasChild: true)
        listService.moveStub = true
        infoContainer.getStub = true
        infoContainer.getReturnInfo = parent
        
        infoContainer.childrenStub = true
        infoContainer.childrenReturnInfo = [child]
        
        handler.handle(info: child, action: .deleteAtTheBegining)

        XCTAssertEqual(infoContainer.getNumberOfCalls, 1)
        XCTAssertEqual(infoContainer.childrenNumberOfCalls, 1)
        XCTAssertEqual(listService.moveNumberOfCalls, 1)
        XCTAssertEqual(listService.moveBlockId, "childId")
        XCTAssertEqual(listService.moveTargetId, "parentId")
        XCTAssertEqual(listService.movePosition, .bottom)
    }
    
    func test_deleteAtTheBegining_last_children() throws {
        let child1 = info(id: "childId1", style: .text, parentId: "parentId")
        let child2 = info(id: "childId2", style: .text, parentId: "parentId")
        let parent = info(id: "parentId", style: .toggle, hasChild: true)
        listService.moveStub = true
        infoContainer.getStub = true
        infoContainer.getReturnInfo = parent
        
        infoContainer.childrenStub = true
        infoContainer.childrenReturnInfo = [child1, child2]
        
        // when
        handler.handle(info: child2, action: .deleteAtTheBegining)

        XCTAssertEqual(infoContainer.getNumberOfCalls, 1)
        XCTAssertEqual(infoContainer.childrenNumberOfCalls, 1)
        XCTAssertEqual(listService.moveNumberOfCalls, 1)
        XCTAssertEqual(listService.moveBlockId, "childId2")
        XCTAssertEqual(listService.moveTargetId, "parentId")
        XCTAssertEqual(listService.movePosition, .bottom)
    }
    
    func test_deleteAtTheBegining_not_last_children() throws {
        let child1 = info(id: "childId1", style: .text, parentId: "parentId")
        let child2 = info(id: "childId2", style: .text, parentId: "parentId")
        let parent = info(id: "parentId", style: .toggle, hasChild: true)
        
        infoContainer.getStub = true
        infoContainer.getReturnInfo = parent
        infoContainer.childrenStub = true
        infoContainer.childrenReturnInfo = [child1, child2]
        
        service.mergeStub = true
        
        // when
        handler.handle(info: child1, action: .deleteAtTheBegining)

        XCTAssertEqual(infoContainer.getNumberOfCalls, 1)
        XCTAssertEqual(infoContainer.childrenNumberOfCalls, 1)
        XCTAssertEqual(service.mergeNumberOfCalls, 1)
        XCTAssertEqual(service.mergeSecondBlockId, "childId1")
    }
    
    func test_deleteAtTheBegining_one_children_of_page() throws {
        let child = info(id: "childId", style: .text, parentId: "parentId")
        let parent = BlockInformation(
            id: "parentId",
            content: .smartblock(.init(style: .page)),
            backgroundColor: nil,
            alignment: .center,
            childrenIds: [child.id],
            fields: [:],
            metadata: .init()
        )
        
        infoContainer.getStub = true
        infoContainer.getReturnInfo = parent
        infoContainer.childrenStub = true
        infoContainer.childrenReturnInfo = [child]
        
        service.mergeStub = true
        
        // when
        handler.handle(info: child, action: .deleteAtTheBegining)

        XCTAssertEqual(infoContainer.getNumberOfCalls, 1)
        XCTAssertEqual(infoContainer.childrenNumberOfCalls, 1)
        XCTAssertEqual(service.mergeNumberOfCalls, 1)
        XCTAssertEqual(service.mergeSecondBlockId, "childId")
    }
    
    func test_deleteForEmpty_one_children() throws {
        let child = info(id: "childId", style: .text, parentId: "parentId")
        let parent = info(id: "parentId", style: .toggle, hasChild: true)
        listService.moveStub = true
        infoContainer.getStub = true
        infoContainer.getReturnInfo = parent
        
        infoContainer.childrenStub = true
        infoContainer.childrenReturnInfo = [child]
        
        handler.handle(info: child, action: .deleteForEmpty)

        XCTAssertEqual(infoContainer.getNumberOfCalls, 1)
        XCTAssertEqual(infoContainer.childrenNumberOfCalls, 1)
        XCTAssertEqual(listService.moveNumberOfCalls, 1)
        XCTAssertEqual(listService.moveBlockId, "childId")
        XCTAssertEqual(listService.moveTargetId, "parentId")
        XCTAssertEqual(listService.movePosition, .bottom)
    }
    
    func test_deleteForEmpty_last_children() throws {
        let child1 = info(id: "childId1", style: .text, parentId: "parentId")
        let child2 = info(id: "childId2", style: .text, parentId: "parentId")
        let parent = info(id: "parentId", style: .toggle, hasChild: true)
        listService.moveStub = true
        infoContainer.getStub = true
        infoContainer.getReturnInfo = parent
        
        infoContainer.childrenStub = true
        infoContainer.childrenReturnInfo = [child1, child2]
        
        // when
        handler.handle(info: child2, action: .deleteForEmpty)

        XCTAssertEqual(infoContainer.getNumberOfCalls, 1)
        XCTAssertEqual(infoContainer.childrenNumberOfCalls, 1)
        XCTAssertEqual(listService.moveNumberOfCalls, 1)
        XCTAssertEqual(listService.moveBlockId, "childId2")
        XCTAssertEqual(listService.moveTargetId, "parentId")
        XCTAssertEqual(listService.movePosition, .bottom)
    }
    
    func test_deleteForEmpty_not_last_children() throws {
        let child1 = info(id: "childId1", style: .text, parentId: "parentId")
        let child2 = info(id: "childId2", style: .text, parentId: "parentId")
        let parent = info(id: "parentId", style: .toggle, hasChild: true)
        
        infoContainer.getStub = true
        infoContainer.getReturnInfo = parent
        infoContainer.childrenStub = true
        infoContainer.childrenReturnInfo = [child1, child2]
        
        service.mergeStub = true
        
        // when
        handler.handle(info: child1, action: .deleteForEmpty)

        XCTAssertEqual(infoContainer.getNumberOfCalls, 1)
        XCTAssertEqual(infoContainer.childrenNumberOfCalls, 1)
        XCTAssertEqual(service.mergeNumberOfCalls, 1)
        XCTAssertEqual(service.mergeSecondBlockId, "childId1")
    }
    
    func test_deleteForEmpty_one_children_of_page() throws {
        let child = info(id: "childId", style: .text, parentId: "parentId")
        let parent = BlockInformation(
            id: "parentId",
            content: .smartblock(.init(style: .page)),
            backgroundColor: nil,
            alignment: .center,
            childrenIds: [child.id],
            fields: [:],
            metadata: .init()
        )
        
        infoContainer.getStub = true
        infoContainer.getReturnInfo = parent
        infoContainer.childrenStub = true
        infoContainer.childrenReturnInfo = [child]
        
        service.mergeStub = true
        
        // when
        handler.handle(info: child, action: .deleteForEmpty)

        XCTAssertEqual(infoContainer.getNumberOfCalls, 1)
        XCTAssertEqual(infoContainer.childrenNumberOfCalls, 1)
        XCTAssertEqual(service.mergeNumberOfCalls, 1)
        XCTAssertEqual(service.mergeSecondBlockId, "childId")
    }
    
    // MARK: - Private
    
    private func validateTurnInto() {
        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }
    
    private func info(
        id: String = "id",
        style: BlockText.Style = .text,
        hasChild: Bool = false,
        parentId: BlockId? = nil
    ) -> BlockInformation {
        BlockInformation(
            id: id,
            content: .text(.empty(contentType: style)),
            backgroundColor: nil,
            alignment: .center,
            childrenIds: hasChild ? ["childId"] : [],
            fields: [:],
            metadata: .init(indentationLevel: 0, parentId: parentId)
        )
    }
}
