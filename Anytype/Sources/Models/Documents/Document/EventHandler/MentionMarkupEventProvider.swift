import AnytypeCore
import BlocksModels
import ProtobufMessages

final class MentionMarkupEventProvider {
    
    private enum Constants {
        static let threshold: CFTimeInterval = 0.05
    }
    
    private weak var container: RootBlockContainer?
    private let timeChecker = TimeChecker(threshold: Constants.threshold)
    
    init(container: RootBlockContainer) {
        self.container = container
    }
    
    func updateMentionsEvent() -> EventHandlerUpdate {
        guard let rootId = container?.rootId,
              timeChecker.exceedsTimeInterval(),
              let allBlockIds = container?.blocksContainer.children(of: rootId)else {
            return .update(blockIds: [])
        }
        
        let blockModels = allBlockIds.compactMap { container?.blocksContainer.model(id: $0) }
        
        var blockIdsForUpdate = Set<String>()
      
        blockModels.forEach { model in
            guard case let .text(content) = model.information.content else { return }

            guard !content.marks.marks.isEmpty else { return }
            
            var string = content.text
            
            var sortedMarks = content.marks.marks.sorted { $0.range.from < $1.range.from }
            
            for offset in 0..<sortedMarks.count {
                let mark = sortedMarks[offset]
                if mark.type != .mention || mark.param.isEmpty {
                    continue
                }
                
                guard let mentionRange = mentionRange(
                        in: string,
                        range: mark.range
                ) else { return }
                let mentionFrom = mark.range.from
                let mentionTo = mark.range.to
                let mentionName = string[mentionRange]
                
                let details = container?.detailsContainer.get(by: mark.param)
                guard let mentionNameInDetails = details?.detailsData.name else { return }
                
                if mentionName != mentionNameInDetails {
                    blockIdsForUpdate.insert(model.information.id)
                    let countDelta = Int32(mentionName.count - mentionNameInDetails.count)

                    string.replaceSubrange(mentionRange, with: mentionNameInDetails)
                    
                    if countDelta != 0 {
                        var mentionMark = mark
                        mentionMark.range.to -= countDelta
                        sortedMarks[offset] = mentionMark
                        
                        for counter in 0..<sortedMarks.count {
                            var mark = sortedMarks[counter]
                            if counter == offset || mark.range.to <= mentionFrom {
                                continue
                            }
                            
                            if mark.range.from >= mentionTo {
                                mark.range.from -= countDelta
                            }
                            mark.range.to -= countDelta
                            sortedMarks[counter] = mark
                        }
                        
                    }
                }
                
            }
            if blockIdsForUpdate.contains(model.information.id) {
                update(
                    model: model,
                    string: string,
                    marks: sortedMarks
                )
            }
        }
        return .update(blockIds: blockIdsForUpdate)
    }
    
    private func mentionRange(
        in string: String,
        range: Anytype_Model_Range
    ) -> Range<String.Index>? {
        guard range.from < string.count,
              range.to <= string.count else {
            anytypeAssertionFailure("Index out of bounds \(range) in \(string)")
            return nil
        }
        let from = string.index(string.startIndex, offsetBy: Int(range.from))
        let to = string.index(string.startIndex, offsetBy: Int(range.to))
        return from..<to
    }
    
    private func update(
        model: BlockModelProtocol,
        string: String,
        marks: [Anytype_Model_Block.Content.Text.Mark]) {
        if case var .text(content) = model.information.content {
            content.text = string
            content.marks = Anytype_Model_Block.Content.Text.Marks(marks: marks)
            var model = model
            model.information.content = .text(content)
        }
    }
}
