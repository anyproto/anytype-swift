import SwiftUI

struct HomeProfileView: View {
    @EnvironmentObject var accountData: AccountInfoDataAccessor
    
    let icons = ["searchTextFieldIcon", "Settings/wallpaper", "plus"]
    
    var body: some View {
        VStack() {
            Text("Hi, \(accountData.visibleAccountName)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 100.0)
            UserIconView(color: .red, name: "W")
                .frame(width: 98, height: 98)
            HStack {
                ForEach(icons, id: \.self) { name in
                    UserIconView(image: UIImage(named: name), name: name)
                        .frame(width: 60, height: 60)
                        .overlay(Circle().stroke(lineWidth: 2))
                }
            }
            .padding(.top, 40)
            Spacer()
        }
    }
}

struct HomeProfileView_Previews: PreviewProvider {
    static var previews: some View {
        HomeProfileView()
    }
}
