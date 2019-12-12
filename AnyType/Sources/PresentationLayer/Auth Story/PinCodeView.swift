//
//  PinCodeView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 02.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct PinCodeView: View {
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                Text("Choose pin code")
                    .font(.title)
                    .fontWeight(.bold)
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
                Text("Do it later")
                .font(.body)
                .foregroundColor(Color("GrayText"))
                .fontWeight(.bold)
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
                            Text("\((vIndex - 1) * row_columns + hIndex)")
                            .font(.title)
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                        }
                        .buttonStyle(NumpadButtonStyle())
                    }
                }
            }
            
            HStack(spacing: 32) {
                Button(action: {
                    
                }) {
                    Text("0")
                        .font(.title)
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                }
                .alignmentGuide(.buttonAlignment, computeValue: { d in d[HorizontalAlignment.center]})
                .buttonStyle(NumpadButtonStyle())
                
                Button(action: {
                    
                }) {
                    Image("clear")
                        .frame(width: 72, height: 72)
                        .foregroundColor(.black)
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
