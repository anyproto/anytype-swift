import SwiftUI

struct EditorSetView: View {
    @ObservedObject var model: EditorSetViewModel
    
    var body: some View {
        VStack {
            header
            settings
            SetTableView()
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }
    
    private var header: some View {
        VStack(alignment: .leading) {
            Rectangle().foregroundColor(.pureBlue)
                .frame(height: 240)
            AnytypeText("Set title", style: .title, color: .textPrimary).padding()
            AnytypeText("Set description", style: .body, color: .textPrimary)
                .padding()
        }
    }
    
    private var settings: some View {
        HStack {
            AnytypeText("All employees", style: .heading, color: .textPrimary)
                .padding()
            Image.arrow.rotationEffect(.degrees(90))
            Spacer()
            Image.ObjectAction.template.padding()
        }
        .frame(height: 56)
    }
}

struct EditorSetView_Previews: PreviewProvider {
    static var previews: some View {
        EditorSetView(model: EditorSetViewModel(document: BaseDocument(objectId: "")))
    }
}
