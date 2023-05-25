//
//  SoundController.swift
//  SpriteSandbox
//
//  Created by Ario Syahputra on 22/05/23.
//

import AVFoundation

class SoundController {
    static let instance = SoundController()
    var player: AVAudioPlayer?
    
    func playSound(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ".mp3") else {
            print("Sound file not found: \(fileName)")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("Error playing sound \(error.localizedDescription)")
        }
        
        player?.numberOfLoops = -1
    }
    
    func setVolume(_ volume: Float) {
        player?.volume = volume
    }
}


