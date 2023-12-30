import SwiftUI
import CoreGraphics
import CoreImage.CIFilterBuiltins

struct BarcodeGeneratorView: View {
    @State private var input = ""
    @State private var generatedImageInfo: (image: UIImage, text: String, type: BarcodeType)?
    @Binding private var type: BarcodeType
    @FocusState private var isTextFieldFocused
    
    init(type: Binding<BarcodeType>) {
        self._type = type
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            if let generatedImageInfo {
                Text(generatedImageInfo.text)
                
                let image = Image(uiImage: generatedImageInfo.image)
                
                image.resizable()
                    .scaledToFit()
                
                ShareLink(item: image, preview: SharePreview(generatedImageInfo.text, image: image))
            }
            
            Spacer()
            
            HStack {
                Picker(
                    selection: $type,
                    content: {
                        ForEach(BarcodeType.allCases) { barcodeType in
                            Text(barcodeType.rawValue)
                                .tag(barcodeType)
                                .onTapGesture {
                                    type = barcodeType
                                }
                        }
                    },
                    label: {
                        Text(type.rawValue)
                    }
                )
                .pickerStyle(.menu)
                
                TextField("Barcode Text/ID/URL", text: $input)
                    .focused($isTextFieldFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit(of: .text) {
                        isTextFieldFocused = false
                        generateImage()
                    }
                
                Button("Submit") {
                    isTextFieldFocused = false
                    generateImage()
                }
            }
        }
        .padding()
        .navigationTitle("Generate Barcode")
        .onChange(of: input) { _ in
            generateImage()
        }
    }
    
    func generateImage() {
        guard input != generatedImageInfo?.text || type != generatedImageInfo?.type else { return }
        
        Task {
            let filter: CIFilter? = {
                switch type {
                case .aztec:
                    let filter = CIFilter.aztecCodeGenerator()
                    filter.setValue(40, forKey: "inputCorrectionLevel")
                    return filter
                case .code128:
                    return CIFilter.code128BarcodeGenerator()
                case .pdf417:
                    return CIFilter.pdf417BarcodeGenerator()
                case .qrCode:
                    let filter = CIFilter.qrCodeGenerator()
                    filter.setValue("M", forKey: "inputCorrectionLevel")
                    return filter
                }
            }()
            
            guard let filter, let data = input.data(using: .ascii) else { return }
            
            filter.setValue(data, forKey: "inputMessage")
            
            guard let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 14, y: 14)) else { return }
            
            let context = CIContext(options: nil)
            let cgImage = context.createCGImage(output, from: output.extent)!
            let image = UIImage(cgImage: cgImage)
            
            self.generatedImageInfo = (image, input, type)
        }
    }
}

struct BarcodeGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeGeneratorView(type: .constant(.qrCode))
    }
}
