import SwiftUI
import Foundation

struct AutocompleteListView: View {
    let predictions: [LocationPrediction]
    let onSelect: (LocationPrediction) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(predictions) { prediction in
                Button(action: {
                    onSelect(prediction)
                }) {
                    HStack {
                        Text(prediction.description)
                            .foregroundColor(.primary)
                            .padding(.vertical, 12)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                Divider()
                
            }

        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(maxHeight: 200)

    }
    
}
