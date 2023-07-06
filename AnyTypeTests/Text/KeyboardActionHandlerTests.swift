import XCTest
@testable import Anytype
@testable import Services
@testable import AnytypeCore

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
            documentId: "",
            service: service,
            listService: listService,
            toggleStorage: toggleStorage,
            container: infoContainer,
            modelsHolder: .init()
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

        let string = NSAttributedString(string: "123")
        handler.handle(info: info, currentString: string, action: .enterInside(string: string, NSRange(location: 1, length: 1)))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, 1)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterInside_at_the_start() throws {
        let info = info()
        service.splitStub = true

        let string = NSAttributedString(string: "123")
        handler.handle(info: info, currentString: string, action: .enterInside(string: string, NSRange(location: 0, length: 0)))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, 0)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterInside_with_children() throws {
        let info = info(hasChild: true)
        service.splitStub = true

        let string = NSAttributedString(string: "123")
        handler.handle(info: info, currentString: string, action: .enterInside(string: string, NSRange(location: 1, length: 1)))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, 1)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .inner)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterInside_bullited() throws {
        let info = info(style: .bulleted)
        service.splitStub = true

        let string = NSAttributedString(string: "123")
        handler.handle(info: info, currentString: string, action: .enterInside(string: string, NSRange(location: 1, length: 1)))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, 1)
        XCTAssertEqual(service.splitData!.newBlockContentType, .bulleted)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterInside_title() throws {
        let info = info(style: .title)
        service.splitStub = true
        
        let string = NSAttributedString(string: "123")
        handler.handle(info: info, currentString: string, action: .enterInside(string: string, NSRange(location: 1, length: 1)))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, 1)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterInside_description() throws {
        let info = info(style: .description)
        service.splitStub = true
        
        let string = NSAttributedString(string: "123")
        handler.handle(info: info, currentString: string, action: .enterInside(string: string, NSRange(location: 1, length: 1)))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, 1)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterInside_quote() throws {
        let info = info(style: .quote)
        service.splitStub = true
        
        let string = NSAttributedString(string: "123")
        handler.handle(info: info, currentString: string, action: .enterInside(string: string, NSRange(location: 1, length: 1)))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, 1)
        XCTAssertEqual(service.splitData!.newBlockContentType, .quote)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }

    func test_enterInside_header() throws {
        let info = info(style: .header)
        service.splitStub = true
        
        let string = NSAttributedString(string: "123")
        handler.handle(info: info, currentString: string, action: .enterInside(string: string, NSRange(location: 1, length: 1)))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, 1)
        XCTAssertEqual(service.splitData!.newBlockContentType, .header)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterInside_toggle_open() throws {
        toggleStorage.toggle(blockId: "id")
        let info = info(style: .toggle)
        service.splitStub = true
        
        let string = NSAttributedString(string: "123")
        handler.handle(info: info, currentString: string, action: .enterInside(string: string, NSRange(location: 1, length: 1)))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, 1)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .inner)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterInside_toggle_closed() throws {
        let info = info(style: .toggle)
        service.splitStub = true
        
        let string = NSAttributedString(string: "123")
        handler.handle(info: info, currentString: string, action: .enterInside(string: string, NSRange(location: 1, length: 1)))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, 1)
        XCTAssertEqual(service.splitData!.newBlockContentType, .toggle)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterInside_toggle_open_with_children() throws {
        toggleStorage.toggle(blockId: "id")
        let info = info(style: .toggle, hasChild: true)
        service.splitStub = true
        
        let string = NSAttributedString(string: "123")
        handler.handle(info: info, currentString: string, action: .enterInside(string: string, NSRange(location: 1, length: 1)))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, 1)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .inner)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterInside_toggle_closed_with_children() throws {
        let info = info(style: .toggle, hasChild: true)
        service.splitStub = true
        
        let string = NSAttributedString(string: "123")
        handler.handle(info: info, currentString: string, action: .enterInside(string: string, NSRange(location: 1, length: 1)))
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, 1)
        XCTAssertEqual(service.splitData!.newBlockContentType, .toggle)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    // MARK: - enterAtTheEnd
    func test_enterAtTheEnd() throws {
        let info = info()
        service.splitStub = true

        let string = NSAttributedString(string: "123")
        handler.handle(
            info: info,
            currentString: string,
            action: .enterAtTheEnd(string: string, NSRange(location: string.length - 1, length: 0))
        )

        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, string.length - 1)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterAtTheEnd_title() throws {
        let info = info(style: .title)
        service.splitStub = true

        let string = NSAttributedString(string: "123")
        handler.handle(
            info: info,
            currentString: string,
            action: .enterAtTheEnd(string: string, NSRange(location: string.length - 1, length: 0))
        )

        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, string.length - 1)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterAtTheEnd_header() throws {
        let info = info(style: .header)
        service.splitStub = true

        let string = NSAttributedString(string: "123")
        handler.handle(
            info: info,
            currentString: string,
            action: .enterAtTheEnd(string: string, NSRange(location: string.length - 1, length: 0))
        )

        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, string.length - 1)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterAtTheEnd_callout() throws {
        let info = info(style: .callout)
        service.splitStub = true

        let string = NSAttributedString(string: "123")
        handler.handle(
            info: info,
            currentString: string,
            action: .enterAtTheEnd(string: string, NSRange(location: string.length - 1, length: 0))
        )

        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, string.length - 1)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterAtTheEnd_quote() throws {
        let info = info(style: .quote)
        service.splitStub = true

        let string = NSAttributedString(string: "123")
        handler.handle(
            info: info,
            currentString: string,
            action: .enterAtTheEnd(string: string, NSRange(location: string.length - 1, length: 0))
        )

        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, string.length - 1)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    func test_enterAtTheEnd_bulleted() throws {
        let info = info(style: .bulleted)
        service.splitStub = true
        
        let string = NSAttributedString(string: "123")
        handler.handle(
            info: info,
            currentString: string,
            action: .enterAtTheEnd(string: string, NSRange(location: string.length - 1, length: 0))
        )
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, string.length - 1)
        XCTAssertEqual(service.splitData!.newBlockContentType, .bulleted)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }

    func test_enterAtTheEnd_bulleted_with_children() throws {
        let info = info(style: .bulleted, hasChild: true)
        service.addStub = true
        let childInfo = BlockInformation.emptyText

        let string = NSAttributedString(string: "123")
        handler.handle(
            info: info,
            currentString: string,
            action: .enterAtTheEnd(string: string, NSRange(location: string.length - 1, length: 0))
        )

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

        let string = NSAttributedString(string: "123")
        handler.handle(
            info: info,
            currentString: string,
            action: .enterAtTheEnd(string: string, NSRange(location: string.length - 1, length: 0))
        )

        XCTAssertEqual(service.addChildNumberOfCalls, 1)
        XCTAssertEqual(service.addChildInfo!, childInfo)
        XCTAssertEqual(service.addChildParentId, "id")
    }

    func test_enterAtTheEnd_closed_toggle() throws {
        let info = info(style: .toggle)
        service.splitStub = true
        
        let string = NSAttributedString(string: "123")
        handler.handle(
            info: info,
            currentString: string,
            action: .enterAtTheEnd(string: string, NSRange(location: string.length - 1, length: 0))
        )
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, string.length - 1)
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

        let string = NSAttributedString(string: "123")
        handler.handle(
            info: info,
            currentString: string,
            action: .enterAtTheEnd(string: string, NSRange(location: string.length - 1, length: 0))
        )

        XCTAssertEqual(service.addNumberOfCalls, 1)
        XCTAssertEqual(service.addInfo!, childInfo)
        XCTAssertEqual(service.addTargetBlockId, "childId")
        XCTAssertEqual(service.addPosition, .top)
        XCTAssertEqual(service.addSetFocus, true)
    }

    func test_enterAtTheEnd_closed_toggle_with_children() throws {
        let info = info(style: .toggle, hasChild: true)
        service.splitStub = true
        
        let string = NSAttributedString(string: "123")
        handler.handle(
            info: info,
            currentString: string,
            action: .enterAtTheEnd(string: string, NSRange(location: string.length - 1, length: 0))
        )
        
        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, string.length - 1)
        XCTAssertEqual(service.splitData!.newBlockContentType, .toggle)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: "123"))
    }
    
    // MARK: - enterOnEmpty
    func test_enterOnEmpty_text() throws {
        let info = info(style: .text)
        service.splitStub = true

        handler.handle(info: info, currentString: .init(string: ""), action: .enterForEmpty)

        XCTAssertEqual(service.splitNumberOfCalls, 1)
        XCTAssertEqual(service.splitData!.range.location, 0)
        XCTAssertEqual(service.splitData!.newBlockContentType, .text)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.string, .init(string: ""))
    }
    
    func test_enterOnEmpty_text_with_children() throws {
        let info = info(style: .text, hasChild: true)
        service.addStub = true

        handler.handle(info: info, currentString: .init(string: ""), action: .enterForEmpty)

        XCTAssertEqual(service.addNumberOfCalls, 1)
        XCTAssertEqual(service.addInfo!, .emptyText)
        XCTAssertEqual(service.addSetFocus, false)
        XCTAssertEqual(service.addPosition, .top)
        XCTAssertEqual(service.addTargetBlockId, "id")
    }
    
    func test_enterOnEmpty_bulleted() throws {
        let info = info(style: .bulleted)
        service.turnIntoStub = true

        handler.handle(info: info, currentString: .init(string: ""), action: .enterForEmpty)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle!, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }

    func test_enterOnEmpty_bulleted_with_children() throws {
        let info = info(style: .bulleted, hasChild: true)
        service.turnIntoStub = true

        handler.handle(info: info, currentString: .init(string: ""), action: .enterForEmpty)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle!, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }

    func test_enterOnEmpty_open_toggle() throws {
        toggleStorage.toggle(blockId: "id")
        let info = info(style: .toggle)
        service.turnIntoStub = true

        handler.handle(info: info, currentString: .init(string: ""), action: .enterForEmpty)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle!, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }

    func test_enterOnEmpty_closed_toggle() throws {
        let info = info(style: .toggle)
        service.turnIntoStub = true

        handler.handle(info: info, currentString: .init(string: ""), action: .enterForEmpty)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle!, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }

    func test_enterOnEmpty_open_toggle_with_children() throws {
        toggleStorage.toggle(blockId: "id")
        let info = info(style: .toggle, hasChild: true)
        service.turnIntoStub = true

        handler.handle(info: info, currentString: .init(string: ""), action: .enterForEmpty)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle!, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }

    func test_enterOnEmpty_closed_toggle_with_children() throws {
        let info = info(style: .toggle, hasChild: true)
        service.turnIntoStub = true

        handler.handle(info: info, currentString: .init(string: ""), action: .enterForEmpty)

        XCTAssertEqual(service.turnIntoNumberOfCalls, 1)
        XCTAssertEqual(service.turnIntoStyle!, .text)
        XCTAssertEqual(service.turnIntoBlockId, "id")
    }
    
    // MARK: - enterAtTheBegining
    func test_enterAtTheBegining() throws {
        let info = info(style: .text, hasChild: true)
        service.addStub = true
        let childInfo = BlockInformation.emptyText

        handler.handle(info: info, currentString: .init(string: ""), action: .enterForEmpty)

        XCTAssertEqual(service.addNumberOfCalls, 1)
        XCTAssertEqual(service.addInfo!, childInfo)
        XCTAssertEqual(service.addTargetBlockId, "id")
        XCTAssertEqual(service.addPosition, .top)
        XCTAssertEqual(service.addSetFocus, false)
    }
    
    func test_enterAtTheBegining_bulleted() throws {
        let info = info(style: .bulleted, hasChild: true)
        service.splitStub = true
        let childInfo = BlockInformation.emptyText

        let string = NSAttributedString(string: "Title text")
        handler.handle(info: info, currentString: string,
                       action: .enterAtTheBegining(string: string, NSRange(location: 0, length: 0)))

        eventually { [weak self] in
            XCTAssertEqual(self?.service.splitNumberOfCalls, 1)
        }
        XCTAssertEqual(service.splitData!.string.string, "Title text")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.newBlockContentType, .bulleted)
        XCTAssertEqual(service.splitData!.range.location, 0)
    }
    
    func test_enterAtTheBegining_toggle() throws {
        let info = info(style: .toggle, hasChild: true)
        service.splitStub = true

        let string = NSAttributedString(string: "Toogle")
        handler.handle(info: info, currentString: string,
                       action: .enterAtTheBegining(string: string, NSRange(location: 0, length: 0)))

        eventually { [weak self] in
            XCTAssertEqual(self?.service.splitNumberOfCalls, 1)
        }
        XCTAssertEqual(service.splitData!.string.string, "Toogle")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.newBlockContentType, .toggle)
        XCTAssertEqual(service.splitData!.range.location, 0)
    }
    
    func test_enterAtTheBegining_title() throws {
        let info = info(content: .text(.plain("Title text", contentType: .title)))
        service.splitStub = true

        let string = NSAttributedString(string: "Title text")
        handler.handle(info: info, currentString: string,
                       action: .enterAtTheBegining(string: string, NSRange(location: 0, length: 0)))

        eventually { [weak self] in
            XCTAssertEqual(self?.service.splitNumberOfCalls, 1)
        }
        XCTAssertEqual(service.splitData!.string.string, "Title text")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.newBlockContentType, .title)
        XCTAssertEqual(service.splitData!.range.location, 0)
    }
    
    func test_enterAtTheBegining_description() throws {
        let text = "description text"
        let info = info(content: .text(.plain(text, contentType: .description)))
        service.splitStub = true

        let string = NSAttributedString(string: text)
        handler.handle(info: info, currentString: string,
                       action: .enterAtTheBegining(string: string, NSRange(location: 0, length: 0)))

        eventually { [weak self] in
            XCTAssertEqual(self?.service.splitNumberOfCalls, 1)
        }
        XCTAssertEqual(service.splitData!.string.string, "description text")
        XCTAssertEqual(service.splitData!.mode, .bottom)
        XCTAssertEqual(service.splitData!.blockId, "id")
        XCTAssertEqual(service.splitData!.newBlockContentType, .description)
        XCTAssertEqual(service.splitData!.range.location, 0)
    }

    
    // MARK: - delete
    
    func test_delete_text() throws {
        let info = info(style: .text)
        service.mergeStub = true

        handler.handle(info: info, currentString: .init(string: ""), action: .delete)

        XCTAssertEqual(service.mergeNumberOfCalls, 1)
        XCTAssertEqual(service.mergeSecondBlockId, "id")
    }
    
    func test_delete_text_with_children() throws {
        let info = info(style: .text, hasChild: true)
        service.mergeStub = true

        handler.handle(info: info, currentString: .init(string: ""), action: .delete)

        XCTAssertEqual(service.mergeNumberOfCalls, 1)
        XCTAssertEqual(service.mergeSecondBlockId, "id")
    }
    
    func test_delete_title() throws {
        let info = info(style: .title)

        handler.handle(info: info, currentString: .init(string: ""), action: .delete)
    }
    
    func test_delete_description() throws {
        let info = info(style: .description)

        handler.handle(info: info, currentString: .init(string: ""), action: .delete)
    }
    
    func test_delete_callout() throws {
        let info = info(style: .callout)
        service.turnIntoStub = true

        handler.handle(info: info, currentString: .init(string: ""), action: .delete)

        validateTurnInto()
    }
    
    func test_delete_quote() throws {
        let info = info(style: .quote)
        service.turnIntoStub = true

        handler.handle(info: info, currentString: .init(string: ""), action: .delete)

        validateTurnInto()
    }
    
    func test_delete_bulleted() throws {
        let info = info(style: .bulleted)
        service.turnIntoStub = true

        handler.handle(info: info, currentString: .init(string: ""), action: .delete)

        validateTurnInto()
    }
    
    func test_delete_bulleted_with_children() throws {
        let info = info(style: .bulleted, hasChild: true)
        service.turnIntoStub = true

        handler.handle(info: info, currentString: .init(string: ""), action: .delete)

        validateTurnInto()
    }
    
    func test_delete_toggle() throws {
        let info = info(style: .toggle)
        service.turnIntoStub = true

        handler.handle(info: info, currentString: .init(string: ""), action: .delete)

        validateTurnInto()
    }
    
    func test_delete_toggle_with_children() throws {
        let info = info(style: .toggle, hasChild: true)
        service.turnIntoStub = true

        handler.handle(info: info, currentString: .init(string: ""), action: .delete)

        validateTurnInto()
    }
    
    // MARK: - Delitable
    func test_delete_text_first_block_in_page_without_title_and_description() throws {
        let headerLayout = info(id: "headerLayout", content: .layout(.init(style: .header)))
        let info = info(style: .text)
        infoContainer.stubChildForParent(parentId: headerLayout.id, child: nil)

        handler.handle(info: info, currentString: .init(string: ""), action: .delete)
        
        // No action
    }
    
    func test_delete_text_second_block_in_page_without_title_and_description() throws {
        let headerLayout = info(id: "headerLayout", content: .layout(.init(style: .header)))
        let info1 = info(id: "id1", style: .text)
        let info2 = info(id: "id2", style: .text)
        infoContainer.stubChildForParent(parentId: headerLayout.id, child: nil)
        service.mergeStub = true
        
        handler.handle(info: info2, currentString: .init(string: ""), action: .delete)
        
        XCTAssertEqual(service.mergeNumberOfCalls, 1)
        XCTAssertEqual(service.mergeSecondBlockId!, "id2")
    }
    
    func test_delete_text_first_block_in_page_without_title_with_description() throws {
        let headerLayout = info(id: "headerLayout", content: .layout(.init(style: .header)))
        let description = info(id: "description", style: .description, parent: headerLayout)
        let info = info(style: .text)
        service.mergeStub = true

        handler.handle(info: info, currentString: .init(string: ""), action: .delete)
        
        XCTAssertEqual(service.mergeNumberOfCalls, 1)
        XCTAssertEqual(service.mergeSecondBlockId!, "id")
    }
    
    func test_delete_text_first_block_in_page_with_title_without_description() throws {
        let headerLayout = info(id: "headerLayout", content: .layout(.init(style: .header)))
        let title = info(id: "title", style: .description, parent: headerLayout)
        let info = info(style: .text)
        service.mergeStub = true

        handler.handle(info: info, currentString: .init(string: ""), action: .delete)
        
        XCTAssertEqual(service.mergeNumberOfCalls, 1)
        XCTAssertEqual(service.mergeSecondBlockId!, "id")
    }
    
    // MARK: - Nested blocks
    func test_deleteAtTheBegining_one_children() throws {
        let parent = info(id: "parentId", style: .toggle, hasChild: true)
        let child = info(id: "childId", style: .text, parent: parent)
        listService.moveStub = true
        
        handler.handle(info: child, currentString: .init(string: ""), action: .delete)
        
        XCTAssertEqual(listService.moveNumberOfCalls, 1)
        XCTAssertEqual(listService.moveBlockId, "childId")
        XCTAssertEqual(listService.moveTargetId, "parentId")
        XCTAssertEqual(listService.movePosition, .bottom)
    }
    
    func test_deleteAtTheBegining_last_children() throws {
        let parent = info(id: "parentId", style: .toggle, hasChild: true)
        let child1 = info(id: "childId1", style: .text, parent: parent)
        let child2 = info(id: "childId2", style: .text, parent: parent)
        listService.moveStub = true
        
        // when
        handler.handle(info: child2, currentString: .init(string: ""), action: .delete)
        
        XCTAssertEqual(listService.moveNumberOfCalls, 1)
        XCTAssertEqual(listService.moveBlockId, "childId2")
        XCTAssertEqual(listService.moveTargetId, "parentId")
        XCTAssertEqual(listService.movePosition, .bottom)
    }
    
    func test_deleteAtTheBegining_not_last_children() throws {
        let parent = info(id: "parentId", style: .toggle, hasChild: true)
        let child1 = info(id: "childId1", style: .text, parent: parent)
        let child2 = info(id: "childId2", style: .text, parent: parent)
        
        service.mergeStub = true
        
        // when
        handler.handle(info: child1, currentString: .init(string: ""), action: .delete)
        
        XCTAssertEqual(service.mergeNumberOfCalls, 1)
        XCTAssertEqual(service.mergeSecondBlockId, "childId1")
    }
    
    func test_deleteAtTheBegining_one_children_of_page() throws {
        let childId = "childId"
        let parent = BlockInformation(
            id: "parentId",
            content: .smartblock(.init(style: .page)),
            backgroundColor: nil,
            horizontalAlignment: .center,
            childrenIds: [childId],
            configurationData: .init(parentId: "parentId", backgroundColor: nil, indentationStyle: .none, calloutBackgroundColor: nil),
            fields: [:]
        )
        let child = info(id: childId, style: .text, parent: parent)
        
        service.mergeStub = true
        
        // when
        handler.handle(info: child, currentString: .init(string: ""), action: .delete)
        
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
        id: BlockId = "id",
        style: BlockText.Style = .text,
        hasChild: Bool = false,
        parent: BlockInformation = .empty(id: "pageId", content: .smartblock(.init(style: .page)))
    ) -> BlockInformation {
        info(id: id, content: .text(.empty(contentType: style)), hasChild: hasChild, parent: parent)
    }
    
    private func info(
        id: BlockId = "id",
        content: BlockContent,
        hasChild: Bool = false,
        parent: BlockInformation? = nil
    ) -> BlockInformation {
        let parent = parent ?? pageInfo()
        
        let info = BlockInformation(
            id: id,
            content: content,
            backgroundColor: nil,
            horizontalAlignment: .center,
            childrenIds: hasChild ? ["childId"] : [],
            configurationData: .init(parentId: parent.id, backgroundColor: nil, indentationStyle: .none, calloutBackgroundColor: nil),
            fields: [:]
        )
        
        infoContainer.getReturnInfo[parent.id] = parent
        infoContainer.stubChildForParent(parentId: parent.id, child: info)
        
        infoContainer.getReturnInfo[id] = info
        
        return info
    }
    
    private func pageInfo() -> BlockInformation {
        let info = BlockInformation(
            id: "pageId",
            content: .smartblock(.init(style: .page)),
            backgroundColor: nil,
            horizontalAlignment: .center,
            childrenIds: [],
            configurationData: .init(backgroundColor: nil, indentationStyle: .none, calloutBackgroundColor: nil),
            fields: [:]
        )
        
        infoContainer.getReturnInfo["pageId"] = info
        
        return info
    }
}
