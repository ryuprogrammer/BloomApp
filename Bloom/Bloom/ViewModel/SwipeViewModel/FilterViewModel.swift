import Foundation

class FilterViewModel: ObservableObject {
    let prefectures = Prefectures().prefectures
    let userDefaultsDataModel = UserDefaultsDataModel()
    let loadFileDataModel = LoadFileDataModel()
    /// UserDefaultsのフィルターデータ
    @Published var filter: FilterElement = FilterElement(address: [], hobbys: [], professions: [])

    // MARK: - UserDefaults
    /// フィルターデータの追加・更新
    func addFilter(filter: FilterElement) {
        userDefaultsDataModel.addFilter(filter: filter)
    }

    /// フィルターの取得
    func fetchFilter() {
        if let filter = userDefaultsDataModel.fetchFilter() {
            self.filter = filter
        }
    }

    /// フィルターデータの削除
    func deleteFilter() {
        userDefaultsDataModel.deleteFilter()
    }

    /// hobbyを取得
    func fetchHobbyData() -> [String] {
        guard let hobbys = loadFileDataModel.loadCsvFile(fileName: "HobbyList") else {
            return []
        }

        return hobbys
    }

    /// professionを取得
    func fetchProfessionData() -> [String] {
        guard let professions = loadFileDataModel.loadCsvFile(fileName: "ProfessionList") else {
            return []
        }

        return professions
    }
}
