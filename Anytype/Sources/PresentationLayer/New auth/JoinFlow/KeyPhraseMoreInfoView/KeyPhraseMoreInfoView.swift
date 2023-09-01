import SwiftUI

struct KeyPhraseMoreInfoView: View {
    
    var body: some View {
        VStack(spacing: 20) {
            DragIndicator()
            ScrollView(.vertical, showsIndicators: false) {
                Spacer.fixedHeight(26)
                
                AnytypeText(Loc.Auth.JoinFlow.Key.ReadMore.title, style: .heading, color: .Auth.inputText)
                    .multilineTextAlignment(.center)
                
                Spacer.fixedHeight(32)
                
                optionsRows
                
                Spacer.fixedHeight(28)
                
                instruction
            }
        }
        .padding(.horizontal, 24)
        .background(Color.Background.secondary)
        .preferredColorScheme(.dark)
    }
    
    private var optionsRows: some View {
        VStack(alignment: .leading, spacing: 16) {
            optionRow(for: "🎲", description: Loc.Auth.JoinFlow.Key.ReadMore.Option1.title)
            optionRow(for: "🪪", description: Loc.Auth.JoinFlow.Key.ReadMore.Option2.title)
            optionRow(for: "☝️", description: Loc.Auth.JoinFlow.Key.ReadMore.Option3.title)
        }
    }
    
    private func optionRow(for emoji: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading) {
                AnytypeText(emoji, style: .authEmoji, color: .Auth.inputText)
            }
            .frame(width: 56, height: 56)
            AnytypeText(description, style: .bodyRegular, color: .Auth.inputText)
        }
    }
    
    private var instruction: some View {
        ZStack {
            Color.Background.highlightedOfSelected
                .opacity(0.9)
            instructionContent
        }
        .cornerRadius(8)
    }
    
    private var instructionContent: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(16)
            
            Image(asset: .X18.lock)
                .foregroundColor(.Button.active)
            
            Spacer.fixedHeight(12)
            
            AnytypeText(Loc.Auth.JoinFlow.Key.ReadMore.Instruction.title, style: .subheading, color: .Auth.inputText)
            
            Spacer.fixedHeight(12)
            
            instructionsRows
            
            Spacer.fixedHeight(24)
        }
        .padding(.horizontal, 24)
    }
    
    private var instructionsRows: some View {
        VStack(alignment: .leading, spacing: 12) {
            instructionRow(description: Loc.Auth.JoinFlow.Key.ReadMore.Instruction.Option1.title)
            instructionRow(description: Loc.Auth.JoinFlow.Key.ReadMore.Instruction.Option2.title)
        }
    }
    
    private func instructionRow(description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            AnytypeText("•", style: .bodyRegular, color: .Auth.inputText)
            AnytypeText(description, style: .uxCalloutRegular, color: .Auth.inputText)
        }
    }
}


struct KeyPhraseMoreInfoView_Previews : PreviewProvider {
    static var previews: some View {
        KeyPhraseMoreInfoView()
    }
}
