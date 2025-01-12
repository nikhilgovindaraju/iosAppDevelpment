
import SwiftUI

class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func run(action: @escaping () -> Void) {
        workItem?.cancel()
        let workItem = DispatchWorkItem(block: action)
        self.workItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}


struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var predictions: [LocationPrediction]
    @Binding var showAutocomplete: Bool
    @State private var isLoading = false
    
    let debouncer = Debouncer(delay: 0.3)
    
    var body: some View {
        HStack {
            SearchBarWrapper(
                text: $searchText,
                isLoading: $isLoading,
                onTextChange: { newValue in
                    if !newValue.isEmpty {
                        debouncer.run {
                            fetchPredictions(for: newValue)
                        }
                    } else {
                        showAutocomplete = false
                        predictions = []
                    }
                },
                onClear: {
                    searchText = ""
                    predictions = []
                    showAutocomplete = false
                }
            )
        }
        
    }
    
    private func fetchPredictions(for query: String) {
        isLoading = true
        showAutocomplete = true
        
        Task {
            do {
                let predictions = try await NetworkManager.shared.fetchAutocomplete(query: query)
                await MainActor.run {
                    self.predictions = predictions
                    self.isLoading = false
                }
            } catch {
                print("Error fetching predictions: \(error)")
                await MainActor.run {
                    self.predictions = []
                    self.isLoading = false
                }
            }
        }
    }
    
    func clearAutocomplete() {
        predictions = []
        showAutocomplete = false
    }
}

struct SearchBarWrapper: UIViewRepresentable {
    @Binding var text: String
    @Binding var isLoading: Bool
    let onTextChange: (String) -> Void
    let onClear: () -> Void
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Enter city name"
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
        

        if isLoading {
            let loader = UIActivityIndicatorView(style: .medium)
            loader.startAnimating()
            uiView.setRightView(loader, for: .always)
        } else {
            uiView.setRightView(nil, for: .always)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        var parent: SearchBarWrapper
        
        init(_ parent: SearchBarWrapper) {
            self.parent = parent
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.text = searchText
            parent.onTextChange(searchText)
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            parent.onClear()
            searchBar.resignFirstResponder()
        }
    }
}

extension UISearchBar {
    func setRightView(_ view: UIView?, for position: UITextField.ViewMode) {
        if let textField = value(forKey: "searchField") as? UITextField {
            textField.rightView = view
            textField.rightViewMode = position
        }
    }
}
    
#Preview {
    SearchBarView(
        searchText: .constant(""),
        predictions: .constant([]),
        showAutocomplete: .constant(false)
    )
}
