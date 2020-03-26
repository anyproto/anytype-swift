//
//  DashboardEventHandler.swift
//  AnyType
//
//  Created by Batvinkin Denis on 22.03.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import os

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

        // sort pages
        let dictionary = pages.reduce([String : Anytype_Model_Block]()) { (result, block) in
            var result = result
            result[block.id] = block
            return result
        }
        self.dashboardPages = indices.compactMap { dictionary[$0] }
    }

    private func addPage(addBlock: Anytype_Event.Block.Add) {
        self.dashboardPages += addBlock.blocks
    }

    private func updatePages(setLink: Anytype_Event.Block.Set.Link) {
        guard setLink.hasFields, setLink.fields.hasValue else { return }

        // find page
        var pageToUpdate = self.dashboardPages.first(where: { page -> Bool in
            page.id == setLink.id
        })

        // update page
        pageToUpdate?.fields.fields["name"] = setLink.fields.value.fields["name"]
        // TODO: add update icon
    }
}
