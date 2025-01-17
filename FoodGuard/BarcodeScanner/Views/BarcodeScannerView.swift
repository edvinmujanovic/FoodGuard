import SwiftUI

struct BarcodeScannerView: View {
    @State private var API = FoodAPI()
    @State private var isFoodLoaded = false
    @State var viewModel = BarcodeScannerViewModel()
    @State private var productName: String = ""
    @State private var isScannerActive = true
    @State private var isSheetPresented = false
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                if isScannerActive {
                    ScannerView(scannedCode: $viewModel.scannedCode, alertItem: $viewModel.alertItem)
                        .edgesIgnoringSafeArea(.all)
                }
                
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                VStack {
                    Text("Scanner")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    Image(systemName: "viewfinder")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 280, height: 280)
                        .foregroundColor(.white)
                        .padding()
                    
                    Spacer()
                    
                    
                    if (productName != "") && !isFoodLoaded {
                        Text("You can scan another barcode now!")
                            .font(.title)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                    if isFoodLoaded {
                        Text("Barcode successfully scanned!")
                            .font(.title)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Text("You can scan another barcode now!")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                    } else {
                        Text("Place the barcode inside the frame to scan.")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
            }
            .onChange(of: viewModel.scannedCode) { newScannedCode in
                //load food when the barcode is scanned
                Task {
                    do {
                        try await API.loadFood(barcode: newScannedCode)
                        isFoodLoaded = true
                        isScannerActive = false
                        isSheetPresented = true // Present the sheet directly
                        
                        // set the productName when the API successfully loads the data
                        productName = API.foodModel?.name ?? "N/A"
                        //historyModel.addScannedProduct(productName: API.foodModel?.name ?? "N/A")
                        
                        //add to history
                        let history = HistoryData(productName: productName)
                        modelContext.insert(history)
                        
                        
                    } catch {
                        print("Error loading food: \(error)")
                    }
                }
            }
            
            .onChange(of: isSheetPresented) { newIsSheetPresented in
                if !newIsSheetPresented {
                    isScannerActive = true
                }
            }
            .onAppear {
                // start the scanner when the view appears
                isScannerActive = true
                isFoodLoaded = false
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isSheetPresented) {
                DraggableProductView(productName: productName, ingredients: API.foodModel?.ingredients ?? [], ingredientsTags: API.foodModel?.ingredientsTags ?? [], isSheetPresented: $isSheetPresented, isScannerActive: $isScannerActive)
                    .navigationBarHidden(true)
            }
        }
    }
}

