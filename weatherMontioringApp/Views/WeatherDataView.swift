
import SwiftUI
import Highcharts
import UIKit



struct WeatherDataView: View {
    let weatherData: WeatherData
    
    private func createGauge(name: String, value: Double, radius: String,
                            innerRadius: String, color: HIColor) -> HISolidgauge {
        let gauge = HISolidgauge()
        gauge.name = name
        
        let dataLabels = HIDataLabels()
        dataLabels.enabled = false
        gauge.dataLabels = [dataLabels]
        
        gauge.radius = radius
        gauge.innerRadius = innerRadius
        gauge.color = color
        
        let data = HIData()
        data.y = NSNumber(value: value)
        data.color = color
        data.radius = radius
        data.innerRadius = innerRadius
        
        gauge.data = [data]
        
        return gauge
    }
    
    private var chartOptions: HIOptions {
        let options = HIOptions()
        
        let title = HITitle()
        title.text = "Weather Data"
        options.title = title
        
        let chart = HIChart()
        chart.type = "solidgauge"
        chart.height = NSNumber(value: 400)
        chart.backgroundColor = HIColor(hexValue: "FFFFFF")
        options.chart = chart

        let pane = HIPane()
        pane.startAngle = NSNumber(value: 0)
        pane.endAngle = NSNumber(value: 360)
 
        let background1 = HIBackground()
        background1.backgroundColor = HIColor(rgba: 130, green: 238, blue: 106, alpha: 0.35)
        background1.outerRadius = "112%"
        background1.innerRadius = "88%"
        background1.borderWidth = NSNumber(value: 0)
        
        let background2 = HIBackground()
        background2.backgroundColor = HIColor(rgba: 106, green: 165, blue: 231, alpha: 0.35)
        background2.outerRadius = "87%"
        background2.innerRadius = "63%"
        background2.borderWidth = NSNumber(value: 0)
        
        let background3 = HIBackground()
        background3.backgroundColor = HIColor(rgba: 255, green: 99, blue: 71, alpha: 0.35)
        background3.outerRadius = "62%"
        background3.innerRadius = "38%"
        background3.borderWidth = NSNumber(value: 0)
        
        pane.background = [background1, background2, background3]
        options.pane = [pane]
        
        let plotOptions = HIPlotOptions()
        plotOptions.solidgauge = HISolidgauge()
        plotOptions.solidgauge.rounded = true
        plotOptions.solidgauge.linecap = "round"
        plotOptions.solidgauge.stickyTracking = false
        let dataLabels = HIDataLabels()
        dataLabels.enabled = false
        plotOptions.solidgauge.dataLabels = [dataLabels]
        options.plotOptions = plotOptions

        let yAxis = HIYAxis()
        yAxis.min = NSNumber(value: 0)
        yAxis.max = NSNumber(value: 100)
        yAxis.lineWidth = NSNumber(value: 0)
        yAxis.tickPositions = []
        options.yAxis = [yAxis]

        let cloudCover = createGauge(
            name: "Cloud Cover",
            value: weatherData.cloudCover,
            radius: "112%",
            innerRadius: "88%",
            color: HIColor(rgba: 130, green: 238, blue: 106, alpha: 1.0)
        )
        
        let humidity = createGauge(
            name: "Humidity",
            value: weatherData.humidity,
            radius: "87%",
            innerRadius: "63%",
            color: HIColor(rgba: 106, green: 165, blue: 231, alpha: 1.0)
        )
        
        let precipitation = createGauge(
            name: "Precipitation",
            value: weatherData.precipitationProbability,
            radius: "62%",
            innerRadius: "38%",
            color: HIColor(rgba: 255, green: 99, blue: 71, alpha: 1.0)
        )
        
        options.series = [cloudCover, humidity, precipitation]
        
        return options
    }
    
    var body: some View {
        ZStack {
            Image("App_background")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
            
            VStack(spacing: 20) {
                VStack {
                    VStack(spacing: 15) {
                        WeatherMetricRow(icon: "Precipitation", value: "\(Int(weatherData.precipitationProbability))%", title: "Precipitation:")
                        WeatherMetricRow(icon: "Humidity", value: "\(Int(weatherData.humidity))%", title: "Humidity:")
                        WeatherMetricRow(icon: "CloudCover", value: "\(Int(weatherData.cloudCover))%", title: "Cloud Cover:")
                    }
                    .padding()
                }
                .background(Color.white.opacity(0.2))
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .frame(width: .infinity)
                
                ChartView(options: chartOptions)
                    .frame(height: 400)
            }
            .padding()
        }
    }
}

struct WeatherMetricRow: View {
    let icon: String
    let value: String
    let title: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Image(icon)
            .resizable()
            .frame(width: 35, height: 35)
            .padding(.leading, 50)
            
            HStack {
                Text(title)
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(value)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    
            }
            .padding(.leading, 20)
        }
    }
}
