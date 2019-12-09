//
//  CustomTextField.swift
//  AnyType
//
//  Created by Denis Batvinkin on 03.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    var title: String
    
    @State var action: String = ""
    
    var body: some View {
        VStack(spacing: 13) {
            TextField(title, text: $action)
            Divider()
        }
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        return CustomTextField(text: .constant(""), title: "Enter your name")
    }
}
