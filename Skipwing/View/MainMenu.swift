//
//  MainMenu.swift
//  SpriteSandbox
//
//  Created by Ario Syahputra on 22/05/23.
//

import SwiftUI

struct MainMenu: View {
    @Binding var currentView: viewScreen
    @State private var buttonScale: CGFloat = 1.0

    
    var body: some View {
        ZStack{
            Image("BackgroundBlur")
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .edgesIgnoringSafeArea(.all)
                    
            VStack{
                
                Text("Jump The Rope")
                    .font(.custom("Fredoka-Bold", size: 43))
                    .foregroundColor(.white)
                    .padding(.vertical, 200)
                
                
                Button {
                    withAnimation {
                        currentView = .gameView
                    }
                } label: {
                    Text("Play")
                        .multilineTextAlignment(.center)
                        .font(.custom("Fredoka-Medium", size: 30))
                        .foregroundColor(.white)
                        .frame(width: 210, height: 67)
                        .padding(2)
                        .background(Color.accentColor)
                        .cornerRadius(30)
                        .scaleEffect(buttonScale)
                }
                .onAppear {
                    let timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
                        withAnimation(Animation.easeInOut(duration: 0.8).repeatForever()) {
                            buttonScale = 0.9
                        }
                    }
                    timer.fire()
                }
               
            }
                    
            
        }
        .onAppear {
            SoundController.instance.playSound(fileName: "MainMenu")
            SoundController.instance.setVolume(0.2)
        }
    }
}

struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu(currentView: .constant(.mainMenu))
    }
}
