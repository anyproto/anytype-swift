import XCTest
@testable import Anytype


final class CustomSpaceOrderBuilderTests: XCTestCase {
    
    var builder: (any CustomSpaceOrderBuilderProtocol)!
    var userDefaults: UserDefaultsStorageMock!

    override func setUpWithError() throws {
        userDefaults = UserDefaultsStorageMock()
        Container.shared.userDefaultsStorage.register { [weak self] in self!.userDefaults }
        builder = CustomSpaceOrderBuilder()
    }

    override func tearDownWithError() throws {
        builder = nil
        userDefaults = nil
    }

    @MainActor
    func testMove() throws {
        let one = SpaceView.mock(id: 1)
        let two = SpaceView.mock(id: 2)
        let three = SpaceView.mock(id: 3)
        
        let stage1 = builder.updateSpacesList(spaces: [one, two, three])
        let result = builder.move(space: one, after: two, allSpaces: stage1)
        
        XCTAssertEqual(result, [two, one, three])
    }
    
    @MainActor
    func testSeveralMoves() throws {
        let one = SpaceView.mock(id: 1)
        let two = SpaceView.mock(id: 2)
        let three = SpaceView.mock(id: 3)
        
        let stage1 = builder.updateSpacesList(spaces: [one, two, three])
        
        let stage2 = builder.move(space: one, after: two, allSpaces: stage1)
        let stage3 = builder.move(space: three, after: two, allSpaces: stage2)
        let result = builder.move(space: two, after: one, allSpaces: stage3)
        
        XCTAssertEqual(result, [three, one, two])
    }
    
    @MainActor
    func testMoveToTheSamePosition() throws {
        let one = SpaceView.mock(id: 1)
        let two = SpaceView.mock(id: 2)
        let three = SpaceView.mock(id: 3)
        
        let stage1 = builder.updateSpacesList(spaces: [one, two, three])
        
        let result = builder.move(space: two, after: two, allSpaces: stage1)
        
        XCTAssertEqual(result, [one, two, three])
    }
    
    @MainActor
    func testMoveTwice() throws {
        let one = SpaceView.mock(id: 1)
        let two = SpaceView.mock(id: 2)
        let three = SpaceView.mock(id: 3)
        
        let stage1 = builder.updateSpacesList(spaces: [one, two, three])
        
        let stage2 = builder.move(space: one, after: two, allSpaces: stage1)
        let result = builder.move(space: two, after: three, allSpaces: stage2)
        
        XCTAssertEqual(result, [one, three, two])
    }
    
    @MainActor
    func testSwapBack() throws {
        let one = SpaceView.mock(id: 1)
        let two = SpaceView.mock(id: 2)
        let three = SpaceView.mock(id: 3)
        
        let stage1 = builder.updateSpacesList(spaces: [one, two, three])
        
        let stage2 = builder.move(space: one, after: two, allSpaces: stage1)
        let result = builder.move(space: two, after: one, allSpaces: stage2)
        
        XCTAssertEqual(result, [one, two, three])
    }
    
    
    @MainActor
    func testAddNewSpaces() throws {
        let one = SpaceView.mock(id: 1)
        let two = SpaceView.mock(id: 2)
        let three = SpaceView.mock(id: 3)
        
        let stage1 = builder.updateSpacesList(spaces: [one, two])
        let stage2 = builder.move(space: one, after: two, allSpaces: stage1)
        let result = builder.updateSpacesList(spaces: [one, two, three])
        
        XCTAssertEqual(result, [three, two, one])
    }
    
    @MainActor
    func testRemoveSpaces() throws {
        let one = SpaceView.mock(id: 1)
        let two = SpaceView.mock(id: 2)
        let three = SpaceView.mock(id: 3)
        
        let stage1 = builder.updateSpacesList(spaces: [one, two, three])
        _ = builder.move(space: one, after: two, allSpaces: stage1)
        let result = builder.updateSpacesList(spaces: [three, one])
        
        XCTAssertEqual(result, [one, three])
    }

}
