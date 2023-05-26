import Foundation
import Logger

public enum ErrorDomain: String {
    case quickAction
    case userDefaults
    case debug
    case middlewareEvents
    
    case middlewareConfigurationProvider
    case anytypeImageDownloader
    case contentUrlBuilder
    case imageGuideline
    case imageViewWrapper
    
    case imageCreation
    case colorCreation
    case fileLoader
    case diskStorage
    case camera
    
    case blockBuilder
    case localEventConverter
    case localEventConverterSetFocus
    case middlewareEventConverter
    case objectDetails
    case relationsBuilder
    case arrayExtension
    
    case blockInformationCreator
    case blockContainer
    case blockDelegate
    case blocksConverter
    case blockValidator

    case unsplash
    case blockImage
    case unknownLabel
    case unsupportedBlock
    case blockVideo
    
    case editorBrowser
    case editorPage
    case editorSet
    case editorSetPagination
    case loadingController
    
    case markStyleModifier
    case markupChanger
    case markStyleConverter
    case blockMarkupChanger
    case markupViewModel
    case mentionMarkup
    case markdownListener
    
    case anytypeText
    case iconEmoji
    case anytypeColor
    case mergedArray
    
    case keyboardActionHandler
    case blockActionsService
    case objectActionsService
    case keyboardListner
    case textLayout
    case textConverter
    case searchService
    case bookmarkService
    case pageService
    case textService
    case relationsService
    case blockListService
    case authService
    case subscriptionService
    case subscriptionStorage
    case detailsStorage
    case dataviewService
    case simpleTablesService
    case relationDetailsStorage
    case groupsSubscribeService
    case workspaceService
    case blockWidgetService
    case fileService
    
    case homeView
    case baseDocument
    case protobufConverter
    case restrictionsConverter
    
    case iconPicker
    case appIcon
    
    case calendar
    case anytypeId
    
    case sceneLifecycleStateService

    case simpleTables
    
    case objectTypeProvider
    case objectTypeSearch
    case relationSearch
}

extension AssertionLogger {
    
    @inlinable
    public func log(
        _ message: String,
        domain: ErrorDomain,
        info: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(message, domain: domain.rawValue, info: info, file: file, function: function, line: line)
    }
}
