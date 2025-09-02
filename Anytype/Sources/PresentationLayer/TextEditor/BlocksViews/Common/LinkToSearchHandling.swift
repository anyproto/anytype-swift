import Foundation
import UIKit
import AnytypeCore
import Services
import Factory


protocol LinkToSearchDelegate: AnyObject {
    func updateTextForLinkToObject(newText: NSAttributedString, range: NSRange, originalText: NSAttributedString)
    func updateTextForLinkToUrl(newText: NSAttributedString, range: NSRange, originalText: NSAttributedString)
    func removeLink(markup: MarkupType, newText: NSAttributedString, range: NSRange, originalText: NSAttributedString)
    func openLinkToObject(data: LinkToObjectSearchModuleData)
}

protocol LinkToSearchHelperProtocol {
    func showLinkToSearch(
        range: NSRange,
        text: NSAttributedString,
        delegate: LinkToSearchDelegate,
        document: any BaseDocumentProtocol,
        markupChanger: any BlockMarkupChangerProtocol,
        info: BlockInformation
    )
}

@MainActor
final class LinkToSearchHelper: LinkToSearchHelperProtocol {
    
    func showLinkToSearch(
        range: NSRange,
        text: NSAttributedString,
        delegate: LinkToSearchDelegate,
        document: any BaseDocumentProtocol,
        markupChanger: any BlockMarkupChangerProtocol,
        info: BlockInformation
    ) {
        let urlLink = text.linkState(range: range)
        let objectIdLink = text.linkToObjectState(range: range)
        let eitherLink: Either<URL, String>? = urlLink.map { .left($0) } ?? objectIdLink.map { .right($0) } ?? nil
    
        let data = LinkToObjectSearchModuleData(
            spaceId: document.spaceId,
            currentLinkUrl: text.linkState(range: range),
            currentLinkString: text.linkToObjectState(range: range),
            route: .link,
            setLinkToObject: { [weak delegate] linkBlockId in
                guard let delegate = delegate else { return }
                AnytypeAnalytics.instance().logChangeTextStyle(markupType: MarkupType.linkToObject(linkBlockId), objectType: .custom)
                let newText = markupChanger.setMarkup(.linkToObject(linkBlockId), range: range, attributedString: text, contentType: info.content.type)
                delegate.updateTextForLinkToObject(newText: newText, range: range, originalText: text)
            },
            setLinkToUrl: { [weak delegate] url in
                guard let delegate = delegate else { return }
                let newText = markupChanger.setMarkup(
                    .link(url),
                    range: range,
                    attributedString: text,
                    contentType: info.content.type
                )
                delegate.updateTextForLinkToUrl(newText: newText, range: range, originalText: text)
            },
            removeLink: { [weak delegate] in
                guard let delegate = delegate else { return }
                switch eitherLink {
                case .right:
                    let newText = markupChanger.removeMarkup(.linkToObject(nil), range: range, contentType: info.content.type, attributedString: text)
                    delegate.removeLink(markup: .linkToObject(nil), newText: newText, range: range, originalText: text)
                case .left:
                    let newText = markupChanger.removeMarkup(.link(nil), range: range, contentType: info.content.type, attributedString: text)
                    delegate.removeLink(markup: .link(nil), newText: newText, range: range, originalText: text)
                case .none:
                    break
                }
            },
            willShowNextScreen: nil
        )
        delegate.openLinkToObject(data: data)
    }
}

extension Container {
    var linkToSearchHelper: Factory<any LinkToSearchHelperProtocol> {
        self { LinkToSearchHelper() }.shared
    }
}
