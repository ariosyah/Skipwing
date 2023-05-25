//
//  PlayScreen.swift
//  SpriteSandbox
//
//  Created by Ario Syahputra on 22/05/23.
//

import SwiftUI
import SpriteKit
import UIKit

struct GameView: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        
        //FPS BOX
        view.showsFPS = false
        view.showsNodeCount = false

        if let scene = GameScene(fileNamed: "GameScene.sks") {
            scene.scaleMode = .resizeFill
            view.presentScene(scene)
        }
        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
    }
}

//Custom Color using Hex in SpriteKit
extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexValue = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if hexValue.hasPrefix("#") {
            hexValue = String(hexValue.dropFirst())
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexValue).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}


class GameScene: SKScene {
    private var player: SKSpriteNode!
    private var isJumping = false
    private var isLose = false
    private var jumpCount = 0
    private var jumpCountLabel: SKLabelNode!
    private var instruction: SKLabelNode!
    private var circle: SKShapeNode!
    private var playAgainButton: SKShapeNode!
    private var finalScoreLabel: SKLabelNode!
    private var gameOverLabel: SKLabelNode!
    private var popUpDesc: SKLabelNode!
    private var popUpContainer: SKShapeNode!
    let lightGreen = "#7FA734"
    let darkGreen = "#3A5216"
    private var canJump = false
    private var playerHasJumpedThisCycle = false
    private var rope: SKShapeNode! = nil
    private var feedbackGenerator: UIImpactFeedbackGenerator?


    override func didMove(to view: SKView) {
        
        feedbackGenerator = UIImpactFeedbackGenerator(style: .light) // Haptic feedback levels when player jumps

        let background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = -1 // Place the background behind other nodes
        
        // Circle scoreboard banner
        circle = SKShapeNode(circleOfRadius: 100) // Set the radius of the circle
        circle.position = CGPoint(x: 0, y: 220) // Set the position of the circle
        circle.fillColor = UIColor(hex: lightGreen) // Set the fill color of the circle
        circle.alpha = 0.8
        circle.strokeColor = .clear
        
        // "Tap to jump" instruction label
        instruction = SKLabelNode(text: "Tap to jump!")
        instruction.position = CGPoint(x: circle.position.x, y: circle.position.y - circle.frame.size.height/2 - 50)
        instruction.fontColor = .white
        instruction.fontSize = 40
        instruction.fontName = "Fredoka-SemiBold"
        
        // Jumpcount score label
        jumpCountLabel = SKLabelNode(text: String(jumpCount))
        jumpCountLabel.position = CGPoint(x: circle.position.x, y: circle.position.y - jumpCountLabel.fontSize/2)
        jumpCountLabel.fontColor = SKColor.white
        jumpCountLabel.fontSize = 50
        jumpCountLabel.fontName = "Fredoka-Regular"

        // Player
        print("player Spawned")
        player = SKSpriteNode(imageNamed: "Person")
        player.position = CGPoint(x: frame.midX, y: -300 + 75)
        
        
        // Rope Components
        let ropeYMaxScale = 0.65 // Max Scaling Y point
        let ropeYMinScale = 0.2  // Min Scaling Y point
        let multiplyFactor = 0.5 // Adjust jump safe area
        
        let rope = createRopeNode()
        rope.position = CGPoint(x: frame.midX, y: frame.midY - 200) // Rotate the rope to horizontal position
        rope.zPosition = 1 // Adjust the rope to be in front of player
        rope.zRotation = .pi / 2 * -1
        
        // rope starting point
        rope.xScale = ropeYMaxScale
        
        // Adjust the height of the swing rope
        let scaleAction1 = SKAction.scaleX(to: ropeYMinScale, duration: 0.5) // Rope animation from max to min (top to mid)
        // Rope animation from mid to 1/2 bottom
        let scaleAction2 = SKAction.scaleX(to: ropeYMinScale + ((-ropeYMaxScale-ropeYMinScale) * multiplyFactor), duration: multiplyFactor)
        
        // Jump safe area
        let enableJumpAction = SKAction.run {
            self.canJump = true
        }
        
        let scaleAction3 = SKAction.scaleX(to: -ropeYMaxScale, duration: 1-multiplyFactor)  // Rope animation from 1/2 bottom to bottom
        
        // Adjust the rope to back (z position)
        let swapAction = SKAction.run {
            rope.zPosition = -1
            
            // Player lose && jumped not in safe area
            if !self.playerHasJumpedThisCycle && !self.isLose {
                self.isLose = true
                self.showGameOverPopup()
                self.circle.removeFromParent()
                self.jumpCountLabel.removeFromParent()
                
                // Stop the rope
//                rope.removeAllActions()
            }
            
            self.canJump = false
        }
        
        let scaleAction4 = SKAction.scaleX(to: ropeYMinScale, duration: 0.5) // Rope animation from mid to bot
        let scaleAction5 = SKAction.scaleX(to: ropeYMaxScale, duration: 0.5) // Rope animation from mid to top
        
        // Set rope position to front
        let swapAction2 = SKAction.run {
            rope.zPosition = 1
            self.playerHasJumpedThisCycle = false
        }
        
        // Repeat animation
        let sequence = SKAction.sequence([scaleAction1, scaleAction2, enableJumpAction, scaleAction3, swapAction, scaleAction4, scaleAction5, swapAction2])
        let repeatAction = SKAction.repeatForever(sequence)
        rope.run(repeatAction)
        
        
        // Merge all components to be in the game scene
        addChild(background)
        addChild(circle)
        addChild(jumpCountLabel)
        addChild(instruction)
        addChild(player)
        addChild(rope)
    }
    
    // Trigger the haptic feedback
    private func triggerHapticFeedback() {
        feedbackGenerator?.impactOccurred()
    }

    private func createRopeNode() -> SKShapeNode {
        let radius = 200.0 // Adjust the size & radius of weight
        
        rope = SKShapeNode()
        rope.fillColor = .clear // Set fill color to no color or clear
        rope.strokeColor = .white
        rope.lineWidth = 6.0 // Adjust width of the rope

        let path = UIBezierPath(
            arcCenter: CGPoint(x: 0, y: 0),
            radius: CGFloat(radius),
            startAngle: CGFloat.pi / 2,
            endAngle: -CGFloat.pi / 2,
            clockwise: true
        )

        rope.path = path.cgPath

        return rope
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if playAgainButton?.contains(touchLocation) == true {
            
            // Perform smooth animation transition
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            
            let resetAction = SKAction.run {
                self.resetGame() // Execute the resetGame() function
            }
            
            let sequence = SKAction.sequence([fadeOut, resetAction, fadeIn])
            playAgainButton?.run(sequence)
            
        } else {
            jumpPlayer()
        }
        
        if instruction.alpha > 0 && isJumping {
            
           let fadeOutAction = SKAction.fadeOut(withDuration: 0.5) // Fade out the instruction label
           instruction.run(fadeOutAction)
            
        }
        
    }

    private func jumpPlayer() {
        if !isJumping {
            isJumping = true
            jumpCount += 1
            jumpCountLabel.text = String(jumpCount)
            
            // Player can't jump & game is over
            if !canJump {
                
                if !isLose {
                    print("gabisa jump")
                    jumpCount -= 1
                    self.isLose = true
                    showGameOverPopup()
                    circle.removeFromParent()
                    jumpCountLabel.removeFromParent()
                }
                
                
            } else {
                
                // Create a sound action to play the jump sound
                let jumpSoundAction = SKAction.playSoundFileNamed("JumpSound.mp3", waitForCompletion: false)
                
                let jumpAction = SKAction.sequence([
                    SKAction.run { [weak self] in
                        self?.player.texture = SKTexture(imageNamed: "PersonJump")
                    },
                    jumpSoundAction, // Play the jump sound
                    SKAction.run { [weak self] in
                        self?.triggerHapticFeedback() // Trigger haptic
                    },
                    SKAction.moveBy(x: 0, y: 80, duration: 0.3),
                    SKAction.moveBy(x: 0, y: -80, duration: 0.3),
                    SKAction.run { [weak self] in
                        self?.player.texture = SKTexture(imageNamed: "Person")
                        self?.isJumping = false
                    }
                ])
                player.run(jumpAction)
                
                // Player can jump
                playerHasJumpedThisCycle = true
            }
            
        }
    }
    
    private func createButton(withText text: String) -> SKShapeNode {
        
        //Adjust button size and radius
        let buttonSize = CGSize(width: 157, height: 50)
        let cornerRadius: CGFloat = 20

        // Create the button shape node and style
        let button = SKShapeNode(rectOf: buttonSize, cornerRadius: cornerRadius)
        button.fillColor = UIColor(hex: darkGreen)
        button.strokeColor = .clear
        button.alpha = 2.0

        // Create the label for the button
        let buttonLabel = SKLabelNode(text: text)
        buttonLabel.fontName = "Fredoka-Medium"
        buttonLabel.fontSize = 20
        buttonLabel.fontColor = .white
        buttonLabel.position = CGPoint(x: 0, y: 0)

        // Center the label within the button
        buttonLabel.horizontalAlignmentMode = .center
        buttonLabel.verticalAlignmentMode = .center

        // Add label as child to button
        button.addChild(buttonLabel)

        return button
    }


    
    private func showGameOverPopup() {
        
        // Adjust popUp shape size and radius
        let cornerRadius: CGFloat = 20
        let popUpSize = CGSize(width: 265, height: 355)
        
        // Stop the rope
        rope.removeAllActions()

        // Popup shape container
        popUpContainer = SKShapeNode(rectOf: popUpSize, cornerRadius: cornerRadius)
        popUpContainer.fillColor = UIColor(hex: lightGreen)
        popUpContainer.position = CGPoint(x: frame.midX, y: frame.midY)
        popUpContainer.zPosition = 1
        popUpContainer.alpha = 0.8
        popUpContainer.strokeColor = .clear

        // Gameover label
        gameOverLabel = SKLabelNode(text: "Game Over!")
        gameOverLabel.fontSize = 35
        gameOverLabel.fontName = "Fredoka-SemiBold"
        gameOverLabel.fontColor = .white
        gameOverLabel.alpha = 2.0
        gameOverLabel.position = CGPoint(x: 0, y: 100)

        // Final score label
        finalScoreLabel = SKLabelNode(text: String(jumpCount))
        finalScoreLabel.fontSize = 70
        finalScoreLabel.fontName = "Fredoka-Light"
        finalScoreLabel.fontColor = .white
        finalScoreLabel.alpha = 2.0
        finalScoreLabel.position = CGPoint(x: 0, y: 0)
        
        // "Jumps today" / Popup description label
        popUpDesc = SKLabelNode(text: "Jumps today")
        popUpDesc.fontSize = 20
        popUpDesc.fontName = "Fredoka-SemiBold"
        popUpDesc.fontColor = .white
        popUpDesc.alpha = 2.0
        popUpDesc.position = CGPoint(x: 0, y: -70)

        // Play again button
        playAgainButton = createButton(withText: "Play Again")
        playAgainButton.position = CGPoint(x: 0, y: -130)

        // Merge all components to popup
        popUpContainer.addChild(gameOverLabel)
        popUpContainer.addChild(finalScoreLabel)
        popUpContainer.addChild(popUpDesc)
        popUpContainer.addChild(playAgainButton)
        addChild(popUpContainer)

        // Play sound effect when the pop-up appears
        let soundAction = SKAction.playSoundFileNamed("GameOver.mp3", waitForCompletion: false)
        run(soundAction)
        
        // remove instruction "Tap to jump" when pop up appears
        self.instruction.removeFromParent()
        self.canJump = false
    }

    
    private func resetGame() {
        
        // Adding new game scene as a reset game
        let newScene = GameScene(fileNamed: "GameScene.sks")!
        newScene.size = self.size
        newScene.anchorPoint = self.anchorPoint
        newScene.scaleMode = self.scaleMode
        let animation = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(newScene, transition: animation)
        isLose = false
        
        // Primitive reset game
//        jumpCount = 0
//        instruction.alpha = 1
//        jumpCountLabel.text = String(jumpCount)
//        popUp.removeFromParent()
//
//        isJumping = false
//
//        // Reset any other game-related variables or nodes to their initial values
//
//        // Re-add the circle and jump count label
//        addChild(circle)
//        addChild(jumpCountLabel)

        }
    

    
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}


