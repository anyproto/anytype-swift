import SwiftUI

struct PinCodeView: View {
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                AnytypeText("Choose pin code", style: .title)
                    .padding(.bottom, 17)
                
                HStack {
                    ForEach(1...4, id: \.self) { index in
                        Circle()
                            .overlay(
                                Circle()
                                    .stroke(index != 2 ? .clear : Color("GrayText"), lineWidth: 1)
                        )
                            .foregroundColor(index == 2 ? .clear : .black)
                    }
                }
                .foregroundColor(.black)
                .frame(width: 108, height: 12)
                
                NumberPadView()
                    .padding(.top, 48)
                    .padding(.bottom, 44)
            }
            Spacer()
            Button(action: {
                
            }) {
                AnytypeText("Do it later", style: .body)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.top, 45)
    }
}


struct PinCodeView_Previews: PreviewProvider {
    static var previews: some View {
        PinCodeView()
    }
}


extension HorizontalAlignment {
    private enum ButtonAlignment : AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            return d[HorizontalAlignment.center]
        }
    }
    static let buttonAlignment = HorizontalAlignment(ButtonAlignment.self)
}


struct NumberPadView: View {
    
    var body: some View {
        let row_columns = 3
        
        return VStack(alignment: .buttonAlignment, spacing: 16) {
            ForEach(1...row_columns, id: \.self) { vIndex in
                HStack(spacing: 32) {
                    ForEach(1...row_columns, id: \.self) { hIndex in
                        Button(action: {
                            
                        }) {
                            AnytypeText("\((vIndex - 1) * row_columns + hIndex)", style: .title)
                                .foregroundColor(.textPrimary)
                        }
                        .buttonStyle(NumpadButtonStyle())
                    }
                }
            }
            
            HStack(spacing: 32) {
                Button(action: {
                    
                }) {
                    AnytypeText("0", style: .title)
                        .foregroundColor(.textPrimary)
                }
                .alignmentGuide(.buttonAlignment, computeValue: { d in d[HorizontalAlignment.center]})
                .buttonStyle(NumpadButtonStyle())
                
                Button(action: {
                    
                }) {
                    Image("clear")
                        .frame(width: 72, height: 72)
                        .foregroundColor(.textPrimary)
                }
            }
        }
    }
}


struct NumpadButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        ZStack {
            Circle()
                .overlay(
                    Circle()
                        .stroke(configuration.isPressed ? .clear :  Color("GrayText"))
            )
                .frame(width: 72, height: 72)
                .foregroundColor(configuration.isPressed ? Color("backgroundColor") : .clear)
            configuration.label
        }
    }
}
