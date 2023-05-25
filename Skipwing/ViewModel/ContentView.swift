import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        VStack {
            ViewController(currentView: .mainMenu)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .edgesIgnoringSafeArea(.all)
        }.preferredColorScheme(.light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


