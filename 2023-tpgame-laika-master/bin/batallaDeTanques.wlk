import wollok.game.*

object batallaDeTanques {
const width = 10
	const height = 10
	method iniciar() {
        // CONFIG
		game.width(width)
		game.height(height)
		game.title("tankes")
		game.boardGround("fondo.jpg")

        //	VISUALES
        game.addVisual(jugador)
        movimiento.configurarFlechas(jugador)

        generadorEscenario.generar(width, height)
		
		
		self.perseguir()
		game.start()
	}

	method explosion(pos) {
		const expl = new Explosion(pos = pos)
		game.addVisual(expl)
		game.schedule(100, {expl.proximoFrame()})
		game.schedule(200, {expl.proximoFrame()})
		game.schedule(300, {game.removeVisual(expl)})
	}
	
	 method perseguir(){}

	
}



class TanqueEnemigo {
    var property position
    var property image = "enemigo.png"

    method detectarJugador() {
       
    }
    method moverseHaciaJugador() {
        
    }
    
    
    method perseguir(){
		game.onTick(300,"acercarse",{self.avanzar(jugador.position())})
	}
	
	method avanzar(destino){
		position = game.at(
			position.x() + (destino.x()-position.x())/game.width(),
			position.y() + (destino.y()- position.y())/game.height()
		)
	}
    
    
    
    method esquivarObstaculos() {
        
    }

    method disparar() {
        
    }
}






object generadorEscenario {
    const escenario = #{}

    const creadores = #{creadorEnemigo, creadorObstaculo}

    method crearObjetoEnEspacioVacio(creador, alto, ancho) {
        const obj = creador.crear(game.at(0.randomUpTo(ancho - 1), 0.randomUpTo(alto - 1)))
        game.addVisual(obj)

        if (game.colliders(obj).isEmpty()) {
        	
            return obj
        }

        game.removeVisual(obj)
        return self.crearObjetoEnEspacioVacio(creador, alto, ancho)
    }

    method crearObjetos(creador, ancho, alto) {
        creador.cantidad().times{ _ =>
            const obj = self.crearObjetoEnEspacioVacio(creador, ancho, alto)
            escenario.add(obj)
        }
    }

    method generar(ancho, alto) {
        creadores.forEach{
            creador => self.crearObjetos(creador, ancho, alto)
        }
    }

    method destruir() {
        escenario.forEach{ obj => game.removeVisual(obj) }
    }
}


object creadorEnemigo {
    method cantidad() = 5
    method crear(pos) = new TanqueEnemigo(position=pos)
}

object creadorObstaculo {
    method cantidad() = 10
    method crear(pos) = new Obstaculo(position=pos)
}




class Obstaculo {
	var property position
	var property image = "obstaculo.png"
}

object movimiento {
	method configurarFlechas(jugador){
		keyboard.up().onPressDo{ self.mover(arriba,jugador)}
		keyboard.down().onPressDo{ self.mover(abajo,jugador)}
		keyboard.left().onPressDo{ self.mover(izquierda,jugador)}
		keyboard.right().onPressDo{ self.mover(derecha,jugador)}
    }

    method mover(direccion,jugador){
		jugador.position(direccion.siguiente(jugador.position()))
		jugador.image(direccion.image())
	}
}

object izquierda { 
    var property image = "tankeizquierda.png"
    method siguiente(position) = position.left(1) 
}

object derecha { 
	var property image = "tanke.png"
	method siguiente(position) = position.right(1) 
}

object abajo { 
	var property image = "tankeabajo.png"
	method siguiente(position) = position.down(1) 
}

object arriba { 
	var property image = "tankearriba.png"
	method siguiente(position) = position.up(1) 
}














class Explosion {
	var frame = 1
	var pos
	method image() = "explosion" + frame + ".png"
	method position() = pos
	method proximoFrame() { frame += 1 }
}

object jugador {
	var pos = game.at(1,1)
	var property image = "tanke.png"
	
	method position(pos1) { pos = pos1}
	method position() = pos
	
	method disparar(){
			
		var explosionX
        var explosionY

            // dispara a X lugar dependiendo hacia donde mira el tanque
            if (image == "tankearriba.png") {
                explosionX = pos.x()
                explosionY = pos.y() + 1
            } else if (image == "tankeabajo.png") {
                explosionX = pos.x()
                explosionY = pos.y() - 1
            } else if (image == "tankeizquierda.png") {
                explosionX = pos.x() - 1
                explosionY = pos.y()
            } else {
                explosionX = pos.x() + 1
                explosionY = pos.y()
            }
		batallaDeTanques.explosion(game.at(explosionX, explosionY))
		
	}
	
	
}
