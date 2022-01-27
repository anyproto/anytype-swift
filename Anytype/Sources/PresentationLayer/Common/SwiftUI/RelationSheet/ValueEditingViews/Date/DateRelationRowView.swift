import SwiftUI

struct DateRelationRowView: View {
    
    let value: DateRelationEditingValue
    let isSelected: Bool
    @Binding var date: Date
    let onTap: () -> ()
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer.fixedHeight(12)
            content
            Spacer.fixedHeight(12)
        }
        .modifier(DividerModifier(spacing: 0))
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
        DateRelationRowView(value: .exactDay, isSelected: true, date: .constant(Date()), onTap: {})
            .background(Color.purple.opacity(0.2))
    }
}
