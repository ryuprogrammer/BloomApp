import SwiftUI

struct SwipeCardInfomationView: View {
    let profile: ProfileElement
    let myProfile: ProfileElement?
    // 画面横幅取得→写真の横幅と縦幅に利用
    let iconSize = UIScreen.main.bounds.width / 8
    let imageWidth = UIScreen.main.bounds.width - 35
    let imageHeight = (UIScreen.main.bounds.height * 5) / 8

    let cardWidth = UIScreen.main.bounds.width - 55
    let cardHeight = UIScreen.main.bounds.width / 3

    var body: some View {
        ZStack {
//            RoundedRectangle(cornerRadius: 25)
//                .foregroundStyle(Color.blue)
//                .frame(width: imageWidth, height: imageHeight)

            VStack {
                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: cardWidth, height: cardHeight)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke()
                                .foregroundStyle(
                                    .linearGradient(colors: [.white.opacity(0.5), .clear],
                                                    startPoint: .top,
                                                    endPoint: .bottom)
                                )
                        )
                        .padding(10)
                        .shadow(color: .black.opacity(0.3), radius: 20, y: 20)

                    VStack(alignment: .leading, spacing: 8) {
                        // 名前、距離
                        HStack(alignment: .bottom) {
                            Text(profile.userName)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.white)
                                .padding([.leading, .top])

                            if let myProfile,
                               let location = myProfile.location,
                               let distance = location.distance(to: myProfile.location) {
                                Text(String(distance) + "km")
                            }

                            Spacer()
                        }

                        // 年齢、出身地、職業
                        Text(profile.jointProfile())
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.white)
                            .padding(.leading)

                        // 趣味
                        HStack {
                            ForEach(profile.hobby, id: \.self) { hobby in
                                if let myProfile {
                                    if myProfile.hobby.contains(hobby) {
                                        Text(hobby)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color.white)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 8)
                                            .background {
                                                ZStack {
                                                    Capsule()
                                                        .foregroundStyle(Color.main)
                                                    Capsule()
                                                        .stroke(Color.white, lineWidth: 3)
                                                }
                                            }
                                            .padding(.horizontal, 2)
                                    } else {
                                        Text(hobby)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color.white)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 8)
                                            .background {
                                                Capsule().stroke(Color.white, lineWidth: 3)
                                            }
                                            .padding(.horizontal, 2)
                                    }
                                } else {
                                    Text(hobby)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.white)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)
                                        .background {
                                            Capsule().stroke(Color.white, lineWidth: 3)
                                        }
                                        .padding(.horizontal, 2)
                                }
                            }
                        }
                        .padding([.leading, .bottom])
                    }
                    .frame(width: cardWidth, height: cardHeight)
                }
            }
            .frame(width: imageWidth, height: imageHeight)
        }
    }
}

#Preview {
    SwipeCardInfomationView(profile: mockProfileData, myProfile: mockProfileDataMe)
}
