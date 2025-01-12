

import SwiftUI

struct TodayGridView: View {
    let weatherData: WeatherData
    let isCurrentLocation: Bool
    
    var body: some View {
        ScrollView {
            ZStack {
                Image("App_background")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    WeatherDataCard(icon: "WindSpeed", value: String(format: "%.2f mph", weatherData.windSpeed), title: "Wind Speed")
                    WeatherDataCard(icon: "Pressure", value: String(format: "%.2f inHG", weatherData.pressure), title: "Pressure")
                    WeatherDataCard(icon: "Precipitation", value: "\(Int(weatherData.precipitationProbability))%", title: "Precipitation")
                    WeatherDataCard(icon: "Temperature", value: "\(Int(weatherData.temperature))°F", title: "Temperature")
                    WeatherDataCard(icon: weatherData.weatherStatus, value: weatherData.weatherStatus, title: "")
                    WeatherDataCard(icon: "Humidity", value: "\(Int(weatherData.humidity))%", title: "Humidity")
                    WeatherDataCard(icon: "Visibility", value: String(format: "%.2f mi", weatherData.visibility), title: "Visibility")
                    WeatherDataCard(icon: "CloudCover", value: "\(Int(weatherData.cloudCover))%", title: "Cloud Cover")
                    WeatherDataCard(icon: "UVIndex", value: "\(Int(weatherData.uvIndex))%", title: "UV Index")
                }
                .padding()
            }
            .padding(.top, 20)
        }
    }
}

struct WeatherDataCard: View {
    let icon: String
    let value: String
    let title: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 55, height: 55)
            Text(value)
                .font(.system(size: 16, weight: .medium))
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.black.opacity(0.5))
        }
        .padding(.vertical, 50)
        .frame(width: 120, height: 160)
        .background(Color.white.opacity(0.5))
        .cornerRadius(10)
    }
}
