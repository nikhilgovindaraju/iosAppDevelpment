import Foundation

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    private let baseURL = "https://csci571assignmet-3.wl.r.appspot.com/api"
    
    func fetchAutocomplete(query: String) async throws -> [LocationPrediction] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/autocomplete?input=\(encodedQuery)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let autocompleteResponse = try JSONDecoder().decode(AutocompleteResponse.self, from: data)
        return autocompleteResponse.predictions
    }
    
    func fetchGeocoding(placeId: String) async throws -> (latitude: Double, longitude: Double) {
        guard let encodedPlace = placeId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/geocode?place_id=\(encodedPlace)") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let result = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        return (result.latitude, result.longitude)
    }
    
    // this is for loading the mock data
    func loadMockData() -> [String: Any]? {
        if let path = Bundle.main.path(forResource: "mockdata", ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return json
        }
        return nil
    }
    

    
    // Use this function for actual API
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
        guard let url = URL(string: "\(baseURL)/weather?latitude=\(latitude)&longitude=\(longitude)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return WeatherData(from: json ?? [:])
    }
   
    
    // this is for Mock data call
//    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
//        if let mockData = loadMockData() {
//            return WeatherData(from: mockData)
//        } else {
//            // Fallback to real API call
//            guard let url = URL(string: "\(baseURL)/weather?latitude=\(latitude)&longitude=\(longitude)") else {
//                throw URLError(.badURL)
//            }
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
//            return WeatherData(from: json ?? [:])
//        }
//    }
}
