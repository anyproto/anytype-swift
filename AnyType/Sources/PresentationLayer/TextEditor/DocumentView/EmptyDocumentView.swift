//
//  EmptyDocumentView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 03.10.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct EmptyDocumentView: View {
    @State var title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title.isEmpty ? "Untitled" : title)
                .padding(.leading, 15)
            Divider()
            
            VStack {
                HStack(spacing: 17.0) {
                    headerButton(type: .add)
                    headerButton(type: .cover)
                    headerButton(type: .discussion)
                }
                TextField("Untitled", text: $title)
                    .font(.largeTitle)
                    .accentColor(.black)
                    .padding(.top, 20)
                    .padding(.bottom, 5)
                
                bodyButton
            }
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
        }
        .padding(.top, 15)
    }
}

private extension EmptyDocumentView {
    
    enum HeaderButtonType {
        case add
        case cover
        case discussion
        
        var icon: String {
            switch self {
            case .add:
                return "Plus"
            case .cover:
                return "Plus"
            case .discussion:
                return "Plus"
            }
        }
        
        var title: String {
            switch self {
            case .add:
                return "Add Icon"
            case .cover:
                return "Add Cover"
            case .discussion:
                return "Add Discussion"
            }
        }
    }
    
    func headerButton(type: HeaderButtonType) -> some View {
        Button(action: {
            
        }) {
            HStack(spacing: 5.0) {
                Image(type.icon)
                Text(type.title)
            }
        }
        .accentColor(.gray)
    }
    
    var bodyButton: some View {
        VStack {
            Button(action: {
                
            }) {
                Text("Tap here to continue with an empty page, or pick a template")
            }
            .accentColor(.gray)
            .frame(maxHeight: 50)
        }
    }
}

struct EmptyDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyDocumentView(title: "")
    }
}
