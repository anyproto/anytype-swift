//
//  DashboardEventHandler.swift
//  AnyType
//
//  Created by Batvinkin Denis on 22.03.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import os
import BlocksModels

private extension Logging.Categories {
  static let dashboardEventHandler: Self = "Services.DashboardEventHandler"
}

extension HomeCollectionViewModel: EventHandler {
    typealias Event = Anytype_Event.Message.OneOf_Value

	func handleEvent(event: Event) {
		switch event {
		case .blockSetLink(let setLink):
			self.updatePages(setLink: setLink)
			break
		case .blockShow(let blockShow):
			self.processPages(blockShow: blockShow)
		case .blockAdd(let addBlock):
			self.addPage(addBlock: addBlock)
		default:
		  let logger = Logging.createLogger(category: .dashboardEventHandler)
		  os_log(.debug, log: logger, "we handle only events above. Event %@ isn't handled", String(describing: event))
			return
		}
	}
}

extension HomeCollectionViewModel {
    // TODO: Rethink current implementation.
    // We should build DashboardView on top of DocumentViewModel.
    // In this case we could take all updates for nothing.
    private func parser() -> BlocksModelsModule.Parser {
        .init()
    }
    private func update(page: DashboardPage?, details: Anytype_Event.Block.Set.Details?) -> DashboardPage? {
        guard let page = page else { return nil }
        
        var title: String? = nil
        var iconEmoji: String? = nil
        if let details = details {
            let convertedDetails = BlocksModelsModule.Parser.PublicConverters.EventsDetails.convert(event: details)
            let correctedDetails = BlocksModelsModule.Parser.Details.Converter.asModel(details: convertedDetails)
            let information = TopLevel.Builder.detailsBuilder.informationBuilder.build(list: correctedDetails)
            let informationAccessor = TopLevel.AliasesMap.DetailsUtilities.InformationAccessor.init(value: information)
            title = informationAccessor.title?.value
            iconEmoji = informationAccessor.iconEmoji?.value
        }
        
        return .init(id: page.id, targetBlockId: page.targetBlockId, title: title, iconEmoji: iconEmoji, style: page.style)
    }
    private func convert(page: Anytype_Model_Block?, details: Anytype_Event.Block.Set.Details?) -> DashboardPage? {
        guard let page = page, case let .link(value) = page.content else {
            return nil
        }
        var title: String? = nil
        var iconEmoji: String? = nil
        if let details = details {
            let convertedDetails = BlocksModelsModule.Parser.PublicConverters.EventsDetails.convert(event: details)
            let correctedDetails = BlocksModelsModule.Parser.Details.Converter.asModel(details: convertedDetails)
            let information = TopLevel.Builder.detailsBuilder.informationBuilder.build(list: correctedDetails)
            let informationAccessor = TopLevel.AliasesMap.DetailsUtilities.InformationAccessor.init(value: information)
            title = informationAccessor.title?.value
            iconEmoji = informationAccessor.iconEmoji?.value
        }
        return .init(id: page.id, targetBlockId: value.targetBlockID, title: title, iconEmoji: iconEmoji, style: value)
    }
    private func convert(pages: [Anytype_Model_Block], details: [Anytype_Event.Block.Set.Details]) -> [DashboardPage] {
        let dictionary: [String: DashboardPage?] = .init(uniqueKeysWithValues: pages.map({ value in
            switch value.content {
            case let .link(link): return (link.targetBlockID, self.convert(page: value, details: nil))
            default: return (value.id, self.convert(page: value, details: nil))
            }
        }))
        var newDictionary = dictionary.compactMapValues({$0})
        details.forEach { (value) in
            newDictionary[value.id] = self.update(page: newDictionary[value.id], details: value)
        }
        return newDictionary.compactMap({$0.value})
    }
    
    // MARK: - Page processing
    /// Sorting pages according to order in rootPage.childrenIds.
    /// - Parameters:
    ///   - rootId: the Id of root page.
    ///   - pages: [rootPage] + rootPage.pages
    private func processPages(blockShow: Anytype_Event.Block.Show) {
        self.rootId = blockShow.rootID
        let pages = blockShow.blocks

        // obtain root page
        guard let rootPage = pages.first(where: { $0.id == rootId }) else { return }
        let indices = rootPage.childrenIds

        let ourPages = self.convert(pages: pages, details: blockShow.details)
        
        // sort pages
        let dictionary: [String: DashboardPage] = .init(uniqueKeysWithValues: ourPages.map({($0.id, $0)}))

        self.dashboardPages = indices.compactMap { dictionary[$0] }
    }

    private func addPage(addBlock: Anytype_Event.Block.Add) {
        self.dashboardPages += self.convert(pages: addBlock.blocks, details: [])
    }

    private func updatePages(setLink: Anytype_Event.Block.Set.Link) {
        return
        guard setLink.hasFields, setLink.fields.hasValue else { return }

        // find page
        var pageToUpdate = self.dashboardPages.first(where: { page -> Bool in
            page.id == setLink.id
        })

        // update page
//        pageToUpdate?.fields.fields["name"] = setLink.fields.value.fields["name"]
        // TODO: add update icon
    }
}
