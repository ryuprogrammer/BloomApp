import SwiftUI
import CoreLocation

extension Location {
    /// 位置情報から住所を抽出
    func toAddress() async -> String? {
        let geocoder = CLGeocoder()
        var formattedAddress: String?

        // Convert Location struct to CLLocationCoordinate2D
        let coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)

        // Reverse geocode the location to get address information
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                // Format the address using city and locality information
                var addressComponents = [String]()

                if let city = placemark.locality {
                    addressComponents.append(city)
                }
                if let locality = placemark.subLocality {
                    addressComponents.append(locality)
                }

                formattedAddress = addressComponents.joined(separator: "")
                return formattedAddress
            } else {
                print("No placemarks found.")
                return nil
            }
        } catch {
            print("Reverse geocode failed with error: \(error.localizedDescription)")
            return nil
        }
    }

    /// 他の位置との距離をキロメートルで返す
    func distance(to destination: Location?) -> Double? {
        guard let destination else { return nil }
        let coordinate₀ = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let coordinate₁ = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        let meters = coordinate₀.distance(from: coordinate₁)
        let kilometers = meters / 1000.0 // メートルからキロメートルに変換
        return kilometers
    }
}
