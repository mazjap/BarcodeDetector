import SwiftUI

struct BarcodeScannerView: View {
    @State private var scannedCode: String?
    
    var body: some View {
        CameraView {
            scannedCode = $0
        }
        .overlay(alignment: .bottom) {
            if let scannedCode {
                let attrText: AttributedString = {
                    var attrText = AttributedString(scannedCode)
                    
                    attrText.font = .system(size: 30)
                    attrText.foregroundColor = Color.white
                    
                    return attrText
                }()
                
                Text(attrText)
                    .textSelection(.enabled)
                    .padding()
                    .background {
                        Color.black.opacity(0.5)
                    }
            }
        }
        .ignoresSafeArea(.container, edges: .top)
    }
}

#Preview {
    BarcodeScannerView()
}
