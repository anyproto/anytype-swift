import SwiftUI

struct DocumentIconPicker: View {
    
    @EnvironmentObject var iconViewModel: DocumentIconPickerViewModel
    
    @Environment(\.presentationMode) private var presentationMode
    
    private enum IconTab {
        case emoji
        case random
        case upload
        
        var title: String {
            switch self {
            case .emoji: return "Emoji"
            case .random: return "Random"
            case .upload: return "Upload"
            }
        }
    }
    
    @State private var imageURL: URL?
    @State private var tabSelection: IconTab = .emoji
    
    var body: some View {
        VStack(spacing: 0) {
            if tabSelection == .emoji {
                emojiTab
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .trailing)
                        )
                    )
            } else if tabSelection == .upload {
                MediaPickerView(
                    selectedMediaUrl: $imageURL,
                    contentType: .images
                )
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    )
                )
                
            }
            tabHeaders
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private var emojiTab: some View {
        VStack(spacing: 0) {
            DragIndicator(bottomPadding: 0)
            navigationBarView
            EmojiGridView()
        }
    }
    
    private var navigationBarView: some View {
        HStack {
            Spacer()
                .frame(maxWidth: .infinity)
            AnytypeText("Chanje icon", style: .headlineSemibold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            HStack {
                Spacer()
                Button {
                    iconViewModel.removeIcon()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    AnytypeText("Remove", style: .headline)
                        .foregroundColor(.red)
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 48)
    }
    
    private var tabHeaders: some View {
        HStack {
            Button {
                UISelectionFeedbackGenerator().selectionChanged()
                withAnimation {
                    tabSelection = .emoji
                }
                
            } label: {
                AnytypeText(IconTab.emoji.title, style: .headline)
                    .foregroundColor(tabSelection == .emoji ? Color.buttonSelected : Color.buttonActive)
            }
            .frame(maxWidth: .infinity)
            
            Button {
                UISelectionFeedbackGenerator().selectionChanged()
                EmojiProvider.shared.randomEmoji().flatMap {
                    iconViewModel.setEmoji($0.unicode)
                    presentationMode.wrappedValue.dismiss()
                }
                
            } label: {
                AnytypeText(IconTab.random.title, style: .headline)
                    .foregroundColor(Color.buttonActive)
            }
            .frame(maxWidth: .infinity)
            
            Button {
                UISelectionFeedbackGenerator().selectionChanged()
                withAnimation {
                    tabSelection = .upload
                }
                
            } label: {
                AnytypeText(IconTab.upload.title, style: .headline)
                    .foregroundColor(tabSelection == .upload ? Color.buttonSelected : Color.buttonActive)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 48)
    }
    
}

struct DocumentIconPicker_Previews: PreviewProvider {
    static var previews: some View {
        DocumentIconPicker()
    }
}
