import SwiftUI

struct DateRelationDetailsRowView: View {
    
    let value: DateRelationDetailsValue
    let isSelected: Bool
    @Binding var date: Date
    let onTap: () -> ()
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer.fixedHeight(12)
            content
            Spacer.fixedHeight(12)
        }
        .divider()
    }
    
    private var content: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 0) {
                AnytypeText(value.title, style: .uxBodyRegular, color: .textSecondary)
                Spacer()
                
                if isSelected {
                    if value == .exactDay {
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .frame(height: 24)
                            .accentColor(Color.System.amber)
                        Spacer.fixedWidth(4)
                    }
                    
                    Image.optionChecked.foregroundColor(.textSecondary)
                }
            }
        }
    }
    
}

struct DateRelationRowView_Previews: PreviewProvider {
    static var previews: some View {
        DateRelationDetailsRowView(value: .exactDay, isSelected: true, date: .constant(Date()), onTap: {})
            .background(Color.purple.opacity(0.2))
    }
}
