import SceneKit
import UIKit

public class TerrainBuilder {
    public static let mapSize: Float = 400.0
    
    public static func buildIsland(in scene: SCNScene) {
        // 1. Ocean Water Plane
        let waterGeo = SCNPlane(width: CGFloat(mapSize * 2.5), height: CGFloat(mapSize * 2.5))
        waterGeo.cornerRadius = 0
        let waterMat = SCNMaterial()
        waterMat.diffuse.contents = UIColor(red: 0.05, green: 0.25, blue: 0.45, alpha: 0.85)
        waterMat.roughness.contents = 0.1
        waterMat.metalness.contents = 0.8
        waterGeo.materials = [waterMat]
        
        let waterNode = SCNNode(geometry: waterGeo)
        waterNode.eulerAngles.x = -.pi / 2
        waterNode.position = SCNVector3(0, -0.5, 0)
        scene.rootNode.addChildNode(waterNode)
        
        // 2. Main Ground Terrain
        let groundGeo = SCNBox(width: CGFloat(mapSize), height: 2.0, length: CGFloat(mapSize), chamferRadius: 0)
        let groundMat = SCNMaterial()
        groundMat.diffuse.contents = UIColor(red: 0.28, green: 0.45, blue: 0.22, alpha: 1.0) // Military Grass Green
        groundMat.roughness.contents = 0.8
        groundGeo.materials = [groundMat]
        
        let groundNode = SCNNode(geometry: groundGeo)
        groundNode.position = SCNVector3(0, -1.0, 0)
        groundNode.name = "Ground"
        
        // Physics for ground
        let groundShape = SCNPhysicsShape(geometry: groundGeo, options: nil)
        groundNode.physicsBody = SCNPhysicsBody(type: .static, shape: groundShape)
        groundNode.physicsBody?.categoryBitMask = 1
        scene.rootNode.addChildNode(groundNode)
        
        // 3. Sandy Shoreline Beach
        let sandGeo = SCNBox(width: CGFloat(mapSize + 20), height: 1.8, length: CGFloat(mapSize + 20), chamferRadius: 0)
        let sandMat = SCNMaterial()
        sandMat.diffuse.contents = UIColor(red: 0.78, green: 0.72, blue: 0.52, alpha: 1.0)
        sandGeo.materials = [sandMat]
        let sandNode = SCNNode(geometry: sandGeo)
        sandNode.position = SCNVector3(0, -1.1, 0)
        scene.rootNode.addChildNode(sandNode)
        
        // 4. Populate 3D Buildings & Towns
        spawnTown(name: "Pochinki Outpost", center: SCNVector3(-60, 0, -60), in: scene)
        spawnTown(name: "Military Base", center: SCNVector3(80, 0, 70), in: scene)
        spawnTown(name: "Docklands", center: SCNVector3(-90, 0, 80), in: scene)
        spawnTown(name: "Sniper Ridge", center: SCNVector3(60, 0, -80), in: scene)
        
        // 5. Populate Pine Trees & Rocks across the island
        spawnFoliage(in: scene)
    }
    
    private static func spawnTown(name: String, center: SCNVector3, in scene: SCNScene) {
        let offsets: [(Float, Float)] = [(-15, -15), (15, -15), (-15, 15), (15, 15), (0, 0)]
        for (dx, dz) in offsets {
            let pos = SCNVector3(center.x + dx, 0, center.z + dz)
            let house = createHouse()
            house.position = pos
            scene.rootNode.addChildNode(house)
        }
        
        // Watchtower in town center
        let tower = createWatchtower()
        tower.position = SCNVector3(center.x + 25, 0, center.z)
        scene.rootNode.addChildNode(tower)
    }
    
    public static func createHouse() -> SCNNode {
        let houseNode = SCNNode()
        houseNode.name = "Building"
        
        // Walls
        let wallGeo = SCNBox(width: 8.0, height: 4.5, length: 10.0, chamferRadius: 0)
        let wallMat = SCNMaterial()
        wallMat.diffuse.contents = UIColor(red: 0.65, green: 0.62, blue: 0.58, alpha: 1.0)
        wallGeo.materials = [wallMat]
        
        let wallNode = SCNNode(geometry: wallGeo)
        wallNode.position = SCNVector3(0, 2.25, 0)
        wallNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: wallGeo, options: nil))
        wallNode.physicsBody?.categoryBitMask = 2
        houseNode.addChildNode(wallNode)
        
        // Pitched Roof
        let roofGeo = SCNPyramid(width: 9.0, height: 2.5, length: 11.0)
        let roofMat = SCNMaterial()
        roofMat.diffuse.contents = UIColor(red: 0.55, green: 0.22, blue: 0.18, alpha: 1.0) // Red tile
        roofGeo.materials = [roofMat]
        let roofNode = SCNNode(geometry: roofGeo)
        roofNode.position = SCNVector3(0, 4.5, 0)
        houseNode.addChildNode(roofNode)
        
        return houseNode
    }
    
    public static func createWatchtower() -> SCNNode {
        let towerNode = SCNNode()
        towerNode.name = "Watchtower"
        
        // 4 Legs
        let legPositions: [(Float, Float)] = [(-2, -2), (2, -2), (-2, 2), (2, 2)]
        for (lx, lz) in legPositions {
            let legGeo = SCNCylinder(radius: 0.2, height: 9.0)
            let legMat = SCNMaterial()
            legMat.diffuse.contents = UIColor.darkGray
            legGeo.materials = [legMat]
            let legNode = SCNNode(geometry: legGeo)
            legNode.position = SCNVector3(lx, 4.5, lz)
            towerNode.addChildNode(legNode)
        }
        
        // Platform
        let platGeo = SCNBox(width: 5.5, height: 0.4, length: 5.5, chamferRadius: 0)
        let platMat = SCNMaterial()
        platMat.diffuse.contents = UIColor.brown
        platGeo.materials = [platMat]
        let platNode = SCNNode(geometry: platGeo)
        platNode.position = SCNVector3(0, 9.0, 0)
        platNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: platGeo, options: nil))
        towerNode.addChildNode(platNode)
        
        return towerNode
    }
    
    private static func spawnFoliage(in scene: SCNScene) {
        for _ in 0..<120 {
            let x = Float.random(in: -160...160)
            let z = Float.random(in: -160...160)
            
            // Random Tree
            let tree = createPineTree()
            tree.position = SCNVector3(x, 0, z)
            scene.rootNode.addChildNode(tree)
        }
        
        for _ in 0..<60 {
            let x = Float.random(in: -170...170)
            let z = Float.random(in: -170...170)
            
            // Random Boulder
            let rock = createRock()
            rock.position = SCNVector3(x, 0, z)
            scene.rootNode.addChildNode(rock)
        }
    }
    
    public static func createPineTree() -> SCNNode {
        let treeNode = SCNNode()
        treeNode.name = "Tree"
        
        // Trunk
        let trunkGeo = SCNCylinder(radius: 0.35, height: 3.5)
        let trunkMat = SCNMaterial()
        trunkMat.diffuse.contents = UIColor(red: 0.35, green: 0.22, blue: 0.12, alpha: 1.0)
        trunkGeo.materials = [trunkMat]
        let trunkNode = SCNNode(geometry: trunkGeo)
        trunkNode.position = SCNVector3(0, 1.75, 0)
        trunkNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: trunkGeo, options: nil))
        trunkNode.physicsBody?.categoryBitMask = 2
        treeNode.addChildNode(trunkNode)
        
        // Foliage Cones
        let foliageColors = [
            UIColor(red: 0.12, green: 0.36, blue: 0.18, alpha: 1.0),
            UIColor(red: 0.15, green: 0.42, blue: 0.22, alpha: 1.0),
            UIColor(red: 0.18, green: 0.48, blue: 0.25, alpha: 1.0)
        ]
        
        for i in 0..<3 {
            let coneGeo = SCNCone(topRadius: 0, bottomRadius: CGFloat(2.2 - Float(i) * 0.4), height: 2.2)
            let coneMat = SCNMaterial()
            coneMat.diffuse.contents = foliageColors[i]
            coneGeo.materials = [coneMat]
            let coneNode = SCNNode(geometry: coneGeo)
            coneNode.position = SCNVector3(0, 3.2 + Float(i) * 1.3, 0)
            treeNode.addChildNode(coneNode)
        }
        
        return treeNode
    }
    
    public static func createRock() -> SCNNode {
        let scale = Float.random(in: 1.2...2.5)
        let rockGeo = SCNBox(width: CGFloat(scale * 1.5), height: CGFloat(scale), length: CGFloat(scale * 1.2), chamferRadius: CGFloat(scale * 0.3))
        let rockMat = SCNMaterial()
        rockMat.diffuse.contents = UIColor(white: 0.45, alpha: 1.0)
        rockMat.roughness.contents = 0.9
        rockGeo.materials = [rockMat]
        
        let rockNode = SCNNode(geometry: rockGeo)
        rockNode.position = SCNVector3(0, scale * 0.4, 0)
        rockNode.eulerAngles = SCNVector3(Float.random(in: 0...0.5), Float.random(in: 0...3.14), Float.random(in: 0...0.5))
        rockNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: rockGeo, options: nil))
        rockNode.physicsBody?.categoryBitMask = 2
        rockNode.name = "Rock"
        return rockNode
    }
}
