import SwiftUI
import AnytypeCore
import WrappingHStack

struct InfoSelectionView: View {

    let title: String
    let description: String
    let options: [InfoSelectionOption]
    let selectedOptions: [InfoSelectionOption]
    let onSelect: (InfoSelectionOption) -> Void
    
    var body: some View {
        content
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            AnytypeText(title, style: .contentTitleSemibold)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            
            Spacer.fixedHeight(8)
            
            AnytypeText(description, style: .bodyRegular)
                .foregroundColor(.Text.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Spacer.fixedHeight(16)
            
            optionsView
        }
        .padding(.horizontal, UIDevice.isPad ? 75 : 0)
    }
    
    private var optionsView: some View {
        ScrollView {
            Spacer.fixedHeight(8)
            WrappingHStack(
                alignment: .center,
                horizontalSpacing: Constants.optionSpacing,
                verticalSpacing: Constants.optionSpacing
            ) {
                ForEach(options) { option in
                    optionRow(option, isSelected: selectedOptions.contains(option))
                }
            }
            Spacer.fixedHeight(8)
        }
        .scrollIndicators(.never)
        .bounceBehaviorBasedOnSize()
    }
    
    private func optionRow(_ option: InfoSelectionOption, isSelected: Bool) -> some View {
        HStack(spacing: 6) {
            Image(asset: option.icon)
            AnytypeText(option.title, style: .calloutRegular)
                .foregroundColor(isSelected ? .Text.primary : .Text.secondary)
        }
        .padding(.vertical, 10)
        .padding(.leading, 12)
        .padding(.trailing, 16)
        .background(isSelected ? Color.Control.accent25 : Color.Shape.transperentSecondary)
        .cornerRadius(16, style: .continuous)
        .onTapGesture {
            onSelect(option)
        }
        .if(isSelected) {
            $0.overlay(alignment: .topTrailing) {
                AnytypeCircleCheckbox(checked: .constant(true))
                    .padding([.top, .trailing], -8)
            }
        }
    }
}

extension InfoSelectionView {
    enum Constants {
        static let optionSpacing: CGFloat = 8
    }
}
