import CoreLocation

/// 現在地取得
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    private var locationManager = CLLocationManager()
    @Published var currentLocation: Location?

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation() // 位置情報を一度だけ取得する
    }

    /// 現在地取得
    func getCurrentLocation(completion: @escaping (Location?) -> Void) {
        completion(currentLocation)
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentLocation = Location(
                longitude: location.coordinate.longitude,
                latitude: location.coordinate.latitude
            )
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error)")
    }
}
