import SwiftUI
import PhotosUI
import SwiftData

struct MyPageView: View {
    // MARK: - インスタンス
    @ObservedObject var myPageVM = MyPageViewModel()
    let authenticationManager = AuthenticationManager()
    let userDefaultsDataModel = UserDefaultsDataModel()
    @ObservedObject var locationManager = LocationManager.shared

    // MARK: - UI用サイズ指定
    let iconSize = UIScreen.main.bounds.width / 14
    /// 画面横幅取得→写真の横幅と縦幅に利用
    let homeImageSize = UIScreen.main.bounds.width / 4
    let imageWidth = UIScreen.main.bounds.width / 3 - 20
    let imageHeight = UIScreen.main.bounds.height / 5

    // MARK: - 画面遷移
    @State private var navigationPath: [MyPagePath] = []
    @State private var isShowHobbyView: Bool = false
    @State private var isShowAddressView: Bool = false
    @State private var isShowBirthView: Bool = false
    @State private var isShowIntroductionView: Bool = false
    @State private var isShowProfessionView: Bool = false
    @State private var isShowProfileImageView: Bool = false

    // MARK: - その他
    @State var showingProfile: ProfileElement = mockProfileData
    // ニックネームの入力値
    @State var editName: String = ""
    // Home写真に関するプロパティ
    @State var selectedItem: PhotosPickerItem?
    // LazyVGridのcolumns
    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                // ホーム写真と基本情報
                VStack(spacing: 10) {
                    // ホーム写真
                    homeImageView()
                    HStack {
                        VipTicketView()
                        Text(showingProfile.userName)
                            .font(.title)
                    }

                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "p.circle.fill")
                                .foregroundStyle(Color.yellow)
                            Text(showingProfile.toString(profileType: .point) ?? "0ポイント")
                        }

                        HStack {
                            Image(systemName: "location.circle.fill")
                            Text(myPageVM.locationString ?? "取得中...")
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)

                // プロフィール情報セクション
                Section {
                    profileInformation()
                } header: {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("プロフィール情報")
                    }
                }

                // 自己紹介文セクション
                Section {
                    introduction()
                } header: {
                    HStack {
                        Image(systemName: "pencil.line")
                        Text("自己紹介文")
                    }
                }

                // プロフィール写真セクション
                Section {
                    profileImages()
                } header: {
                    HStack {
                        Image(systemName: "person.crop.square")
                        Text("プロフィール写真")
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("マイページ", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        authenticationManager.deleteUser()
                        userDefaultsDataModel.deleteMyProfile()
                    } label: {
                        Text("アカウント削除")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        navigationPath.append(.pathSetting)
                    } label: {
                        Image(systemName: "gearshape")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: iconSize)
                            .foregroundStyle(Color.white)
                    }
                }
            }
            // 画面遷移を制御
            .navigationDestination(for: MyPagePath.self, destination: navigationDestination)
        }.onAppear { // profile取得
            myPageVM.fetchMyProfile()
        }
        .onChange(of: locationManager.currentLocation) {
            print("チェンジーーーーーー")
            showingProfile.location = locationManager.currentLocation
        }
        .accentColor(Color.white)
        .onChange(of: myPageVM.myProfile) { // UserDefaultsのprofileを描画
            if let profile = myPageVM.myProfile {
                self.showingProfile = profile
                self.editName = profile.userName
                // Locationから住所取得
                Task {
                    await myPageVM.fetchAddress(location: showingProfile.location)
                }
            }
        }
        .onChange(of: showingProfile) { // profileの更新
            guard let dataBaseProfile = myPageVM.myProfile else { return }
            if showingProfile != dataBaseProfile {
                Task {
                    // profileImagesを更新する場合は、一旦firebaseの写真を削除する
                    // firebaseの写真は更新できないため。
                    if showingProfile.profileImages != dataBaseProfile.profileImages {
                        let deleteImageCount = dataBaseProfile.profileImages.count
                        await myPageVM.deleteProfileImages(deleteImageCount: deleteImageCount)
                    }
                    myPageVM.upDateMyProfile(profile: showingProfile)
                }
            }
        }
    }

    // MARK: - セクション毎のViewBuilder達
    // ホーム写真
    @ViewBuilder
    func homeImageView() -> some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.2))
                .strokeBorder(Color.black.opacity(0.8), lineWidth: 5)
                .frame(width: homeImageSize, height: homeImageSize)

            DataImage(dataImage: showingProfile.homeImage)
                .aspectRatio(contentMode: .fill)
                .frame(width: homeImageSize, height: homeImageSize)
                .clipShape(Circle())

            PhotosPicker(selection: $selectedItem) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: homeImageSize/3, height: homeImageSize/3)
                    .foregroundStyle(Color.pink.opacity(0.8))
                    .background(Color.white)
                    .clipShape(Circle())
            }
            // List全体にあるタップ可能領域を解除
            .buttonStyle(BorderlessButtonStyle())
            .offset(x: homeImageSize/3, y: homeImageSize/3)
            .onChange(of: selectedItem) {
                Task {
                    guard let data = try? await selectedItem?.loadTransferable(type: Data.self) else { return }
                    guard let uiImage = UIImage(data: data) else { return }

                    if let imageData = uiImage.jpegData(compressionQuality: 0.1) {
                        showingProfile.homeImage = imageData
                    }
                }
            }
        }
    }

    // プロフィール
    @ViewBuilder
    func profileInformation() -> some View {
        HStack {
            ListRowView(
                viewType: .MyPageView,
                image: "person.text.rectangle",
                title: "ニックネーム",
                detail: ""
            )

            Spacer()

            TextField("ニックネームを入力", text: $editName)
                .foregroundStyle(Color.pink)
            // TextFieldを右寄せにする
                .multilineTextAlignment(TextAlignment.trailing)
                .onSubmit {
                    showingProfile.userName = editName
                }
        }

        ListRowView(
            viewType: .MyPageView,
            image: "mappin.and.ellipse",
            title: "居住地",
            detail: showingProfile.toString(profileType: .address)
        )
        .onTapGesture {
            isShowAddressView = true
        }
        .sheet(isPresented: $isShowAddressView) {
            AddressEditView(address: $showingProfile.address)
        }

        ListRowView(
            viewType: .MyPageView,
            image: "birthday.cake",
            title: "生年月日",
            detail: showingProfile.toString(profileType: .birth)
        )
        .onTapGesture {
            isShowBirthView = true
        }
        .sheet(isPresented: $isShowBirthView) {
            BirthEditView(birth: $showingProfile.birth)
        }

        ListRowView(
            viewType: .MyPageView,
            image: "gamecontroller",
            title: "趣味",
            detail: showingProfile.toString(profileType: .hobby)
        )
        .onTapGesture {
            isShowHobbyView = true
        }
        .sheet(isPresented: $isShowHobbyView) {
            HobbyEditView(hobbys: $showingProfile.hobby)
        }

        ListRowView(
            viewType: .MyPageView,
            image: "wallet.pass",
            title: "職業",
            detail: showingProfile.toString(profileType: .profession)
        )
        .onTapGesture {
            isShowProfessionView = true
        }
        .sheet(isPresented: $isShowProfessionView) {
            ProfessionEditView(profession: $showingProfile.profession)
        }
    }

    // 自己紹介文
    @ViewBuilder
    func introduction() -> some View {
        if let introduction = showingProfile.introduction {
            Text(introduction)
                .fixedSize(horizontal: false, vertical: true)
                .onTapGesture {
                    isShowIntroductionView = true
                }
                .sheet(isPresented: $isShowIntroductionView) {
                    IntroductionEditView(introduction: $showingProfile.introduction)
                }
        } else {
            HStack {
                Text("自己紹介文を入力しよう！")

                Spacer()

                PointIconView(point: 10)
            }
            .onTapGesture {
                isShowIntroductionView = true
            }
            .sheet(isPresented: $isShowIntroductionView) {
                IntroductionEditView(introduction: $showingProfile.introduction)
            }
        }
    }

    // プロフィール写真
    @ViewBuilder
    func profileImages() -> some View {
        LazyVGrid(columns: columns) {
            ForEach(showingProfile.profileImages, id: \.self) { image in
                DataImage(dataImage: image)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: imageWidth, height: imageHeight)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            isShowProfileImageView = true
        }
        .sheet(isPresented: $isShowProfileImageView) {
            ProfileImageEditView(profileImages: $showingProfile.profileImages)
        }
    }

    // MARK: - 画面遷移メソッド
    @ViewBuilder
    func navigationDestination(for path: MyPagePath) -> some View {
        switch path {
        case .pathSetting:
            SettingView(path: $navigationPath).toolbar(.hidden, for: .tabBar)
        case .pathPrivacy:
            PrivacyView().toolbar(.hidden, for: .tabBar)
        case .pathService:
            ServiceView().toolbar(.hidden, for: .tabBar)
        case .pathForm:
            FormView().toolbar(.hidden, for: .tabBar)
        case .pathDeleteAccount:
            DeleteAccountView().toolbar(.hidden, for: .tabBar)
        case .pathPranWeb:
            PranWebView().toolbar(.hidden, for: .tabBar)
        }
    }
}

enum MyPagePath {
    case pathSetting
    case pathPrivacy
    case pathService
    case pathForm
    case pathDeleteAccount
    case pathPranWeb
}

#Preview {
    MyPageView()
}

