import SwiftUI

struct ContentView: View {
    @State private var scanType: BarcodeType = .qrCode
    
    var body: some View {
        TabView {
            NavigationView {
                BarcodeGeneratorView(type: $scanType)
            }
            .tabItem {
                Label("Create", systemImage: "barcode")
            }
            
            #if os(iOS)
            NavigationView {
                BarcodeScannerView()
            }
            .tabItem {
                Label("Scan", systemImage: "qrcode.viewfinder")
            }
            #endif
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
