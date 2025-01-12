
import SwiftUI

struct WeatherTabView: View {
    let weatherData: WeatherData
    let isCurrentLocation: Bool
    let onBackTapped: () -> Void
    @State private var selectedTab = 0
    
    init(weatherData: WeatherData, isCurrentLocation: Bool, onBackTapped: @escaping () -> Void) {
        self.weatherData = weatherData
        self.isCurrentLocation = isCurrentLocation
        self.onBackTapped = onBackTapped
 
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                cityName: isCurrentLocation ? "Los Angeles" : weatherData.city,
                temperature: weatherData.temperature,
                weatherStatus: weatherData.weatherStatus,
                onBackTapped: onBackTapped,
                onCloseTapped: onBackTapped,
                isCurrentLocation: isCurrentLocation
            )
            
            TabView(selection: $selectedTab) {
                TodayGridView(weatherData: weatherData, isCurrentLocation: isCurrentLocation)
                    .tabItem {
                        Image("Today_Tab")
                        Text("TODAY")
                    }
                    .tag(0)
                
                WeeklyView(weatherData: weatherData)
                    .tabItem {
                        Image("Weekly_Tab")
                        Text("WEEKLY")
                    }
                    .tag(1)
                
                WeatherDataView(weatherData: weatherData)
                    .tabItem {
                        Image("Weather_Data_Tab")
                        Text("WEATHER DATA")
                    }
                    .tag(2)
            }
        }
    }
}

