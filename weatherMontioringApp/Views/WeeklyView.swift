
import SwiftUI
import Highcharts


struct ChartView: UIViewRepresentable {
    let options: HIOptions
    
    func makeUIView(context: Context) -> HIChartView {
        let chart = HIChartView()
        chart.options = options
        return chart
    }
    
    func updateUIView(_ uiView: HIChartView, context: Context) {
        uiView.options = options
    }
}

struct WeeklyView: View {
    let weatherData: WeatherData
    
    private var chartOptions: HIOptions {
        let options = HIOptions()
        
        let chart = HIChart()
        chart.type = "arearange"
        options.chart = chart
        
        let title = HITitle()
        title.text = "Temperature Variation by Day"
        options.title = title
        
        
        func formatDate(_ dateString: String) -> String {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd"
            
            if let date = inputFormatter.date(from: dateString) {
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "dd MMM"
                return outputFormatter.string(from: date)
            }
            return dateString
        }
                
        let xAxis = HIXAxis()
        xAxis.categories = weatherData.forecasts.prefix(7).map { formatDate($0.date) }
        xAxis.tickPositions = [0,1, 2,3, 4,5, 6]


        xAxis.tickmarkPlacement = "on"
        xAxis.tickInterval = 1
        xAxis.lineWidth = 1
        xAxis.lineColor = HIColor(hexValue: "000000")
        xAxis.title = HITitle()
        xAxis.title.text = nil
        options.xAxis = [xAxis]
        
        let yAxis = HIYAxis()
        yAxis.title = HITitle()
        yAxis.title.text = "Temperatures"
        yAxis.gridLineWidth = 1
        options.yAxis = [yAxis]

        let series = HIArearange()
        series.name = "Temperature Range"
        series.data = weatherData.forecasts.prefix(7).map { forecast in
            [
                NSNumber(value: forecast.tempMin),
                NSNumber(value: forecast.tempMax)
            ]
        }

        series.fillColor = HIColor(linearGradient: ["x1": 0, "y1": 0, "x2": 0, "y2": 1], stops: [
                        [0.0, "rgba(233, 207, 155, 0.8)"],
                        [1.0, "rgba(200, 212, 223, 0.8)"]
                    ])

        let marker = HIMarker()
        marker.enabled = true
        marker.radius = 4
        marker.fillColor = HIColor(hexValue: "000000")  // Black points
        marker.lineWidth = 1
        series.marker = marker
        
        options.series = [series]
        
        return options
    }
    
    
    var body: some View {
        ZStack {
            Image("App_background")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
            
        VStack(spacing: 20) {
            WeatherSummaryCard(
                temperature: weatherData.temperature,
                condition: weatherData.weatherCode,
                location: weatherData.city,
                isCurrentLocation: false
                
            )
            .padding()
            .background(Color.white.opacity(0.2))
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            
            ChartView(options: chartOptions)
                .frame(height: 300)
        }
        .padding()
    }
    }
}
