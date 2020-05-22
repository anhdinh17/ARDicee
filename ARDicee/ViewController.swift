//
//  ViewController.swift
//  ARDicee
//
//  Created by Anh Dinh on 5/19/20.
//  Copyright © 2020 Anh Dinh. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // array to contain all the dice, dice is type SCNNode
    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // yellow dots
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //        // let Swift know that we want to create an AR of a cube
        //        // unit is meter, chamferRadius is how round you want the cornern to be
        //        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        //
        //        // give the cube some materials
        //        let material = SCNMaterial()
        //        material.diffuse.contents = UIColor.red // set the color
        //
        //        // add material to the cube, now the cube is red
        //        // the syntax is an array
        //        cube.materials = [material]
        //
        //        // Create a node
        //        // node is a point in 3D space, I think that's where the cube is placed based on your iphone screen.
        //        let node = SCNNode()
        //        node.position = SCNVector3(x: 0, y: 0, z: -0.5) //set position of the node, this is where the cube appears
        //
        //        // assign the cube to the node to display
        //        node.geometry = cube
        //
        //        // put node into sceneView, the cube appears in 3D.
        //        sceneView.scene.rootNode.addChildNode(node)
        
        // add some light to make the 3D more 3D
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        // important to use A9 chip for AR
        let configuration = ARWorldTrackingConfiguration()
        
        // let Swift know we are detecting horizontal plane
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - Delegate method to detect a touch
    // Delegate method to detect a touch from the View/Window, ie. when user touch the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // check if there's touch - if user touch
        if let touch = touches.first{
            // the location of the touch, in this case it's the sceneView(the screen) that user touch on the phone.
            let touchLocation = touch.location(in: sceneView)
            
            // our touchLocation is a 2D point because we touch the screen, hitTest converts that point on the screen to a 3D coordinate based on the existing plane, in this case that's the plane we detected.
            // so the results is the location of the touch in 3D Coordinate, it's an array
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            // check if there's a hitTest comes back
            // results.first is the 3D location of the touch
            if let hitResult = results.first{
                
                // Now we apply process of creating a 3D dice
                // Create a new scene using the diceCollada.scn file
                // this is the model Dice we let Swift know that we want to create.
                let diceScene = SCNScene(named: "art.scnassets/diceCollada copy.scn")!
                
                // create node for dice
                // it goes and find the childNode with name "Dice", the rootNode in this case I think it's already there when we create the diceScene, the model dice is just the childNode that needs to be added to rootNode
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
                    
                    // position of the dice node
                    // worldTransform is a 4x4 matrix, the column 3 is the one containing the location
                    // tap into it and get the x,y,z location
                    diceNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        // because we use the postion of the plane so when the dice is created,
                        // its center is placed flushed with the plane that was detected.
                        // so we need to add half of its height so that the whole dice can be placed on the plane
                        y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        z: hitResult.worldTransform.columns.3.z
                    )
                    
                    // every time a diceNode is created, add it to array
                    diceArray.append(diceNode)
                                        
                    /*
                     we don't add the dice to diceNode because if you look at the diceNode in this case it's a SCNScene type because we use the syntax of importing the model from somewhere else.
                     For the case of creating a cube/sphere, the node is SCNNode type, so we add the object to the node.
                     */
                    
                    // add to sceneView
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    roll(dice: diceNode)
                }
            }
        }
    }
    
    //MARK: - Func to roll all dices
    func rollAll(){
        // check if array is not empty
        if !diceArray.isEmpty{
            for dice in diceArray{
                roll(dice: dice)
            }
        }
    }
    
    //MARK: - Func to roll 1 dice
    func roll(dice: SCNNode){
        // Create a random number showing how many times rotating 90 degree
        // no random for Y because imagine that the dice only rotates around x and z axis.
        let randomX = Float(arc4random_uniform(4) + 1)*(Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1)*(Float.pi/2)
        
        // runAction is to add an action to the list executed by the node, ie. we want the node to do more thing
        // rotateBy is to make the node rotate a degree aound the axes.
        // in this case, we want the x and z to rotate a randomX and randomZ angle(degree)
        dice.runAction(SCNAction.rotateBy(
            x: CGFloat(randomX),
            y: 0,
            z: CGFloat(randomZ),
            duration: 0.5))//duration is time interval for the rotation
    }
   
    //MARK: - rollAgain button
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    //MARK: - Shake the app
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty{
            for dice in diceArray{
                // remove the dice
                dice.removeFromParentNode()
            }
        }
    }
    
    //MARK: - Delegate method detecting horizontal plane
    // delegate func from ARSCNViewDelegate. Basically, it detects horizontal surface and gives it width and height which is the "anchor"
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // check if the anchor is type ARPlaneAnchor which is from the planeDectection.
        // ARPlaneAnchor is anchor that is just plane surface rather than any other 3D objects
        // the parameter "anchor" is type ARAnchor which is a broad category, that's why we have to check if it's ARPlaneAnchor to specify only the plane surface that we are working on
        if anchor is ARPlaneAnchor{
            // if anchor is type ARPlaneAnchor then cast it down to that type because the parameter anchor is type ARAnchor
            let planeAnchor = anchor as! ARPlaneAnchor
            
            // create a Scene Plane, just like we create a model of a box or a sphere that we use SCNBox or SCNSPhere
            // the ARPlaneAnchor has properties "width" and "height", we can use those
            // Pay attention to the "height", anchor plane is always 2-dimension, the height is z instead of y
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            // Create node for the plane
            let planeNode = SCNNode()
            // Set the position for the node
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            // this one is a little bit tricky
            // so when Swift create SCNPlane, on the 3D coordinate, it's a x-y plane, that's why we have the "height" in it, we have to rotate the plane to lie on the x-z coordinate
            // -Floate.pi/2 is rotate 90 degree clockwise, x = 1 means it rotates around x axis, the other two axis is 0.
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            // Material for the plane
            let gridMaterial = SCNMaterial()
            // Download and use the grid.png file so we can see the plane with the grid image
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            // add material to the plane
            plane.materials = [gridMaterial]
            
            // add plane to node
            planeNode.geometry = plane
            
            // add planeNode to rootNode, we can either use sceneView.scene.rootNode.addChildNode or
            // because the func has the parameter "node" which is doing the same thing, we can use it
            node.addChildNode(planeNode)
            
        }else{
            return
        }
    }
    
}
