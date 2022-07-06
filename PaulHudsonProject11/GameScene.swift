//
//  GameScene.swift
//  PaulHudsonProject11
//
//  Created by Valerii D on 06.07.2022.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    var editingLabel: SKLabelNode!
 
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editingLabel.text = "Done"
            } else {
                editingLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.blendMode = .replace
        background.zPosition = -1                                                      // размещаем фон позади всех
        self.addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        self.addChild(scoreLabel)
        
        editingLabel = SKLabelNode(fontNamed: "Chalkduster")
        editingLabel.text = "Edit"
//        editingLabel.horizontalAlignmentMode = .right
        editingLabel.position = CGPoint(x: 80, y: 700)
        self.addChild(editingLabel)

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)                               // задаем физику тела по краям экрана
        physicsWorld.contactDelegate = self
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: self.size.width * 0.75, y: 0))
        makeBouncer(at: CGPoint(x: self.size.width / 2, y: 0))
        makeBouncer(at: CGPoint(x: self.size.width / 4, y: 0))
        makeBouncer(at: CGPoint(x: self.size.width, y: 0))
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
//        let box = SKSpriteNode(color: .red, size: CGSize(width: 64, height: 64))
//        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))   // задаем физику для объекта квадрат
//        box.position = location
//        self.addChild(box)
        
        let objects = nodes(at: location)
        
        if objects.contains(editingLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1),
                                                      green: CGFloat.random(in: 0...1),
                                                      blue: CGFloat.random(in: 0...1),
                                                      alpha: 1),
                                       size: CGSize(width: Int.random(in: 16...128), height: 16))
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                self.addChild(box)
            } else {
                let ball = SKSpriteNode(imageNamed: "ballRed")
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)           // задаем физику для объекта круг
                ball.physicsBody?.restitution = 0.4                                             //  уровень восстановления (отскока) 0,4, где значения от 0 до 1.
                ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                ball.position = location
                ball.name = "ball"
                self.addChild(ball)
            }
        }
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false                                         // устанавливаем будет ли объект двигаться соответственно физике или будет прикреплён к месту
        self.addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        self.addChild(slotBase)
        self.addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)           // создаем Экшен обращение
        let spinForever = SKAction.repeatForever(spin)                   // создаем Экшен на повторение
        slotGlow.run(spinForever)
    }
    
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        }
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            self.addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {                         // метод вызывается когда объекты соприкасаются первый раз
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
    }
}
