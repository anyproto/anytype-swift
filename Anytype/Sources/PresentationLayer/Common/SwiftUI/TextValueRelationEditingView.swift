import SwiftUI

struct TextValueRelationEditingView: View {
    @State var text: String = ""
    
    var body: some View {
        TextEditor(text: $text)
            .padding()
    }
}

struct TextValueRelationEditingView_Previews: PreviewProvider {
    static var previews: some View {
        TextValueRelationEditingView()
    }
}
