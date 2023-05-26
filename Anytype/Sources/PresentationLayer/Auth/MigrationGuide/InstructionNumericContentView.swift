import SwiftUI

struct InstructionNumericContentView: View {
    
    struct Message {
        var text: String
        var onTap: (() -> Void)? = nil
    }
    
    let messages: [Message]
    
    @ViewBuilder
    var body: some View {
        ForEach(0..<messages.count, id: \.self) { index in
            numericLine(number: index + 1, message: messages[index])
        }
    }
    
    @ViewBuilder
    private func numericLine(number: Int, message: Message) -> some View {
        HStack(alignment: .top, spacing: 0) {
            AnytypeText("\(number). ", style: .uxCalloutRegular, color: .Text.primary)
            AnytypeText(message.text, style: .uxCalloutRegular, color: .Text.primary, isRich: true)
                .ifLet(message.onTap) { view, onTap in
                    view.onTapGesture {
                        onTap()
                    }
                }
        }
    }
}
