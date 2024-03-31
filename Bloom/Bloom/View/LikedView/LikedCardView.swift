import SwiftUI

struct LikedCardView: View {
    var card: LikedCardModel
    
    // 画面横幅取得→写真の横幅と縦幅に利用
    let imageWidth = (UIScreen.main.bounds.width / 2) - 20
    let imageHeight = (UIScreen.main.bounds.height / 4)
    
    var body: some View {
        ZStack {
            Color.blue
            
            DataImage(dataImage: card.profile.profileImages[0])
                .aspectRatio(contentMode: .fill)
                .frame(width: imageWidth, height: imageHeight)
            
            VStack {
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(card.profile.userName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.black)
                    
                    Text(card.profile.birth.toAge() + card.profile.address)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.black)
                }
                .padding(5)
                .frame(width: imageWidth)
                .background(Color.white)
                .shadow(radius: 20)
            }
        }
        .frame(width: imageWidth, height: imageHeight)
        .cornerRadius(25)
        .padding()
        .shadow(radius: 20)
    }
}

#Preview {
    struct PreviewView: View {
        @State var isLike: Bool? = nil
        @State var offset: CGFloat? = .zero
        var body: some View {
            LikedCardView(
                card: LikedCardModel(
                    id: 1,
                    profile: mockProfileData
                )
            )
        }
    }
    
    return PreviewView()
}
