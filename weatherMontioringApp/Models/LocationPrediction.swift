import Foundation

    struct LocationPrediction: Codable, Identifiable, Hashable {
        var id = UUID()
        let description: String
        let place_id: String
        
        enum CodingKeys: String, CodingKey {
            case description
            case place_id
        }
    }

struct AutocompleteResponse: Codable {
    let predictions: [LocationPrediction]
}
