//
//  MenuScene.swift
//  Fear-The-Dead
//
//  Created by DuWeiWu on 2018/7/10.
//  Copyright © 2018年 DuWeiWu. All rights reserved.
//

import SpriteKit


class MenuScene: SKScene {
    // 用于播放声音的 文件名
    var soundToPlay: String?
    
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor(red: 0, green: 0, blue: 0, alpha: 1)        // 设置label
        // 点击任意处开始
        let label = SKLabelNode(text: "Press anywhere to play again!");
        label.fontName = "AvenirNext-Bold";
        label.fontSize = 55
        label.position = CGPoint.zero
        addChild(label)
        
        // 播放声音
        if let soundToPlay = soundToPlay {
            run(SKAction.playSoundFileNamed(soundToPlay, waitForCompletion: false))
        }
    }
    
    // 当我们点击场景的时候，切换的gamescene
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let gameScene = SKScene(fileNamed: "GameScene") else {
            fatalError()
        }
        // 创建flip类型的 切换场景风格
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        gameScene.scaleMode = .aspectFill
        view?.presentScene(gameScene, transition: transition)
    }
    
    deinit {
        
    }
}
