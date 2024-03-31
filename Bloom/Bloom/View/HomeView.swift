import SwiftUI

struct HomeView: View {
    /// タブの選択項目を保持する
    @State var selection: ViewSection = .swipeView
    @ObservedObject var locationManager = LocationManager()
    let userDataModel = UserDataModel()
    let userDefaultsDataModel = UserDefaultsDataModel()
//    let mockData = MockData()

    enum ViewSection: Int {
        case swipeView = 1
        case likedView = 2
        case friendListView = 3
        case myPageView = 4
    }
    
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .white
        
        // タブ選択時のテキスト設定
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(.pink.opacity(0.8)), .font: UIFont.systemFont(ofSize: 10, weight: .bold)]
        // タブ選択時のアイコン設定
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(.pink.opacity(0.8))
        
        // タブ非選択時のテキスト設定
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(.black.opacity(0.7)), .font: UIFont.systemFont(ofSize: 10, weight: .medium)]
        // タブ非選択時のアイコン設定
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(.black.opacity(0.7))
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
          UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        UITabBar.appearance().barTintColor = .green
    }
    
    var body: some View {
        TabView(selection: $selection) {
            SwipeView()
                .tabItem {
                    VStack {
                        Image(systemName: "person.crop.rectangle.stack")
                            .environment(\.symbolVariants, selection == .swipeView ? .fill : .none)
                        Text("スワイプ")
                    }
                }
                .tag(ViewSection.swipeView)
            
            LikedView()
                .tabItem {
                    VStack {
                        Image(systemName: "heart")
                            .environment(\.symbolVariants, selection == .likedView ? .fill : .none)
                        Text("いいね")
                    }
                }
                .tag(ViewSection.likedView)
            
            FriendListView()
                .tabItem {
                    VStack {
                        Image(systemName: "ellipsis.message")
                            .environment(\.symbolVariants, selection == .friendListView ? .fill : .none)
                        Text("トーク")
                    }
                }
                .tag(ViewSection.friendListView)
            
            MyPageView()
                .tabItem {
                    VStack {
                        Image(systemName: "person")
                            .environment(\.symbolVariants, selection == .myPageView ? .fill : .none)
                        Text("マイページ")
                    }
                }
                .tag(ViewSection.myPageView)
        }
        .onAppear {
            locationManager.getCurrentLocation { location in
                if let myProfile = userDefaultsDataModel.fetchMyProfile() {
                    let profile = myProfile.toProfileElement()

                    let setProfile = ProfileElement(
                        userName: profile.userName,
                        introduction: profile.introduction,
                        birth: profile.birth,
                        gender: profile.gender,
                        address: profile.address,
                        grade: profile.grade,
                        hobby: profile.hobby,
                        location: location,
                        profession: profile.profession,
                        profileImages: profile.profileImages,
                        homeImage: profile.homeImage,
                        point: profile.point
                    )

                    userDataModel.addProfile(profile: setProfile) { error in
                        if let error {
                            print("データの更新失敗: \(error)")
                        } else {
                            print("位置情報の更新に成功")
                        }
                    }
                }
            }

            print("モックデータ追加開始")
//            mockData.addProfileData()
        }
    }
}

#Preview {
    HomeView()
}
