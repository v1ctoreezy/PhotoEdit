import SwiftUI

struct PhotoEditView: View {
    init(image initImage:UIImage?){
        
        print("Photo edit: init")
        guard let image = initImage else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)){
            PhotoEditingController.shared.setImage(image: image)
        }
    }
    
    @State private var showImagePicker = false
    @State private var pickImage:UIImage?
    @EnvironmentObject var shared: PhotoEditingController
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView{
            ZStack{
                Color.myBackground
                    .edgesIgnoringSafeArea(.all)
                VStack{
                    HStack{
                        Button(action:{
                            self.showImagePicker = true
                        }){
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }
                        Spacer()
                        if(shared.previewImage != nil){
                            NavigationLink(destination: ExportView()){
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                            }
                        }
                    }
                    .zIndex(1)
                    PhotoEditorView().frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(0)
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showImagePicker, onDismiss: self.loadImage){
            ZStack{
                ImagePicker(image: self.$pickImage)
            }
            
        }
    }
    
    func loadImage(){
        print("Photo edit: pick image finish")
        guard let image = self.pickImage else {
            return
        }
        self.pickImage = nil
        print("Photo edit: pick then setImage")
        self.shared.setImage(image: image)
    }
}

struct PhotoEditView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            PhotoEditView(image: UIImage(named: "carem"))
                .background(Color(UIColor.systemBackground))
                .environment(\.colorScheme, .dark)
                .environmentObject(PhotoEditingController.shared)
        }
    }
}
