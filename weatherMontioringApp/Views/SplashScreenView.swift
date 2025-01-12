
import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            Image("App_background")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image("Partly Cloudy")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.black)
                
                Spacer()
                
                Image("Powered_by_Tomorrow-Black")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                    .padding(.bottom, 50)
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            ContentView()
        }
    }
}

