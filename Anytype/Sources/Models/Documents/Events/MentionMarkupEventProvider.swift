import AnytypeCore
import Services
import ProtobufMessages

final class MentionMarkupEventProvider {
    
    private let objectId: String
    private let infoContainer: any InfoContainerProtocol
    private let detailsStorage: ObjectDetailsStorage
        
    init(
        objectId: String,
        infoContainer: some InfoContainerProtocol,
        detailsStorage: ObjectDetailsStorage
    ) {
        self.objectId = objectId
        self.infoContainer = infoContainer
        self.detailsStorage = detailsStorage
    }
    
    func updateMentionsEvent() -> [DocumentUpdate] {
        return infoContainer
            .recursiveChildren(of: objectId)
            .compactMap { updateIfNeeded(info: $0) }
            .map { .block(blockId: $0) }
    }
    
    func updateIfNeeded(info: BlockInformation) -> String? {
        guard case let .text(content) = info.content else { return nil }
        guard !content.marks.marks.isEmpty else { return nil }
        
        var string = content.text
        var sortedMarks = content.marks.marks
            .sorted { $0.range.from < $1.range.from }
        var needUpdate = false
        
        for offset in 0..<sortedMarks.count {
            let mark = sortedMarks[offset]
            guard mark.type == .mention && mark.param.isNotEmpty else { continue }
            
            guard let mentionRange = mentionRange(in: string, range: mark.range) else { continue }
            let mentionFrom = mark.range.from
            let mentionTo = mark.range.to
            let mentionName = string[mentionRange]
            
            let mentionBlockId = mark.param
            
            guard
                let details = detailsStorage.get(id: mentionBlockId)
            else { return nil }
            
            let mentionNameInDetails = details.mentionTitle
            
            
            let previousString = string[mentionRange]
            if previousString != mentionNameInDetails {
                needUpdate = true
            }
            
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
        
        if needUpdate {
            update(info: info, string: string, marks: sortedMarks)
        }
        
        return needUpdate ? info.id : nil
    }
    
    private func mentionRange(in string: String, range: Anytype_Model_Range) -> Range<String.Index>? {
        guard range.from < string.utf16.count, range.to <= string.utf16.count else {
            anytypeAssertionFailure("Index out of bounds", info: [
                "range from": "\(range.from)",
                "range to": "\(range.to)",
                "string lenght": "\(string.utf16.count)"
            ])
            return nil
        }
        let from = string.utf16.index(string.utf16.startIndex, offsetBy: Int(range.from))
        let to = string.utf16.index(string.utf16.startIndex, offsetBy: Int(range.to))
        return from..<to
    }
    
    private func update(
        info: BlockInformation,
        string: String,
        marks: [Anytype_Model_Block.Content.Text.Mark]) {
        if case var .text(content) = info.content {
            content.text = string
            content.marks = Anytype_Model_Block.Content.Text.Marks.with { $0.marks = marks }
            infoContainer.add(
                info.updated(content: .text(content))
            )
        }
    }
}
