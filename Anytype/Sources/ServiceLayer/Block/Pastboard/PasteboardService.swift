import UIKit
import UniformTypeIdentifiers
import BlocksModels
import ProtobufMessages

private enum PasteboardSlot {
    case textSlot(String)
    case htmlSlot(String)
    case blockSlots([String])
    case fileSlots([NSItemProvider])
}

final class PasteboardService {
    private let document: BaseDocumentProtocol
    private let pasteboardOperations = OperationQueue()
    
    init(document: BaseDocumentProtocol) {
        self.document = document
    }
    
    var hasValidURL: Bool {
        if UIPasteboard.general.hasURLs, let url = UIPasteboard.general.url?.absoluteString, url.isValidURL() {
            return true
        }
        return false
    }
    
    func pasteInsideBlock(focusedBlockId: BlockId, range: NSRange) {
        paste(focusedBlockId: focusedBlockId, range: range, selectedBlockIds: nil)
    }
    
    func pasteInSelectedBlocks(selectedBlockIds: [BlockId]) {
        paste(focusedBlockId: nil, range: nil, selectedBlockIds:selectedBlockIds)
    }
    
    private func paste(focusedBlockId: BlockId?, range: NSRange?, selectedBlockIds: [BlockId]?) {
        let operation = PasteboardOperation { [weak self] completion in
            guard let self = self else { return completion() }
            
            DispatchQueue.global().async {
                self.doPaste(focusedBlockId: focusedBlockId, selectedTextRange: range, selectedBlockIds: selectedBlockIds, isPartOfBlock: false) {
                    completion()
                }
            }
        }
        pasteboardOperations.addOperation(operation)
    }
    
    func copy(blocksIds: [BlockId], selectedTextRange: NSRange) {
        let blocksInfo = blocksIds.compactMap {
            document.infoContainer.get(id: $0)
        }
        if let anySlots = copy(contextId: document.objectId, blocksInfo: blocksInfo, selectedTextRange: selectedTextRange) {
            copyToPasteboard(slots: anySlots)
        }
    }
}

// MARK: - Private methods for pasteboard

private extension PasteboardService {
    
    private func copyToPasteboard(slots: [PasteboardSlot]) {
        let pasteboard = UIPasteboard.general
        var textSlots: [String: Any] = [:]
        var allSlots: [[String: Any]] = [[:]]
        
        slots.forEach { slot in
            switch slot {
            case let .textSlot(text):
                textSlots[UTType.plainText.identifier] = text
            case let .htmlSlot(html):
                textSlots[UTType.html.identifier] = html
            case let .blockSlots(blocksSlots):
                allSlots = blocksSlots.compactMap { blockSlot in
                    [UTType.blockSlot.identifier: blockSlot.data(using: .utf8) ?? blockSlot]
                }
            case .fileSlots:
                // Don't have yet
                break
            }
        }
        allSlots.append(textSlots)
        pasteboard.setItems(allSlots)
    }
    
    private func doPaste(focusedBlockId: BlockId?,
                         selectedTextRange: NSRange?,
                         selectedBlockIds: [BlockId]?,
                         isPartOfBlock: Bool,
                         completion: @escaping () -> Void) {
        var textSlot: String? = nil
        var htmlSlot: String? = nil
        var anySlots: [Anytype_Model_Block]? = nil
        var fileSlots: [Anytype_Rpc.Block.Paste.Request.File]? = nil
        
        guard let slot = obtainSlots() else { return completion() }
        
        switch slot {
        case .textSlot(let text):
            textSlot = text
        case .htmlSlot(let html):
            htmlSlot = html
        case .blockSlots(let anyJSONSlots):
            anySlots = anyJSONSlots.compactMap { anyJSONSlot in
                try? Anytype_Model_Block(jsonString: anyJSONSlot)
            }
        case let .fileSlots(items):
            let fileQueue = OperationQueue()
            
            items.forEach { itemProvider in
                fileQueue.addOperation { [weak self] in
                    guard let self = self else { return }
                    
                    itemProvider.loadFileRepresentation(
                        forTypeIdentifier: UTType.data.identifier
                    ) { temporaryUrl, error in
                        guard let temporaryUrl = temporaryUrl?.relativePath else {
                            return
                        }
                        let name = itemProvider.suggestedName ?? ""
                        fileSlots = [Anytype_Rpc.Block.Paste.Request.File(name: name, data: Data(), localPath: temporaryUrl)]
                        
                        self.paste(contextId: self.document.objectId,
                                   focusedBlockId: focusedBlockId,
                                   selectedTextRange: selectedTextRange,
                                   selectedBlockIds: selectedBlockIds,
                                   isPartOfBlock: isPartOfBlock,
                                   textSlot: textSlot,
                                   htmlSlot: htmlSlot,
                                   anySlots: anySlots,
                                   fileSlots: fileSlots)
                        
                    }
                }
            }
            fileQueue.addBarrierBlock {
                completion()
            }
            return
        }
        
        self.paste(contextId: document.objectId,
                   focusedBlockId: focusedBlockId,
                   selectedTextRange: selectedTextRange,
                   selectedBlockIds: selectedBlockIds,
                   isPartOfBlock: isPartOfBlock,
                   textSlot: textSlot,
                   htmlSlot: htmlSlot,
                   anySlots: anySlots,
                   fileSlots: fileSlots)
        completion()
    }
    
    private func obtainSlots() -> PasteboardSlot? {
        let pasteboard = UIPasteboard.general
        var fileSlot: [NSItemProvider] = []
        
        // Find first item to paste with follow order anySlots, htmlSlot, textSlot, fileSlots
        // anySlots
        if pasteboard.contains(pasteboardTypes: [UTType.blockSlot.identifier], inItemSet: nil) {
            if let pasteboardData = pasteboard.values(
                forPasteboardType: UTType.blockSlot.identifier,
                inItemSet: nil
            ) as? [Data] {
                let anySlots = pasteboardData.compactMap { data in
                    String(data: data, encoding: .utf8)
                }
                if anySlots.isNotEmpty {
                    return .blockSlots(anySlots)
                }
            }
        }
        
        // htmlSlot
        if pasteboard.contains(pasteboardTypes: [UTType.html.identifier], inItemSet: nil) {
            let data = pasteboard.data(
                forPasteboardType: UTType.html.identifier,
                inItemSet: nil
            )
            
            if let data = data?.first, let htmlSlot = String(data: data, encoding: .utf8) {
                return .htmlSlot(htmlSlot)
            }
        }
        
        // textSlot
        if pasteboard.contains(pasteboardTypes: [UTType.plainText.identifier], inItemSet: nil) {
            let text = pasteboard.value(forPasteboardType: UTType.text.identifier)
            
            if let text = text as? String {
                return .textSlot(text)
            }
        }
        
        // fileSlots
        pasteboard.itemProviders.forEach { itemProvider in
            fileSlot.append(itemProvider)
        }
        if fileSlot.isNotEmpty {
            return .fileSlots(fileSlot)
        }
        
        // pasteboard is empty
        return nil
    }
}


// MARK: - Private methods for middle

private extension PasteboardService {
    
    private func paste(contextId: BlockId,
                       focusedBlockId: BlockId?,
                       selectedTextRange: NSRange?,
                       selectedBlockIds: [BlockId]?,
                       isPartOfBlock: Bool,
                       textSlot: String?,
                       htmlSlot: String?,
                       anySlots:  [Anytype_Model_Block]?,
                       fileSlots: [Anytype_Rpc.Block.Paste.Request.File]?) {
        
        let result = Anytype_Rpc.Block.Paste.Service.invoke(
            contextID: contextId,
            focusedBlockID: focusedBlockId ?? "",
            selectedTextRange: selectedTextRange?.asMiddleware ?? Anytype_Model_Range(),
            selectedBlockIds: selectedBlockIds ?? [],
            isPartOfBlock: isPartOfBlock,
            textSlot: textSlot ?? "",
            htmlSlot: htmlSlot ?? "",
            anySlot: anySlots ?? [],
            fileSlot: fileSlots ?? []
        )
            .getValue(domain: .blockActionsService)
        
        let events = result.map {
            EventsBunch(event: $0.event)
        }
        events?.send()
    }
    
    private func copy(contextId: BlockId, blocksInfo: [BlockInformation], selectedTextRange: NSRange) -> [PasteboardSlot]? {
        let blockskModels = blocksInfo.compactMap {
            BlockInformationConverter.convert(information: $0)
        }
        
        let result = Anytype_Rpc.Block.Copy.Service.invoke(
            contextID: contextId,
            blocks: blockskModels,
            selectedTextRange: selectedTextRange.asMiddleware
        )
            .getValue(domain: .blockActionsService)
        
        if let result = result {
            let anySlot = result.anySlot.compactMap { modelBlock in
                try? modelBlock.jsonString()
            }
            return [.htmlSlot(result.htmlSlot), .textSlot(result.textSlot), .blockSlots(anySlot)]
        }
        return nil
    }
}

extension UIPasteboard {
    var hasSlots: Bool {
        UIPasteboard.general.contains(pasteboardTypes: [UTType.html.identifier], inItemSet: nil) ||
        UIPasteboard.general.contains(pasteboardTypes: [UTType.utf8PlainText.identifier])
    }
}
