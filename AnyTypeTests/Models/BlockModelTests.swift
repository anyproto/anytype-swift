//
//  BlockModelTests.swift
//  AnyTypeTests
//
//  Created by Dmitry Lobanov on 19.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import XCTest
@testable import AnyType
import Combine

class BlockModelTests: XCTestCase {
    func testShouldBuildBlocks() {
        XCTContext.runActivity(named: "Check Metablocks") { (activity) in
            let indexPath = MetaBlock.newIndex(level: 1, position: 1)
            let block = MetaBlock.init(indexPath: indexPath, blocks: [Block.mockText(.text), Block.mockText(.bulleted)])
            
            XCTAssertEqual(block.indexPath, indexPath)
            for (i, element) in block.blocks.enumerated() {
                XCTAssertEqual(element.indexPath, MetaBlock.Index.init(item: indexPath.item + i + 1, section: indexPath.section))
                XCTAssertTrue(BlockModels.Utilities.Checker.compare(element.parent, block))
            }
            XCTAssertTrue(block.isRoot)
        }
        XCTContext.runActivity(named: "Check Blocks") { (activity) in
            let indexPath = Block.newIndex(level: 1, position: 1)
            var block = Block.mockText(.text)
            block.indexPath = indexPath
            block.blocks = [Block.mockText(.text), Block.mockText(.bulleted)]
            block.buildIndexPaths()
            
            XCTAssertEqual(block.indexPath, indexPath)
            
            for (i, element) in block.blocks.enumerated() {
                XCTAssertEqual(element.indexPath, Block.Index.init(item: i, section: indexPath.section + 1))
                XCTAssertTrue(BlockModels.Utilities.Checker.compare(element.parent, block))
            }
            XCTAssertTrue(block.isRoot)
        }
    }
    var subscriptions: Set<AnyCancellable> = []
    override class func setUp() {
        super.setUp()
    }
    override func tearDown() {
        subscriptions = []
    }
}

extension BlockModelTests {
    func testShouldCallUpdatesOnRootNode() {
        XCTContext.runActivity(named: "") { (activity) in
            let root = BlockModels.Block.Node(indexPath: BlockModels.Utilities.IndexGenerator.rootID(), blocks: [])
            
            let first = BlockModels.Block.Node(indexPath: .init(), blocks: [])
            let second = BlockModels.Block.Node(indexPath: .init(), blocks: [])
            
            root.blocks = [first, second]
            root.buildIndexPaths()
            
            
            root.objectWillChange.sink{
                print("value: \($0)")
            }.store(in: &self.subscriptions)
            
            let third = BlockModels.Block.Node(indexPath: .init(), blocks: [])
            let target = first
            var blocks = target.blocks
            blocks.append(third)
            target.blocks = blocks
            target.buildIndexPaths()
        }
    }
}
