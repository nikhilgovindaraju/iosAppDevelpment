
import Foundation

struct WeatherData: Codable {
    let temperature: Double
    let weatherCode: Int
    var city: String
    var placeId: String
    let humidity: Double
    let windSpeed: Double
    let visibility: Double
    let pressure: Double
    let cloudCover: Double
    let precipitationProbability: Double
    let uvIndex: Double
    let forecasts: [WeatherForecast]
    var weatherStatus: String{
        return WeatherIconMapper.getWeatherIcon(for: weatherCode)
    }
    
    init(from jsonData: [String: Any]) {
        let timeline = (jsonData["data"] as? [String: Any])?["timelines"] as? [[String: Any]]
        let intervals = timeline?[0]["intervals"] as? [[String: Any]]
        let firstDay = intervals?[0]["values"] as? [String: Any]
        
        self.temperature = firstDay?["temperature"] as? Double ?? 0.0
        self.weatherCode = firstDay?["weatherCode"] as? Int ?? 0
        self.city = "" 
        self.placeId=""
        self.humidity = firstDay?["humidity"] as? Double ?? 0.0
        self.windSpeed = firstDay?["windSpeed"] as? Double ?? 0.0
        self.visibility = firstDay?["visibility"] as? Double ?? 0.0
        self.pressure = firstDay?["pressureSeaLevel"] as? Double ?? 0.0
        self.cloudCover = firstDay?["cloudCover"] as? Double ?? 0.0
        self.precipitationProbability = firstDay?["precipitationProbability"] as? Double ?? 0.0
        self.uvIndex = firstDay?["uvIndex"] as? Double ?? 0.0
        
        var forecastArray: [WeatherForecast] = []
        
 
        if let allDays = intervals {
            for day in allDays {
                if let values = day["values"] as? [String: Any],
                   let startTime = day["startTime"] as? String {
                    let forecast = WeatherForecast(
                        date: startTime.split(separator: "T")[0].description,
                        condition: values["weatherCode"] as? Int ?? 0,
                        sunriseTime: values["sunriseTime"] as? String ?? "N/A",
                        sunsetTime: values["sunsetTime"] as? String ?? "N/A",
                        tempMin: values["temperatureMin"] as? Double ?? 0.0,
                        tempMax: values["temperatureMax"] as? Double ?? 0.0
                    )
                    forecastArray.append(forecast)
                }
            }
        }
        self.forecasts = forecastArray
    }
}

struct WeatherForecast: Identifiable, Codable {
    let id = UUID()
    let date: String
    let condition: Int
    let sunriseTime: String
    let sunsetTime: String
    let tempMin: Double
    let tempMax: Double
    
    init(date: String, condition: Int, sunriseTime: String, sunsetTime: String, tempMin: Double, tempMax: Double) {
        self.date = date
        self.condition = condition
        self.sunriseTime = sunriseTime
        self.sunsetTime = sunsetTime
        self.tempMin = tempMin
        self.tempMax = tempMax
        
    }
}

struct GeocodingResponse: Codable {
    let latitude: Double
    let longitude: Double
}

