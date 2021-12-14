import SwiftUI

struct SetTableViewHeader: View {
    @EnvironmentObject private var model: EditorSetViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                ForEach(model.colums, id: \.key) { name in
                    AnytypeText(name.value, style: .relation2Regular, color: .textSecondary)
                        .frame(width: 144)
                    
                    Rectangle()
                        .frame(width: 0.5, height: 18)
                        .foregroundColor(.grayscale30)
                }
            }
            .frame(height: 40)
            Divider()
        }
    }
}

struct SetTableViewHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetTableViewHeader()
    }
}
