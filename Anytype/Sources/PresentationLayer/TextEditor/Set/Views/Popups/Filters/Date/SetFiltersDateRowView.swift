import SwiftUI

struct SetFiltersDateRowView: View {
    let configuration: SetFiltersDateRowConfiguration
    @Binding var date: Date
    
    var body: some View {
        Button {
            configuration.onTap()
        } label: {
            HStack(spacing: 0) {
                AnytypeText(
                    configuration.title,
                    style: .uxBodyRegular,
                    color: .textPrimary
                )
                .layoutPriority(1)
                Spacer()
                
                if configuration.isSelected {
                    valueView
                    Image.optionChecked
                        .frame(width: 24, height: 24)
                        .foregroundColor(.buttonSelected)
                }
            }
        }
    }
    
    private var valueView: some View {
        Group {
            switch configuration.dateType {
            case .exactDate:
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .frame(height: 24)
                    .accentColor(Color.System.amber)
                Spacer.fixedWidth(4)
            case let .days(count):
                AnytypeText(count, style: .uxBodyRegular, color: .textPrimary)
                    .lineLimit(1)
                Spacer.fixedWidth(4)
            default:
                EmptyView()
            }
        }
    }
}
