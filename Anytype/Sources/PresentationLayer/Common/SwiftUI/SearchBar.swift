import SwiftUI

struct SearchBar: View {
    
    @Binding var text: String
        
    var body: some View {
        TextField(
            "Search",
            text: $text
        )
        .padding(8)
        .padding(.horizontal, 25)
        .font(AnytypeFontBuilder.font(textStyle: .headline))
        .background( Color.grayscale10)
        .cornerRadius(10)
        .overlay(overlay)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
    
    private var overlay: some View {
        HStack {
            Image.SearchBar.magnifyingglass
                .foregroundColor(.gray)
                .frame(minWidth: 0,
                       maxWidth: .infinity,
                       alignment: .leading
                )
                .padding(.leading, 8)
            
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                    
                }) {
                    Image.SearchBar.circleFill
                        .foregroundColor(.gray)
                        .padding(.trailing, 8)
                }
            }
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""))
    }
}
