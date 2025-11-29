import Raylib

struct Game {
    var player: Player
    var bullets: [Bullet] = []
    let world_height: Float = 500
    let initial_player_position = Vector2(x: 400,y: 200)
    var score = 0
    var is_gaming = true
    let score_time: Float = 0.20
    var tick_time: Float = 0
    
    mutating func handle_movement() {
        player.handle_movement()
    }
    
    
    mutating func tick() {

        if !is_gaming {
            return
        }
        for i in bullets.indices {
            bullets[i].move()
        }
        
        spawnBullet()
        bullets.removeAll { $0.position.y > world_height }
        
        if playerCollided() {
            player.lives -= 1
            player.position = initial_player_position
            bullets = []
            if player.lives == 0 {
                is_gaming = false
                return
            }
        }
        tick_time += Raylib.getFrameTime()
        if tick_time > score_time {
            score += 10
            tick_time = 0
        }
    }
    
    mutating func spawnBullet() {
        let random = Float.random(in: 0...1)
        if random < 0.4 {
            let x = Float.random(in: 0...800)
            let speed_modifier = Float.random(in: -50...100)
            var bullet = Bullet(position: Vector2(x: x, y: -10))
            bullet.falling_speed += speed_modifier
            bullets.append(bullet)
        }
    }
    
    func playerCollided() -> Bool {
        for bullet in bullets {
            let distance = player.position.distance(bullet.position)
            if distance < (player.radius + bullet.radius) {
                return true
            }
        }
        return false
    }
    
    func render() {
        if is_gaming {
            player.render()
        } else {
            Raylib.drawText("Game Over!", 400, 400, 25, .darkGray)
        }
        
        for bullet in bullets {
            bullet.render()
        }
        Raylib.drawText("Score: \(score)", 400, 0, 25, .darkGray)
    }
    
    init() {
         player = Player(position: initial_player_position)
    }
}

struct Player {
    var position: Vector2
    var lives: Int8 = 3
    
    let movement_speed: Float = 250
    let slow_speed: Float = 150
    let radius: Float = 10
    
    func render() {
        Raylib.drawCircleV(position, radius, Color.red)
    }
    
    mutating func handle_movement() {
        let delta = Raylib.getFrameTime()
        var speed = movement_speed
        if Raylib.isKeyDown(.leftShift) {
            speed = slow_speed
        }
        if Raylib.isKeyDown(.letterD) || Raylib.isKeyDown(.right) {
            let direction = Vector2(x: speed * delta, y: 0.0)
            self.move(by: direction)
        }
        if Raylib.isKeyDown(.letterA) || Raylib.isKeyDown(.left) {
            let direction = Vector2(x: -speed * delta, y: 0.0)
            self.move(by: direction)
        }
        if Raylib.isKeyDown(.letterS) || Raylib.isKeyDown(.down) {
            let direction = Vector2(x: 0.0, y: speed * delta)
            self.move(by: direction)
        }
        if Raylib.isKeyDown(.letterW) || Raylib.isKeyDown(.up) {
            let direction = Vector2(x: 0.0, y: -speed * delta)
            self.move(by: direction)
        }
    }
    
    mutating func move(by direction: Vector2) {
        self.position = self.position + direction
    }
}

struct Bullet {
    var position: Vector2
    
    var falling_speed: Float = 100
    let radius: Float = 4
    
    func render() {
        Raylib.drawCircleV(position, radius, Color.blue)
    }
    
    mutating func move() {
        self.position.y += falling_speed * Raylib.getFrameTime()
    }
}

@main
struct SwiftGameApp {
    static func main() {
        let screenWidth: Int32 = 800
        let screenHeight: Int32 = 450
        
        var game = Game()

        Raylib.initWindow(screenWidth, screenHeight, "MyGame")
        Raylib.setTargetFPS(60)
        
        while Raylib.windowShouldClose == false {
            // update
            game.handle_movement()
            game.tick()
            
            // draw
            Raylib.beginDrawing()
            Raylib.clearBackground(.rayWhite)

            game.render()
            
            Raylib.drawFPS(10, 10)
            Raylib.endDrawing()
        }
        Raylib.closeWindow()
    }
}

