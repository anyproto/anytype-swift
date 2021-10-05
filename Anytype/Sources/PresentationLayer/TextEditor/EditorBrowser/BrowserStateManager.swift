import BlocksModels
import AnytypeCore

final class BrowserStateManager {
    var nextIsForward = false
    var lastClosedPage: BlockId? {
        closedPages.last
    }
    
    private var openedPages: [BlockId] = []
    private var closedPages: [BlockId] = []
    private var cachedChildrenCount = 0
    
    func didShow(blockId: BlockId, childernCount: Int) {
        fixStateForChachedPage(childernCount: childernCount)
        
        if nextIsForward {
            forwardAction(blockId: blockId)
            return
        }
        
        if cachedChildrenCount > childernCount {
            closeAction()
        } else if cachedChildrenCount < childernCount {
            openAction(blockId: blockId)
        } else {
            printError(blockId: blockId, childernCount: childernCount)
        }
    }
    
    
    // didShow dont called if we open cached page on startup
    // add fake id of root page
    private func fixStateForChachedPage(childernCount: Int) {
        if cachedChildrenCount == 0 && childernCount > 1{
            openedPages.append("fakeIdOfTheRoot")
            cachedChildrenCount = 1
        }
    }
    
    private func forwardAction(blockId: BlockId) {
        openedPages.append(blockId)
        _ = closedPages.popLast()
        cachedChildrenCount += 1
        nextIsForward = false
    }
    
    private func closeAction() {
        guard let closedBlockId = openedPages.popLast() else {
            anytypeAssertionFailure("Empty opened pages list")
            return
        }
        closedPages.append(closedBlockId)
        cachedChildrenCount -= 1
    }
    
    private func openAction(blockId: BlockId) {
        openedPages.append(blockId)
        closedPages = []
        cachedChildrenCount += 1
    }
    
    private func printError(blockId: BlockId, childernCount: Int) {
        anytypeAssertionFailure(
            """
            Broken state of browser.
            PageId: \(blockId)
            OpenedPages: \(openedPages)
            ClosedPages: \(closedPages)
            CurrentChildernConunt: \(childernCount)
            CachedChildrenCount: \(cachedChildrenCount)
            """
        )
    }
}
