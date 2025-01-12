
import SwiftUI
import Foundation

struct MetricItem: View {
    let icon: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(icon)  
                .resizable()
                .scaledToFit()
                .frame(width: 55, height: 55)
            Text(value)
                .font(.subheadline)
        }
    }
}


