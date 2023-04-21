//
//  MoonoGameScene.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/17.
//

import SpriteKit
import AVFAudio

protocol MoonoGameSceneDelegate: AnyObject {
    func didReceiveTouchCount(number: Int64)
}

final class MoonoGameScene: SKScene {
    
    weak var gameSceneDelegate: MoonoGameSceneDelegate?
    
    private var player: AVAudioPlayer?
    
    // MARK: - Game Elements
    private let numberToIncrease: Int64 = 1
    //Nodes
    private var particles: SKEmitterNode?
    private var moonoImage: SKSpriteNode?
    
    //Actions
    private let touchFadeOut: SKAction = SKAction.fadeOut(withDuration: 0.1)
    private let touchFadeIn: SKAction = SKAction.fadeIn(withDuration: 0.1)
    
    // MARK: - Life cycle
    /// Indicates when the scene is presented by a view.
    override func didMove(to view: SKView) {
        setUpScenery()
    }
    
    // MARK: - Set up
    private func showMoveParticles(touchPosition: CGPoint) {
        
        if particles == nil {
            particles = SKEmitterNode(fileNamed: GameSceneAsset.particles.rawValue)
            guard let particles = particles else { return }
            particles.zPosition = 1
            particles.targetNode = self
            addChild(particles)
        }
        
        particles?.position = touchPosition
        particles?.particleAction?.duration = 3.0 //TODO: Need to check
        moonoImage?.run(touchFadeOut, completion: {
            self.moonoImage?.run(self.touchFadeIn)
        })
        
    }
    
    private func setUpScenery() {
        moonoImage = SKSpriteNode(imageNamed: GameSceneAsset.moonoImage.rawValue)
        guard let moonoNode = moonoImage else { return }
        moonoNode.anchorPoint = CGPoint(x: 0, y: 0)
        moonoNode.position = CGPoint(x: 80, y: 370)
        moonoNode.zPosition = 0
        moonoNode.size = CGSize(width: 250, height: 250)
        addChild(moonoNode)
    }
    
    //MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /// Let delegate know there is an increase in touch number
        gameSceneDelegate?.didReceiveTouchCount(number: numberToIncrease)
        
        /// Play audio for every touch
        playGameSound()
        
        particles?.removeFromParent()
        particles = nil
        
        /// Define touch animation range;
        /// Range is based on the position and the size of 'moonoImage property'
        let moonoImagePostion = self.moonoImage?.position ?? CGPoint(x: 0.0, y: 0.0)
        let moonoImageSize = self.moonoImage?.size ?? CGSize(width: 0.0, height: 0.0)
        let rangeX = moonoImagePostion.x...(moonoImagePostion.x + moonoImageSize.width)
        let rangeY = moonoImagePostion.y...(moonoImagePostion.y + moonoImageSize.height)
        
        /// Check if touch is found in the valid range;
        /// Fire animation if the touch is in the valid range
        for touch in touches {
            
            let startPoint = touch.location(in: self)
            if rangeX.contains(startPoint.x) && rangeY.contains(startPoint.y) {
                showMoveParticles(touchPosition: startPoint)
            }
            
        }
        
    }
    
    private func playGameSound() {
        let fileName = "bubbles"
        guard let audioFileUrl = Bundle.main.url(forResource: fileName, withExtension: "wav") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: audioFileUrl)
            player?.play()
        } catch(let err) {
            print("Error Init AVAudioPlayer ---- \(err.localizedDescription)")
        }
    }
    
}

