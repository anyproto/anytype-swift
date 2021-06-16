import SwiftUI

struct DocumentIconPicker: View {
    
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
    
    @State private var tabSelection: IconTab = .emoji
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator(bottomPadding: 0)
            navigationBarView
            TabView(selection: $tabSelection) {
                EmojiGridView().tag(IconTab.emoji)
                
                Text("Upload").tag(IconTab.upload)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            tabHeaders
        }
        .ignoresSafeArea(.keyboard)
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
                    debugPrint("")
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
                tabSelection = .emoji
            } label: {
                AnytypeText(IconTab.emoji.title, style: .headline)
                    .foregroundColor(tabSelection == .emoji ? Color.buttonSelected : Color.buttonActive)
            }
            .frame(maxWidth: .infinity)
            
            Button {
                tabSelection = .random
            } label: {
                AnytypeText(IconTab.random.title, style: .headline)
                    .foregroundColor(tabSelection == .random ? Color.buttonSelected : Color.buttonActive)
            }
            .frame(maxWidth: .infinity)
            
            Button {
                tabSelection = .upload
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
