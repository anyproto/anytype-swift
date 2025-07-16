import Foundation
import ProtobufMessages

extension BlockLatex {
    func handleSetLatex(data: Anytype_Event.Block.Set.Latex) -> Self {
        var blockLatex = self

        if data.hasProcessor {
            blockLatex.processor = data.processor.value
        }
        
        if data.hasText {
            blockLatex.text = data.text.value
        }

        return blockLatex
    }
}
