import SwiftUI

struct SetTableViewHeader: View {
    @EnvironmentObject private var model: EditorSetViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LazyHStack(spacing: 0) {
                ForEach(model.colums, id: \.key) { data in
                    HStack(spacing: 0) {
                        Spacer.fixedWidth(15)
                        if data.isReadOnly {
                            Image.Relations.lockedSmall
                            Spacer.fixedWidth(4)
                        }
                        AnytypeText(data.name, style: .relation2Regular, color: .textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Spacer()
                    }.frame(width: 144)
                    
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
