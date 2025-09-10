import SwiftUI

struct HomeWidgetsGroupView: View {
    
    let title: String
    let onCreate: (() -> Void)?
    
    init(title: String, onCreate: (() -> Void)? = nil) {
        self.title = title
        self.onCreate = onCreate
    }
    
    var body: some View {
        HStack {
            Text(title)
                .anytypeStyle(.caption1Medium)
            Spacer()
            if let onCreate {
                Button {
                    onCreate()
                } label: {
                    Image(asset: .X18.plus)
                }
            }
        }
        .padding(EdgeInsets(top: 22, leading: 0, bottom: 12, trailing: 0))
        .foregroundStyle(Color.Control.transparentSecondary)
    }
}
