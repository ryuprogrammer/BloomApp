import SwiftUI

struct MessageRowView: View {
    // MARK: - イニシャライズ
    let message: MessageElement
    let isMyMessage: Bool
    let friendProfile: ProfileElement?
    
    // MARK: - UI用サイズ指定
    let iconSize = UIScreen.main.bounds.width / 10
    
    var body: some View {
        if isMyMessage { // 自分
            HStack {
                Spacer()
                
                VStack {
                    Spacer()
                    
                    Text(message.createAt.timeString())
                        .foregroundStyle(Color.gray)
                        .font(.caption)
                }
                
                Text(message.message)
                    .padding(10)
                    .background(Color.cyan)
                    .cornerRadius(20)
                    .foregroundColor(Color.white)
            }
        } else { // 相手
            if let friendProfile = friendProfile {
                HStack {
                    DataImage(dataImage: friendProfile.homeImage)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: iconSize, height: iconSize)
                        .clipShape(Circle())
                    
                    Text(message.message)
                        .padding(10)
                        .background(Color.pink.opacity(0.7))
                        .cornerRadius(20)
                        .foregroundColor(Color.white)
                    
                    VStack {
                        Spacer()
                        
                        Text(message.createAt.timeString())
                            .foregroundStyle(Color.gray)
                            .font(.caption)
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    VStack {
        MessageRowView(
            message: MessageElement(
                uid: "sss",
                roomID: "roomID",
                isNewMessage: true, name: "userName",
                message: "メッセージ",
                createAt: Date()
            ),
            isMyMessage: false,
            friendProfile: mockProfileData
        )
        
        MessageRowView(
            message: MessageElement(
                uid: "sss",
                roomID: "roomID",
                isNewMessage: true, name: "userName",
                message: "メッセージ",
                createAt: Date()
            ),
            isMyMessage: true,
            friendProfile: nil
        )
    }
}
