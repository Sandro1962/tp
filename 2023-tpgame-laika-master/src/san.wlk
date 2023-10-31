import wollok.game.*

object juego2 {
	
	method iniciar() {
		
		const width = 15
		const height = 15
		
        // CONFIG
		game.width(width)
		game.height(height)
		game.title("tankes")
		game.boardGround("fondo2.jpg")
	
        //	VISUALES
        game.addVisual(jugador)
        movimiento.configurarFlechas(jugador)
        

      	self.generarIvasores()
      	
      	
      	generadorEscenario.generar(width, height)
      	
      	
      	
      	
		game.start()
		
		
	}

	
	
	method generarIvasores() {
		game.onTick(2000,"aparece invasor",{new Enemigo().aparecer()}) 
	}
	
	
	method posicionAleatoria() = game.at(
		game.width().randomUpTo(1),
		game.height().randomUpTo(1)
	)
	
}



object jugador {
	var pos = game.at(1,1)
	var property image = "tanke.png"
	
	
	method position(pos1) { pos = pos1}
	method position() = pos
	
	
	
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



class Enemigo {
	var position = null
	
	
	
	method aparecer(){
		position = juego2.posicionAleatoria()
		game.addVisual(self)
		self.perseguir()
		//game.schedule(60000,{self.desaparecer()})	
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
	
	method position() = position
	method image() = "enemigo.png"
	
	//method desaparecer() {
	//	if(game.hasVisual(self)){
	//		game.removeVisual(self)
	//	    game.removeTickEvent("acercarse")
	//	}
	//}
	
		
	}
	


object creadorObstaculo {
    method cantidad() = 10
    method crear(pos) = new Obstaculo(position=pos)
}

class Obstaculo {
	var property position
	var property image = "obstaculo.png"
}

object generadorEscenario {
    const escenario = #{}

    const creadores = #{creadorObstaculo}

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







