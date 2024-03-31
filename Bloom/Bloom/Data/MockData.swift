import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct MockData {
    let prefectures = Prefectures()
    // ランダムな性別を生成する関数
    func randomGender() -> Gender {
        return Bool.random() ? .men : .wemen
    }

    // ランダムな趣味を生成する関数
    func randomHobbies() -> [String] {
        let hobbies = ["マジック", "ゲーム", "読書", "ダンス", "ドライブ", "カフェ巡り", "掃除"]
        let numberOfHobbies = Int.random(in: 1...3) // 1〜3個の趣味をランダムに選択
        var selectedHobbies = Set<String>()
        while selectedHobbies.count < numberOfHobbies {
            if let hobby = hobbies.randomElement() {
                selectedHobbies.insert(hobby)
            }
        }
        return Array(selectedHobbies)
    }

    // ランダムな住所を生成する関数
    func randomAddress() -> String {
        let addresses = prefectures.prefectures
        return addresses.randomElement() ?? "福井県🦀"
    }

    // ランダムな生年月日を生成する関数
    func randomBirth() -> String {
        let year = Int.random(in: 1990...2004)
        let month = Int.random(in: 10...12)
        let day = Int.random(in: 10...28) // とりあえず閏年は考慮しない
        return "\(year)\(month)\(day)"
    }

    // ランダムな場所を生成する関数
    func randomLocation() -> Location {
        let random = Double.random(in: 0...9)
        let latitude = 35.710057714926265 + random
        let longitude = 139.81071829999996 + random
        return Location(longitude: longitude, latitude: latitude)
    }

    // プロジェクト内のアセットから指定の画像を取得してData型に変換する関数
    func imageDataFromAsset() -> Data? {
        guard let image = UIImage(named: "mockImage") else {
            fatalError("Failed to load image")
        }

        guard let imageData = image.jpegData(compressionQuality: 0.01) else {
            fatalError("Failed to convert image to JPEG data")
        }

        return imageData
    }

    // ランダムなホーム写真を生成する関数
    func randomHomeImageData() -> Data {
        // 仮のランダムな画像データを生成することを想定
        return Data()
    }

    // モックデータを生成する関数
    func generateMockData() -> [ProfileAndId] {
        var mockData: [ProfileAndId] = []
        for num in 0..<100 {
            let profile = ProfileElement(userName: "User_\(num))",
                                         introduction: "This is a sample introduction.",
                                         birth: randomBirth(),
                                         gender: randomGender(),
                                         address: randomAddress(),
                                         grade: Int.random(in: 1...100),
                                         hobby: randomHobbies(),
                                         location: randomLocation(),
                                         profession: "学生",
                                         profileImages: [imageDataFromAsset() ?? Data()],
                                         homeImage: imageDataFromAsset() ?? Data(),
                                         point: Int.random(in: 0...100))
            mockData.append(ProfileAndId(profile: profile))
        }
        return mockData
    }

    // MARK: - Firebaseにするメソッド系
    /// コレクションの名称
    private let collectionName = "profiles"
    private var db = Firestore.firestore()
    private let storage = Storage.storage()

    /// Profile追加メソッド
    func addProfile(uid: String, profile: ProfileElement, completion: @escaping (Error?) -> Void) {
        // Firestoreに保存するデータを辞書形式で用意
        let firestoreData: [String: Any] = [
            "userName": profile.userName,
            "introduction": profile.introduction as Any,
            "birth": profile.birth,
            "gender": profile.gender.rawValue,
            "address": profile.address,
            "grade": profile.grade,
            "hobby": profile.hobby,
            "location": profile.location as Any,
            "profession": profile.profession as Any,
            "point": profile.point
        ]

        // 指定したUIDを持つドキュメントにデータを追加（または更新）
        db.collection(collectionName).addDocument(data: firestoreData) { error in
            guard error == nil else {
                completion(error)
                return
            }

            // Firebase Storageにプロファイル画像をアップロード
            let storageRef = self.storage.reference()

            // profileImagesのアップロード
            for (index, imageData) in profile.profileImages.enumerated() {
                let imageRef = storageRef.child("profileImages/\(uid)/image\(index).jpg")
                imageRef.putData(imageData, metadata: nil) { metadata, error in
                    guard error == nil else {
                        completion(error)
                        return
                    }
                }
            }

            // homeImageのアップロード
            let homeImageRef = storageRef.child("homeImages/\(uid)/home.jpg")
            homeImageRef.putData(profile.homeImage, metadata: nil) { metadata, error in
                guard error == nil else {
                    completion(error)
                    return
                }
            }

            // すべてのアップロードが完了したことをコールバック
            completion(nil)
        }
    }

    /// モックデータを全て追加
    func addProfileData() {
        let profiles = generateMockData()

        for profile in profiles {
            addProfile(uid: profile.uuid.uuidString, profile: profile.profile) { error in
                if let error {
                    print("error: \(String(describing: error))")
                } else {
                    print("1人のMockデータ追加完了")
                }
            }
        }
    }
}

struct ProfileAndId {
    let uuid = UUID()
    let profile: ProfileElement
}
