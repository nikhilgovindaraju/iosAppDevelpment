import Alamofire
import Highcharts
import SwiftyJSON
import Toast
import SwiftSpinner
import SwiftUI
import CoreLocation
import UIKit


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    private let manager = CLLocationManager()
    @Published var weatherData: WeatherData?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        SwiftSpinner.show("Fetching Weather Details for Los Angeles")
        Task {
            do {
                let weather = try await NetworkManager.shared.fetchWeather(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                await MainActor.run {
                    self.weatherData = weather
                    SwiftSpinner.hide()
                }
            } catch {
                await MainActor.run {
                    SwiftSpinner.hide()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }
}

struct WeatherDetailView: View {
    let weatherData: WeatherData
    let isCurrentLocation: Bool
    @State var showDetailView: Bool = false
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            if !isCurrentLocation {
                HStack {
                    Spacer()
                    Button(action: toggleFavorite) {
                        Image( favoritesManager.isFavorite(weatherData.city) ? "close-circle" : "plus-circle")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal)
            }
            WeatherSummaryCard(
                temperature: weatherData.temperature,
                condition: weatherData.weatherCode,
                location: weatherData.city,
                isCurrentLocation: isCurrentLocation
            )
            .background(Color.white.opacity(0.3))
            .cornerRadius(15)
            .shadow(radius: 5)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    DispatchQueue.main.async {
                        showDetailView = true
                    }
                }
            }
            
            WeatherMetricsView(
                humidity: weatherData.humidity,
                windSpeed: weatherData.windSpeed,
                visibility: weatherData.visibility,
                pressure: weatherData.pressure
            )
            .padding()
            .cornerRadius(15)
            
            ForecastTableView(forecasts: weatherData.forecasts)
                .padding()
                .background(Color.white.opacity(0.6))
                .cornerRadius(15)
                .shadow(radius: 5)
        }
        
        .fullScreenCover(isPresented: $showDetailView) {
            WeatherTabView(
                weatherData: weatherData,
                isCurrentLocation: isCurrentLocation,
                onBackTapped: {
                 
                        showDetailView = false
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                        
                    }
                }
            )
            .tabViewStyle(.automatic)
            .interactiveDismissDisabled()
            
        }

        .overlay(
            Group {
                if showToast {
                    VStack {
                        Spacer()
                        ToastView(message: toastMessage)
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: showToast)
                }
            }
        )
        .interactiveDismissDisabled(true)
    }
    private func toggleFavorite() {
        let city = weatherData.city
        if favoritesManager.isFavorite(city) {
            favoritesManager.removeFavorite(city)
            toastMessage = "\(city) was removed from the Favorite List"
        } else {
            favoritesManager.addFavorite(city)
            toastMessage = "\(city) was added to the Favorite List"
        }
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }
}

struct WeatherSummaryCard: View {
    let temperature: Double
    let condition: Int
    let location: String
    let isCurrentLocation: Bool
    
    var displayLocation: String {
        isCurrentLocation ? "Los Angeles" : location
    }
    
    var weatherStatus: String {
           switch condition {
               case 1000: return "Clear"
               case 1100: return "Mostly Clear"
               case 1101: return "Partly Cloudy"
               case 1102: return "Mostly Cloudy"
               case 1001: return "Cloudy"
               case 2000: return "Fog"
               case 2100: return "Light Fog"
               case 4000: return "Drizzle"
               case 4001: return "Rain"
               case 4200: return "Light Rain"
               case 4201: return "Heavy Rain"
               case 5000: return "Snow"
               case 5001: return "Flurries"
               case 5100: return "Light Snow"
               case 5101: return "Heavy Snow"
               case 6000: return "Freezing Drizzle"
               case 6001: return "Freezing Rain"
               case 6200: return "Light Freezing Rain"
               case 6201: return "Heavy Freezing Rain"
               case 7000: return "Ice Pellets"
               case 7101: return "Heavy Ice Pellets"
               case 7102: return "Light Ice Pellets"
               case 8000: return "Thunderstorm"
               default: return "Unknown"
           }
       }
    
    var body: some View {
        HStack(spacing:-40){
            Image(WeatherIconMapper.getWeatherIcon(for: condition))
            
            VStack(alignment: .leading, spacing: 6) {
                
                
                Text("\(Int(temperature))°F")
                    .font(.system(size: 50, weight: .medium))
                
                Text(weatherStatus)
                    .font(.title2)
                
                Text(displayLocation)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            

            .frame(maxWidth: .infinity)
            .cornerRadius(15)
        }
        .padding()
    }
}

struct WeatherMetricsView: View {
    let humidity: Double
    let windSpeed: Double
    let visibility: Double
    let pressure: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 20) {
                Text("Humidity")
                Text("Wind Speed")
                Text("Visibility")
                Text("Pressure")
            }
            .font(.system(size: 16))
            
            HStack(spacing: 30) {
                MetricItem(icon: "Humidity", value: String(format: "%.1f%%", humidity))
                MetricItem(icon: "WindSpeed", value: String(format: "%.2f mph", windSpeed))
                MetricItem(icon: "Visibility", value: String(format: "%.2f mi", visibility))
                MetricItem(icon: "Pressure", value: String(format: "%.2f inHg", pressure))
            }
        }
        .frame(width: .infinity, height: (100))
        
    }
        
}



struct ForecastTableView: View {
    let forecasts: [WeatherForecast]
    
    func formatTime(_ timeString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = inputFormatter.date(from: timeString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "HH:mm"
            return outputFormatter.string(from: date)
        }
        return "N/A"
    }
    
    func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MM/dd/yyyy"
            return outputFormatter.string(from: date)
        }
        return dateString
    }
        
    
    var body: some View {
        ScrollView{
        VStack {
            ForEach(forecasts) { forecast in
                HStack {
                    Text(formatDate(forecast.date))
                    Image(WeatherIconMapper.getWeatherIcon(for: forecast.condition))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Spacer()
                    
                    Text(formatTime(forecast.sunriseTime))
                    Image(systemName: "sunrise.fill")
                        .foregroundColor(.orange)
                    Text(formatTime(forecast.sunsetTime))
                    Image(systemName: "sunset.fill")
                        .foregroundColor(.black)
                }
                .padding(.vertical, 8)
                Divider()
            }
        }
    }
    }
}


struct CustomNavigationBar: View {
    let cityName: String
    let temperature: Double
    let weatherStatus: String
    let onBackTapped: () -> Void
    let onCloseTapped: () -> Void
    let isCurrentLocation: Bool
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var showToast = false
    @State private var toastMessage = ""

    
    private func getShareURL() -> URL? {
        let message = "The current temperature at \(cityName) is \(Int(temperature)) °F. The weather conditions are \(weatherStatus) #CSCI571WeatherSearch"
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://twitter.com/intent/tweet?text=\(encodedMessage)"
        return URL(string: urlString)
    }
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: onBackTapped) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("Weather")
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button(action: {
                    if let url = getShareURL() {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Image("twitter")
                        .foregroundColor(.blue)
                }
            }
            
            Text(cityName)
                .font(.system(size: 17, weight: .medium))
                .frame(maxWidth: .infinity)
            
            if showToast {
                VStack{
                    Spacer()
                    ToastView(message: toastMessage)
                }
                .transition(.opacity)
                .animation(.easeInOut, value: showToast)
            }
        }
        .padding(.horizontal)
        .padding(.vertical)
        .background(Color.white)
    }
    private func toggleFavorite() {
            if favoritesManager.isFavorite(cityName) {
                favoritesManager.removeFavorite(cityName)
                toastMessage = "\(cityName) was removed from the Favorite List"
            } else {
                favoritesManager.addFavorite(cityName)
                toastMessage = "\(cityName) was added to the Favorite List"
            }
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showToast = false
            }
        }
}

struct ContentView: View {
    @State private var searchText = ""
    @State private var showAutocomplete = false
    @State private var predictions: [LocationPrediction] = []
    @State private var selectedLocation: LocationPrediction?
    @State private var weatherData: WeatherData?
    @StateObject private var locationManager = LocationManager()
    @StateObject private var favoritesManager = FavoritesManager()
    @Environment(\.presentationMode) var presentationMode
    @State private var showNavigationBar = false
    
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Image("App_background")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if !showNavigationBar {

                    SearchBarView(
                        searchText: $searchText,
                        predictions: $predictions,
                        showAutocomplete: $showAutocomplete
                    )
                    .background(Color.white)
                    
            
                    ZStack(alignment: .top) {
            
                        TabView(selection: $currentPage) {
                            if let weather = locationManager.weatherData {
                                WeatherDetailView(weatherData: weather, isCurrentLocation: true)
                                    .tag(0)
                            }
                            ForEach(favoritesManager.favorites, id: \.self) { cityName in
                                FavoriteCityView(cityName: cityName)
                                    .tag(favoritesManager.favorites.firstIndex(of: cityName)! + 1)
                            }
                        }
                        .tabViewStyle(.page)
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                        .tabViewStyle(.page)
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                        .padding()
                        
                   
                        if showAutocomplete && !predictions.isEmpty {
                            VStack {

                                AutocompleteListView(predictions: predictions) { prediction in
                                    handleLocationSelection(prediction)
                                }
                                .offset(y: 32)
                                Spacer()
                            }
                        }
                    }
                                    } else {
                                        CustomNavigationBar(
                                            cityName: weatherData?.city ?? "",
                                            temperature: weatherData?.temperature ?? 0.0,
                                            weatherStatus: weatherData?.weatherStatus ?? "",
                                            onBackTapped: {
                                                searchText = ""
                                                showNavigationBar = false
                                                weatherData = nil
                                                requestLocationAndWeather()
                                            },
                                            onCloseTapped: {
                                                showNavigationBar = false
                                                weatherData = nil
                                            },
                                            isCurrentLocation: weatherData == nil
                                        )
                    
                                        VStack(spacing: 20) {
                                            if let weather = weatherData {
                                                WeatherDetailView(weatherData: weather, isCurrentLocation: false)
                                            } else if !showNavigationBar, let weather = locationManager.weatherData {
                                                WeatherDetailView(weatherData: weather, isCurrentLocation: true)
                                            }
                                        }
                                        .padding()
                                    }            }
        }
        .environmentObject(favoritesManager)
    }


    private func requestLocationAndWeather() {
        locationManager.requestLocation()
    }
    
    private func handleLocationSelection(_ prediction: LocationPrediction) {
        showAutocomplete = false
        predictions = []
        searchText = prediction.description
        selectedLocation = prediction
        
        weatherData=nil
        locationManager.weatherData=nil
        
        
        SwiftSpinner.show("Fetching Weather Details for \(prediction.description)")
        
        Task {
            do {
                let coordinates = try await NetworkManager.shared.fetchGeocoding(placeId: prediction.place_id)
                var weather = try await NetworkManager.shared.fetchWeather(
                    latitude: coordinates.latitude,
                    longitude: coordinates.longitude
                )
                
                await MainActor.run {
                    weather.city = prediction.description
                    self.weatherData = weather
                    self.showNavigationBar = true  
                    SwiftSpinner.hide()
                }
            } catch {
                print("Error fetching weather: \(error)")
                await MainActor.run {
                    SwiftSpinner.hide()
                }
            }
        }
    }
    
}
struct FavoriteCityView: View {
    let cityName: String
    @State private var weatherData: WeatherData?
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var showDetailView = false
    
    var body: some View {
        if let weather = weatherData {
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: toggleFavorite) {
                        Image("close-circle")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal)
                
                WeatherSummaryCard(
                    temperature: weather.temperature,
                    condition: weather.weatherCode,
                    location: weather.city,
                    isCurrentLocation: false
                )
                .background(Color.white.opacity(0.3))
                .cornerRadius(15)
                .onTapGesture {
                    showDetailView = true
                }
                
                WeatherMetricsView(
                    humidity: weather.humidity,
                    windSpeed: weather.windSpeed,
                    visibility: weather.visibility,
                    pressure: weather.pressure
                )
                .padding()
                .cornerRadius(15)
                
                ForecastTableView(forecasts: weather.forecasts)
                    .padding()
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(15)
            }
            .fullScreenCover(isPresented: $showDetailView) {
                WeatherTabView(
                    weatherData: weather,
                    isCurrentLocation: false,
                    onBackTapped: {
                        showDetailView = false
                    }
                )
                .tabViewStyle(.automatic)
                .interactiveDismissDisabled()
            }
            .overlay(
                Group {
                    if showToast {
                        VStack {
                            Spacer()
                            ToastView(message: toastMessage)
                        }
                        .transition(.opacity)
                        .animation(.easeInOut, value: showToast)
                    }
                }
            )
        } else {
            ProgressView()
                .onAppear {
                    Task {
                        await fetchWeatherForCity()
                    }
                }
        }
    }
    
    private func toggleFavorite() {
        favoritesManager.removeFavorite(cityName)
        toastMessage = "\(cityName) was removed from the Favorite List"
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }
    
    private func fetchWeatherForCity() async {
        do {
            let predictions = try await NetworkManager.shared.fetchAutocomplete(query: cityName)
            guard let firstPrediction = predictions.first else { return }
            
            let coordinates = try await NetworkManager.shared.fetchGeocoding(placeId: firstPrediction.place_id)
            
            var weather = try await NetworkManager.shared.fetchWeather(
                latitude: coordinates.latitude,
                longitude: coordinates.longitude
            )
            
            await MainActor.run {
                weather.city = cityName
                self.weatherData = weather
            }
        } catch {
            print("Error loading weather for \(cityName): \(error)")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NetworkManager.shared)
}

