import Foundation
import Factory

public extension Container {
    
    var audioSessionService: Factory<AudioSessionServiceProtocol> {
        self { AudioSessionService() }.singleton
    }
    
    var authMiddleService: Factory<AuthMiddleServiceProtocol> {
        self { AuthMiddleService() }.shared
    }
    
    var blockService: Factory<BlockServiceProtocol> {
        self { BlockService() }.shared
    }
    
    var blockTableService: Factory<BlockTableServiceProtocol> {
        self { BlockTableService() }.shared
    }
    
    var blockWidgetService: Factory<BlockWidgetServiceProtocol> {
        self { BlockWidgetService() }.shared
    }
    
    var bookmarkService: Factory<BookmarkServiceProtocol> {
        self { BookmarkService() }.shared
    }
    
    var dataviewService: Factory<DataviewServiceProtocol> {
        self { DataviewService() }.shared
    }
    
    var debugService: Factory<DebugServiceProtocol> {
        self { DebugService() }.shared
    }
}
