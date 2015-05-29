//
//  GameScene.swift
//  TicTacToeSpriteKit
//
//  Created by Ozan Üst on 5/20/15.
//  Copyright (c) 2015 Xenium. All rights reserved.
//

import SpriteKit
import UIKit

class GameScene: SKScene {
    
    var emptyBox1 = SKSpriteNode(imageNamed: "emptyBox.jpg")
    var emptyBox2 = SKSpriteNode(imageNamed: "emptyBox.jpg")
    var emptyBox3 = SKSpriteNode(imageNamed: "emptyBox.jpg")
    var emptyBox4 = SKSpriteNode(imageNamed: "emptyBox.jpg")
    var emptyBox5 = SKSpriteNode(imageNamed: "emptyBox.jpg")
    var emptyBox6 = SKSpriteNode(imageNamed: "emptyBox.jpg")
    var emptyBox7 = SKSpriteNode(imageNamed: "emptyBox.jpg")
    var emptyBox8 = SKSpriteNode(imageNamed: "emptyBox.jpg")
    var emptyBox9 = SKSpriteNode(imageNamed: "emptyBox.jpg")
    
    var emptyBoxes: [SKSpriteNode]!
    var xPositions: [CGFloat]!
    var yPositions: [CGFloat]!
    var fillTexture: SKTexture!
    var emptyTexture = SKTexture(imageNamed: "emptyBox.jpg")
    var label = SKLabelNode(text: "Nought Turn")
    var restartLabel = SKLabelNode(text: "Click to Restart")
    var restartButton = SKSpriteNode(imageNamed: "button.png")
    
    var cross = 1
    var nought = 2
    var tags = [0,0,0,0,0,0,0,0,0]
    var winningCombinations = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
    var unsignedBoxes = [0]
    var winner = 0
    var aiTurn: Int!
    var aiSigned: Bool = false
    var firstMove: Bool = false
    var preferWin: Bool = true
    var toWinTurn: Bool = false
    var nextTurnAI: Bool = false
    var toWin = 0
    var toWinComb = []
    
    var turn = 1
    var signedBoxes = 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        let grid = SKSpriteNode(imageNamed: "grid.jpeg")
        grid.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(grid)
        
        xPositions = [412, 512, 612, 412, 512, 612, 412, 512, 612]
        yPositions = [484, 484, 484, 384, 384, 384, 284, 284, 284]
        emptyBoxes = [emptyBox1, emptyBox2, emptyBox3, emptyBox4, emptyBox5, emptyBox6, emptyBox7, emptyBox8, emptyBox9]
        
        label.position.x = 512
        label.position.y = 184
        label.fontColor = UIColor.blackColor()
        self.addChild(label)
        
        restartLabel.position.x = 512
        restartLabel.position.y = 130
        restartLabel.fontColor = UIColor.blackColor()
        self.addChild(restartLabel)
        restartLabel.hidden = true
        
        restartButton.position.x = 512
        restartButton.position.y = 60
        restartButton.xScale = 0.5
        restartButton.yScale = 0.5
        self.addChild(restartButton)
        restartButton.hidden = true
        
        for (var i = 0; i < 9; i++){
            emptyBoxes[i].name = "Unattached"
            emptyBoxes[i].xScale = 0.95
            emptyBoxes[i].yScale = 0.95
            emptyBoxes[i].position.x = xPositions[i]
            emptyBoxes[i].position.y = yPositions[i]
            self.addChild(emptyBoxes[i])
        }
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            
            if (turn % 2 == 0 && winner == 0){
                fillTexture = SKTexture(imageNamed: "nought.png")
                label.text = "Cross Turn"
            } else if(turn % 2 != 0 && winner == 0){
                fillTexture = SKTexture(imageNamed: "cross.png")
                label.text = "Nought Turn"
            }
            
            for(var i = 0; i < 9; i++){
                if (emptyBoxes[i].containsPoint(location) && emptyBoxes[i].name != "Attached"){
                    emptyBoxes[i].texture = SKTexture(imageNamed: "nought.png")
                    emptyBoxes[i].name = "Attached"
                    aiSigned = false
                    signedBoxes++
                    turn++
                    tags[i] = nought
                    println(tags)
                    /*if (turn % 2 == 0){
                    tags[i] = nought
                    } else {
                    tags[i] = cross
                    }*/
                }
            }
            
            controllingWinner()
            endGameControllers()
            
            if(restartButton.containsPoint(location)){
                for(var i = 0; i < 9; i++){
                    emptyBoxes[i].texture = emptyTexture
                    emptyBoxes[i].name = "Unattached"
                    tags[i] = 0
                }
                label.text = ""
                winner = 0
                signedBoxes = 0
                restartLabel.hidden = true
                restartButton.hidden = true
                aiSigned = false
                if (turn % 2 == 0){
                    turn = 1
                } else if (turn % 2 == 1 && turn == 9){
                    turn = 2
                    nextTurnAI = true
                }
                firstMove = false
                toWinTurn = false
                unsignedBoxes.removeAll()
                unsignedBoxes.append(0)
            }
            
            
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        if (turn % 2 == 0){
            while (aiSigned == false && signedBoxes != 9 && winner == 0){
                
                for combination in winningCombinations{
                    
                    println(combination)
                    
                    if (nextTurnAI == true && turn == 2){
                        aiTurn = Int(arc4random_uniform(9))
                        emptyBoxes[aiTurn].texture = SKTexture(imageNamed: "cross.png")
                        tags[aiTurn] = cross
                        emptyBoxes[aiTurn].name = "Attached"
                        aiSigned = true
                        signedBoxes++
                        turn++
                        break
                    }
                    if (tags[combination[0]] == tags[combination[1]] && tags[combination[1]] == cross && emptyBoxes[combination[2]].name != "Attached") {
                        
                        tags[combination[2]] = cross
                        emptyBoxes[combination[2]].texture = SKTexture(imageNamed: "cross.png")
                        aiSigned = true
                        turn++
                        signedBoxes++
                        emptyBoxes[combination[2]].name = "Attached"
                        println("workedtodo1")
                        break
                        
                    }else if (tags[combination[0]] == tags[combination[2]] && tags[combination[2]] == cross && emptyBoxes[combination[1]].name != "Attached") {
                        
                        tags[combination[1]] = cross
                        emptyBoxes[combination[1]].texture = SKTexture(imageNamed: "cross.png")
                        aiSigned = true
                        turn++
                        signedBoxes++
                        emptyBoxes[combination[1]].name = "Attached"
                        println("workedtodo2")
                        break
                        
                    }else if (tags[combination[1]] == tags[combination[2]] && tags[combination[1]] == cross && emptyBoxes[combination[0]].name != "Attached") {
                        
                        tags[combination[0]] = cross
                        emptyBoxes[combination[0]].texture = SKTexture(imageNamed: "cross.png")
                        aiSigned = true
                        turn++
                        signedBoxes++
                        emptyBoxes[combination[0]].name = "Attached"
                        println("workedtodo3")
                        break
                        
                    }else if (tags[combination[0]] == tags[combination[1]] && tags[combination[1]] == nought && emptyBoxes[combination[2]].name != "Attached") {
                        
                        tags[combination[2]] = cross
                        emptyBoxes[combination[2]].texture = SKTexture(imageNamed: "cross.png")
                        aiSigned = true
                        turn++
                        signedBoxes++
                        emptyBoxes[combination[2]].name = "Attached"
                        println("workedprevent1")
                        break
                        
                    }else if (tags[combination[0]] == tags[combination[2]] && tags[combination[0]] == nought && emptyBoxes[combination[1]].name != "Attached") {
                        
                        tags[combination[1]] = cross
                        emptyBoxes[combination[1]].texture = SKTexture(imageNamed: "cross.png")
                        aiSigned = true
                        turn++
                        signedBoxes++
                        emptyBoxes[combination[1]].name = "Attached"
                        println("workedprevent2")
                        break
                        
                    }else if (tags[combination[1]] == tags[combination[2]] && tags[combination[1]] == nought && emptyBoxes[combination[0]].name != "Attached") {
                        
                        tags[combination[0]] = cross
                        emptyBoxes[combination[0]].texture = SKTexture(imageNamed: "cross.png")
                        aiSigned = true
                        turn++
                        signedBoxes++
                        emptyBoxes[combination[0]].name = "Attached"
                        println("workedprevent3")
                        break
                        
                    }else if (tags[combination[1]] != tags[combination[2]] && tags[combination[1]] == nought && emptyBoxes[combination[0]].name != "Attached" && turn <= 2) {
                        
                        tags[combination[0]] = cross
                        emptyBoxes[combination[0]].texture = SKTexture(imageNamed: "cross.png")
                        aiSigned = true
                        turn++
                        signedBoxes++
                        emptyBoxes[combination[0]].name = "Attached"
                        println("workednear")
                        break
                        
                    }else if (tags[combination[0]] != tags[combination[1]] && tags[combination[1]] == nought && emptyBoxes[combination[2]].name != "Attached" && turn <= 2) {
                        
                        tags[combination[2]] = cross
                        emptyBoxes[combination[2]].texture = SKTexture(imageNamed: "cross.png")
                        aiSigned = true
                        turn++
                        signedBoxes++
                        emptyBoxes[combination[2]].name = "Attached"
                        println("workednear2")
                        break
                        
                    }else if (tags[combination[0]] != tags[combination[2]] && tags[combination[0]] == nought && emptyBoxes[combination[1]].name != "Attached" && turn <= 2) {
                        
                        tags[combination[1]] = cross
                        emptyBoxes[combination[1]].texture = SKTexture(imageNamed: "cross.png")
                        aiSigned = true
                        turn++
                        signedBoxes++
                        emptyBoxes[combination[1]].name = "Attached"
                        println("workednear3")
                        break
                        
                    }else if (tags[combination[0]] == tags[combination[2]] && tags[combination[0]] == nought && emptyBoxes[combination[1]].name == "Attached" && toWinTurn == false) {
                        toWin = combination[1]
                        toWinComb = combination
                        toWinTurn = true
                        for combinationInside in winningCombinations{
                            if (combinationInside != toWinComb && combinationInside[0] == toWin && emptyBoxes[combinationInside[1]].name != "Attached"){
                                emptyBoxes[combinationInside[1]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[1]] = cross
                                emptyBoxes[combinationInside[1]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }else if (combinationInside != toWinComb && combinationInside[1] == toWin && emptyBoxes[combinationInside[2]].name != "Attached"){
                                emptyBoxes[combinationInside[2]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[2]] = cross
                                emptyBoxes[combinationInside[2]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }else if (combinationInside != toWinComb && combinationInside[2] == toWin && emptyBoxes[combinationInside[1]].name != "Attached"){
                                emptyBoxes[combinationInside[1]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[1]] = cross
                                emptyBoxes[combinationInside[1]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }
                        }
                        break
                        
                    }else if (tags[combination[0]] == nought && tags[combination[1]] == cross && nextTurnAI == true) {
                        
                        toWin = combination[1]
                        toWinComb = combination
                        nextTurnAI = false
                        
                        for combinationInside in winningCombinations{
                            if (combinationInside != toWinComb && combinationInside[0] == toWin && emptyBoxes[combinationInside[1]].name != "Attached"){
                                emptyBoxes[combinationInside[1]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[1]] = cross
                                emptyBoxes[combinationInside[1]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }else if (combinationInside != toWinComb && combinationInside[1] == toWin && emptyBoxes[combinationInside[2]].name != "Attached"){
                                emptyBoxes[combinationInside[2]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[2]] = cross
                                emptyBoxes[combinationInside[2]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }else if (combinationInside != toWinComb && combinationInside[2] == toWin && emptyBoxes[combinationInside[1]].name != "Attached"){
                                emptyBoxes[combinationInside[1]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[1]] = cross
                                emptyBoxes[combinationInside[1]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }
                        }
                        
                        break
                    }else if (tags[combination[0]] == nought && tags[combination[2]] == cross && nextTurnAI == true) {
                        
                        toWin = combination[1]
                        toWinComb = combination
                        nextTurnAI = false
                        
                        for combinationInside in winningCombinations{
                            if (combinationInside != toWinComb && combinationInside[0] == toWin && emptyBoxes[combinationInside[1]].name != "Attached"){
                                emptyBoxes[combinationInside[1]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[1]] = cross
                                emptyBoxes[combinationInside[1]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }else if (combinationInside != toWinComb && combinationInside[1] == toWin && emptyBoxes[combinationInside[2]].name != "Attached"){
                                emptyBoxes[combinationInside[2]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[2]] = cross
                                emptyBoxes[combinationInside[2]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }else if (combinationInside != toWinComb && combinationInside[2] == toWin && emptyBoxes[combinationInside[1]].name != "Attached"){
                                emptyBoxes[combinationInside[1]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[1]] = cross
                                emptyBoxes[combinationInside[1]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }
                        }
                        
                        break
                    }else if (tags[combination[1]] == nought && tags[combination[2]] == cross && nextTurnAI == true) {
                        
                        toWin = combination[1]
                        toWinComb = combination
                        nextTurnAI = false
                        
                        for combinationInside in winningCombinations{
                            if (combinationInside != toWinComb && combinationInside[0] == toWin && emptyBoxes[combinationInside[1]].name != "Attached"){
                                emptyBoxes[combinationInside[1]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[1]] = cross
                                emptyBoxes[combinationInside[1]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }else if (combinationInside != toWinComb && combinationInside[1] == toWin && emptyBoxes[combinationInside[2]].name != "Attached"){
                                emptyBoxes[combinationInside[2]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[2]] = cross
                                emptyBoxes[combinationInside[2]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }else if (combinationInside != toWinComb && combinationInside[2] == toWin && emptyBoxes[combinationInside[1]].name != "Attached"){
                                emptyBoxes[combinationInside[1]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[1]] = cross
                                emptyBoxes[combinationInside[1]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }
                        }
                        
                        break
                    }else if (tags[combination[0]] == cross && tags[combination[1]] == nought && nextTurnAI == true) {
                        
                        toWin = combination[1]
                        toWinComb = combination
                        nextTurnAI = false
                        
                        for combinationInside in winningCombinations{
                            if (combinationInside != toWinComb && combinationInside[0] == toWin && emptyBoxes[combinationInside[1]].name != "Attached"){
                                emptyBoxes[combinationInside[1]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[1]] = cross
                                emptyBoxes[combinationInside[1]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }else if (combinationInside != toWinComb && combinationInside[1] == toWin && emptyBoxes[combinationInside[2]].name != "Attached"){
                                emptyBoxes[combinationInside[2]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[2]] = cross
                                emptyBoxes[combinationInside[2]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }else if (combinationInside != toWinComb && combinationInside[2] == toWin && emptyBoxes[combinationInside[1]].name != "Attached"){
                                emptyBoxes[combinationInside[1]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[1]] = cross
                                emptyBoxes[combinationInside[1]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }
                        }
                        
                        break
                    }else if (tags[combination[1]] == cross && tags[combination[2]] == nought && nextTurnAI == true) {
                        
                        toWin = combination[1]
                        toWinComb = combination
                        nextTurnAI = false
                        
                        for combinationInside in winningCombinations{
                            if (combinationInside != toWinComb && combinationInside[0] == toWin && emptyBoxes[combinationInside[1]].name != "Attached"){
                                emptyBoxes[combinationInside[1]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[1]] = cross
                                emptyBoxes[combinationInside[1]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }else if (combinationInside != toWinComb && combinationInside[1] == toWin && emptyBoxes[combinationInside[2]].name != "Attached"){
                                emptyBoxes[combinationInside[2]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[2]] = cross
                                emptyBoxes[combinationInside[2]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }else if (combinationInside != toWinComb && combinationInside[2] == toWin && emptyBoxes[combinationInside[1]].name != "Attached"){
                                emptyBoxes[combinationInside[1]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[1]] = cross
                                emptyBoxes[combinationInside[1]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }
                        }
                        
                        break
                    }else if (tags[combination[0]] == cross && tags[combination[2]] == nought && nextTurnAI == true) {
                        
                        toWin = combination[1]
                        toWinComb = combination
                        nextTurnAI = false
                        
                        for combinationInside in winningCombinations{
                            if (combinationInside != toWinComb && combinationInside[0] == toWin && emptyBoxes[combinationInside[1]].name != "Attached"){
                                emptyBoxes[combinationInside[1]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[1]] = cross
                                emptyBoxes[combinationInside[1]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }else if (combinationInside != toWinComb && combinationInside[1] == toWin && emptyBoxes[combinationInside[2]].name != "Attached"){
                                emptyBoxes[combinationInside[2]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[2]] = cross
                                emptyBoxes[combinationInside[2]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }else if (combinationInside != toWinComb && combinationInside[2] == toWin && emptyBoxes[combinationInside[1]].name != "Attached"){
                                emptyBoxes[combinationInside[1]].texture = SKTexture(imageNamed: "cross.png")
                                tags[combinationInside[1]] = cross
                                emptyBoxes[combinationInside[1]].name = "Attached"
                                aiSigned = true
                                signedBoxes++
                                turn++
                                break
                            }
                        }
                        
                        break
                    }else if (emptyBoxes[combination[0]].name == "Attached" && emptyBoxes[combination[1]].name == "Attached" && emptyBoxes[combination[2]].name == "Attached"){
                        
                        unsignedBoxes.removeAtIndex(0)
                        
                        for(var i = 0; i<9; i++){
                            if (tags[i] == 0){
                                unsignedBoxes.append(i)
                            }
                        }
                        aiTurn = Int(arc4random_uniform(UInt32(unsignedBoxes.count)))
                        var aiTurned = unsignedBoxes[aiTurn]
                        if(emptyBoxes[aiTurned].name != "Attached"){
                            emptyBoxes[aiTurned].texture = SKTexture(imageNamed: "cross.png")
                            tags[aiTurned] = cross
                            emptyBoxes[aiTurned].name = "Attached"
                            aiSigned = true
                            signedBoxes++
                            turn++
                        }
                        break
                    }
                }
                
                /*aiTurn = Int(arc4random_uniform(9))
                if(emptyBoxes[aiTurn].name != "Attached"){
                emptyBoxes[aiTurn].texture = SKTexture(imageNamed: "cross.png")
                tags[aiTurn] = cross
                emptyBoxes[aiTurn].name = "Attached"
                aiSigned = true
                signedBoxes++
                turn++
                }*/
                if(aiSigned == true){
                    controllingWinner()
                }
                endGameControllers()
            }
        }
        
        /* Called before each frame is rendered */
    }
    
    func controllingWinner(){
        if (winner == 0){
            for combination in winningCombinations{
                
                if (tags[combination[0]] == tags[combination[1]] && tags[combination[1]] == tags[combination[2]] && tags[combination[0]] != 0) {
                    
                    winner = tags[combination[0]]
                }
                
            }
        }
        
    }
    
    func endGameControllers(){
        if(winner == cross){
            label.text = "Cross wins!"
        }
        if(winner == nought){
            label.text = "Nought wins!"
        }
        if(winner != 0){
            restartLabel.hidden = false
            restartButton.hidden = false
        }
        if(signedBoxes == 9 && winner == 0){
            label.text = "Deuce!"
            restartLabel.hidden = false
            restartButton.hidden = false
        }
    }
}
