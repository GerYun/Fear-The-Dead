//
//  GameScene.swift
//  Fear-The-Dead
//
//  Created by DuWeiWu on 2018/7/10.
//  Copyright © 2018年 DuWeiWu. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK: - 实例变量
    let playerSpeed: CGFloat = 150.0  // 角色的移动速度
    let zombieSpeed: CGFloat = 75.0   // 僵尸的移动速度
    
    var goal: SKSpriteNode?    //Goal 有目标, 目的地，守门员 终点的意思，这里就是赢了
    var player: SKSpriteNode?
    var zombies: [SKSpriteNode] = []
    
    
    // MARK: 生命周期
    // 最后点击的位置
    var lastTouch: CGPoint? = nil
    
    override func didMove(to view: SKView) {
        
        // 设置物理世界的 conctat 代理
        physicsWorld.contactDelegate = self
        
        // 设置初始化相机的位置
        updateCamera()
    }
    
    // MARK: - 各种更新
    // 在物理模拟后执行场景任何需要的更新
    override func didSimulatePhysics() {
        if let _ = player {
            updatePlayer()
            updateZombies()
        }
    }
    
    // 判断是否要更新玩家的位置
    private func shouldMove(currentPosition: CGPoint, touchPosition: CGPoint) -> Bool {
        // abs 返回绝对值
        // 判断，点击的距离，是否大于玩家的宽度或者高度的一半
        // 这里也是判断 点击 是否发生在 玩家身体外面，如果点击在了玩家身体上 就不移动了
        let x = abs(currentPosition.x - touchPosition.x)
        let y = abs(currentPosition.y - touchPosition.y)
        return x > player!.size.width * 2 || y > player!.size.height * 0.5
    }
    
    // 朝最后一次触摸的方向来更新玩家的位置
    func updatePlayer() {
        guard let touch = lastTouch, let player = player else {
            return
        }
        
        guard shouldMove(currentPosition: player.position, touchPosition: touch) else {
            // 不需要移动 将人物设为静止状态
            player.physicsBody?.isResting = true
            return
        }
        
        // 计算移动的角度
        let angle = atan2(player.position.y - touch.y, player.position.x - touch.x +  CGFloat.pi)
        // 创建旋转动作
        let rotateAction = SKAction.rotate(toAngle: angle + CGFloat.pi / 2, duration: 0)
        player.run(rotateAction)
        
        
        // 速速
        let velocotyX = playerSpeed * cos(angle)
        let velocityY = playerSpeed * sin(angle)
        
        // 包含二维向量的结构体，以米/秒为单位。
        // 设置这个 人物就会行走
        let newVelocity = CGVector(dx: velocotyX, dy: velocityY)
        player.physicsBody?.velocity = newVelocity
        
        // 更新相机
        updateCamera()
    }
    
    func updateCamera() {
        if let camera = camera, let player = player {
            camera.position = player.position
        }
    }
    
    // 更新所有僵尸的位置 朝着玩家方向移动
    func updateZombies() {
        
        guard let targetPosition = player?.position else {
            return
        }
        
        for zombie in zombies {
            let currentPosition = zombie.position
            // 计算出需要旋转的角度
            let angle = atan2(currentPosition.y - targetPosition.y, currentPosition.x - targetPosition.x) + CGFloat.pi
            let rotateAction = SKAction.rotate(toAngle: angle + CGFloat.pi * 0.5, duration: 0)
            zombie.run(rotateAction)
            
            // CGVector 二维向量
            let velocotyX = zombieSpeed * cos(angle)
            let velocityY = zombieSpeed * sin(angle)
            let newVelocity = CGVector(dx: velocotyX, dy: velocityY)
            zombie.physicsBody?.velocity = newVelocity
        }
    }
}


// MARK: - 处理点击事件
extension GameScene {
    
    // 处理手势
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }
    
    // 保存最后点击的位置
    func handleTouches(_ touches: Set<UITouch>) {
        for touch in touches {
            lastTouch = touch.location(in: self)
        }
    }
}

//MARK: - 物理碰撞代理
extension GameScene: SKPhysicsContactDelegate {
    
    // 当两个物理体彼此接触时调用
    func didBegin(_ contact: SKPhysicsContact) {
        
        // 1. 为两个物理体创建本地变量
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // 2. 分配两个物理体，以便于较低类别的那个总是存储在firstBody中
        //    因为我们之前设置玩家的 类别 最小
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 3. 对两个节点之间的接触作出反应
        if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask &&
            secondBody.categoryBitMask == zombies[0].physicsBody?.categoryBitMask {
            // 如果第一个是palyer 第二个是僵尸，那么 就是 玩家和僵尸发生了碰撞
            // 结束游戏
            gameOver(false);
        } else if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask &&
            secondBody.categoryBitMask == goal?.physicsBody?.categoryBitMask {
            // Player & Goal
            gameOver(true)
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
    }
}

// MARK: 帮助函数
extension GameScene {
    private func gameOver(_ didWin: Bool) {
        
        print("- - - 游戏结束 - - -")
        
        let menuScene = MenuScene(size: self.size)
        menuScene.soundToPlay = didWin ? "fear_win.mp3" : "fear_lose.mp3"
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        self.scene?.view?.presentScene(menuScene, transition: transition)
    }
}
