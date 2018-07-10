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
    let zombieSpeed: CGFloat = 75.0  // 僵尸的移动速度
    
    var goal: SKSpriteNode?    //目标？？
    var player: SKSpriteNode?
    var zombies: [SKSpriteNode] = []
    
    // 最后点击的位置
    var lastTouch: CGPoint? = nil
    
    override func didMove(to view: SKView) {
        
        // 设置物理世界的 conctat 代理
        physicsWorld.contactDelegate = self
        
        // 设置初始化相机的位置
        updateCamera()
    }
    // MARK - 各种更新
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

    func updateZombies() {
        
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
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
    }
}
