import SwiftUI
import SwiftData

struct RegistrationView: View {
    let explanation = ExplanationText()
    fileprivate var registrationVM = RegistrationViewModel()
    /// 画面遷移
    @State var isShowHomeView: Bool = false
    /// 入力完了を監視
    @State var isDoneType: Bool = false
    ///  ユーザーネーム
    @State var userName = ""
    // 名前の入力の完了を監視
    @State var isDoneName: Bool = false
    // プロフィール入力の進行度
    @State var registrationState: RegistrationState = .name
    // ニックネーム
    @State var name: String = ""
    // 誕生日
    @State var birth: String = ""
    // 性別
    @State var gender: Gender = .men
    // 居住地
    @State var address: String = ""
    // プロフィール写真
    @State var profileImages: [Data] = []
    // ホーム写真
    @State var homeImage: Data = Data()
    
    var body: some View {
        if registrationState == .name {
            NameEntryView(
                name: $name,
                registrationState: $registrationState
            )
        } else if registrationState == .birth {
            BirthEntryView(
                birth: $birth,
                registrationState: $registrationState
            )
        } else if registrationState == .gender {
            GenderEntryView(
                selectedGender: $gender,
                registrationState: $registrationState
            )
        } else if registrationState == .address {
            AddressEntryView(
                address: $address,
                registrationState: $registrationState
            )
        } else if registrationState == .profileImage {
            ProfileImageEntryView(
                profileImages: $profileImages,
                registrationState: $registrationState
            )
        } else if registrationState == .homeImage {
            HomeImageEntryView(
                homeImage: $homeImage,
                registrationState: $registrationState
            )
        } else if registrationState == .doneAll {
            ZStack {
                Color.pink.opacity(0.8)
                    .ignoresSafeArea(.all)
                VStack {
                    Spacer()
                    
                    Image("logoWhite")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    
                    Text("Bloomをはじめよう")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            registrationVM.addProfile(
                                profile: ProfileElement(
                                    userName: name,
                                    introduction: nil,
                                    birth: birth,
                                    gender: gender,
                                    address: address,
                                    grade: 0,
                                    hobby: [],
                                    location: nil,
                                    profession: "獣医師",
                                    profileImages: profileImages,
                                    homeImage: homeImage,
                                    point: 0
                                )
                            )
                            
                            registrationState = .toHome
                        }
                    }, label: {
                        Text("アプリをはじめる")
                            .font(.title2)
                            .foregroundStyle(Color.pink.opacity(0.8))
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .padding()
                    })
                }
            }
        } else if registrationState == .toHome {
            HomeView()
        }
    }
}

enum RegistrationState: Int {
    case noting = 0
    case name = 1
    case birth = 2
    case gender = 3
    case address = 4
    case profileImage = 5
    case homeImage = 6
    case doneAll = 7
    case toHome = 8
}

#Preview {
    RegistrationView()
}
