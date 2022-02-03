import Foundation

enum BrowserNavigationManagerError: Error, LocalizedError {
    case moveForward(page: BrowserPage)
    case moveBack(page: BrowserPage)
    case didShow(page: BrowserPage, openedPages: [BrowserPage], closedPages: [BrowserPage], childernCount: Int, cachedChildrenCount: Int)
    
    var errorDescription: String? {
        switch self {
        case .moveForward(page: let page):
            return "Not found in opened pages: \(page)"
        case .moveBack(page: let page):
            return "Not found in opened pages: \(page)"
        case let .didShow(page, openedPages, closedPages, childernCount, cachedChildrenCount):
            return """
            Broken state of browser.
            Page: \(page)
            OpenedPages: \(openedPages)
            ClosedPages: \(closedPages)
            CurrentChildernCount: \(childernCount)
            CachedChildrenCount: \(cachedChildrenCount)
            """
        }
    }
}
