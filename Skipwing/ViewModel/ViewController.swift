//
//  ViewController.swift
//  SpriteSandbox
//
//  Created by Ario Syahputra on 22/05/23.
//

import SwiftUI

enum viewScreen {
    case mainMenu
    case gameView
}

struct ViewController: View {
    @State var currentView: viewScreen
    
    var body: some View {
        if currentView == .mainMenu {
            MainMenu(currentView: $currentView)
        }else if currentView == .gameView {
            GameView()
        }
    }
}

//struct ViewController_Previews: PreviewProvider {
//    static var previews: some View {
//        ViewController()
//    }
//}
