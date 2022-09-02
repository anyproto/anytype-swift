import BlocksModels
import AnytypeCore
import UIKit

extension BrowserNavigationManager {
    private enum State {
        case `default`
        case movingForwardOnce
        case movingForward(index: Int)
        case movingBack(index: Int)
    }
}

final class BrowserNavigationManager {
    private(set) var openedPages: [BrowserPage] = []
    private(set) var closedPages: [BrowserPage] = []
    
    private var state = State.default
    private var cachedChildrenCount = 0

    func moveForwardOnce() -> Bool {
        guard case .default = state else { return false }
        
        state = .movingForwardOnce

        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.goForward)

        return true
    }
    
    func moveForward(page: BrowserPage) throws {
        guard case .default = state else { return }
        
        guard let index = closedPages.firstIndex(of: page) else {
            throw BrowserNavigationManagerError.moveForward(page: page)
        }

        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.goForward)
        
        state = .movingForward(index: index)
    }
    
    func moveBack(page: BrowserPage) throws {
        guard let index = openedPages.firstIndex(of: page) else {
            throw BrowserNavigationManagerError.moveBack(page: page)
        }

        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.goBack)

        state = .movingBack(index: index)
    }
    
    func didShow(page: BrowserPage, childernCount: Int) throws {
        switch state {
        case .movingBack(index: let index):
            movingBackAction(index: index)
        case .movingForward(index: let index):
            movingForwardAction(index: index)
        case .movingForwardOnce:
            forwardAction(page: page)
        case .default:
            try defaultAction(page: page, childernCount: childernCount)
        }
        
        state = .default
    }
    
    private func defaultAction(page: BrowserPage, childernCount: Int) throws {
        // didShow called twice in the first open
        if cachedChildrenCount == 1 && childernCount == 1 { return }
        
        if cachedChildrenCount > childernCount {
            closeAction()
        } else if cachedChildrenCount < childernCount {
            openAction(page: page)
        } else if cachedChildrenCount == childernCount { // Replace view controller happen
            closeAction()
            openAction(page: page)
        }
    }
    
    private func movingForwardAction(index: Int) {
        openedPages.append(closedPages[index])
        closedPages = Array(closedPages[0 ..< index])
        cachedChildrenCount += 1
    }
    
    private func movingBackAction(index: Int) {
        let newClosedPages = openedPages[(index + 1)..<openedPages.count].reversed()
        closedPages.append(contentsOf: newClosedPages)
        openedPages = Array(openedPages[0...index])
        cachedChildrenCount = index + 1
    }
    
    private func forwardAction(page: BrowserPage) {
        openedPages.append(page)
        _ = closedPages.popLast()
        cachedChildrenCount += 1
    }
    
    private func closeAction() {
        guard let closedBlockId = openedPages.popLast() else {
            anytypeAssertionFailure("Empty opened pages list", domain: .editorBrowser)
            return
        }
        closedPages.append(closedBlockId)
        cachedChildrenCount -= 1
    }
    
    private func openAction(page: BrowserPage) {
        openedPages.append(page)
        closedPages = []
        cachedChildrenCount += 1
    }
}
