import wollok.game.*

object juego {
	
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
method explosion(pos) {
		const expl = new Explosion(pos = pos)
		game.addVisual(expl)
		game.schedule(100, {expl.proximoFrame()})
		game.schedule(200, {expl.proximoFrame()})
		game.schedule(300, {game.removeVisual(expl)})
	}
	
	
	method generarIvasores() {
		game.onTick(2000,"aparece invasor",{new Enemigo().aparecer()}) 
	}
	
	
	method posicionAleatoria() = game.at(
		game.width().randomUpTo(1),
		game.height().randomUpTo(1)
	)
	
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
                explosionY = pos.y() + 3
            } else if (image == "tankeabajo.png") {
                explosionX = pos.x()
                explosionY = pos.y() - 3
            } else if (image == "tankeizquierda.png") {
                explosionX = pos.x() - 3
                explosionY = pos.y()
            } else {
                explosionX = pos.x() + 3
                explosionY = pos.y()
            }
		juego.explosion(game.at(explosionX, explosionY))
		
	}
	
}






object movimiento {
	method configurarFlechas(jugador){
		keyboard.up().onPressDo{ self.mover(arriba,jugador)}
		keyboard.down().onPressDo{ self.mover(abajo,jugador)}
		keyboard.left().onPressDo{ self.mover(izquierda,jugador)}
		keyboard.right().onPressDo{ self.mover(derecha,jugador)}
		keyboard.space().onPressDo{jugador.disparar()}
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
		position = juego.posicionAleatoria()
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
    
/*    

object disparo{
	method configurarDisparo(jugador){
		keyboard.space().onPressDo{self.disparar(jugador)}
	
	}
	
	method direccionDisparo() {
		var direccionD  
        if (jugador.image() == "tankearriba.png") {
            direccionD = disparoArriba
        } else if (jugador.image() == "tankeabajo.png") {
            direccionD = disparoAbajo
        } else if (jugador.image() == "tankeizquierda.png") {
            direccionD = disparoIzquierda
        } else {
            direccionD = disparoDerecha
        }

        return direccionD
			
	}
	
	
	method direccionDisparo() {
        const direcciones = #{ 
            "tankearriba.png" -> disparoArriba,
            "tankeabajo.png" -> disparoAbajo,
            "tankeizquierda.png" -> disparoIzquierda,
            "tanke.png" -> disparoDerecha
        }
		const direccion = direcciones[jugador.image()]
        return direccion
    }


	//arreglar	
	method disparar(jugador) {
    const posicionDisparo = self.direccionDisparo().posicion(jugador)
    const posicionX = posicionDisparo[0].toInt()
    const posicionY = posicionDisparo[1].toInt()
	   
    batallaDeTanques.explosion(game.at(posicionX, posicionY))
           
	}
}


object disparoIzquierda{   
    method posicion(jugador){ 
    	return [jugador.position().x()-1 ,jugador.position().y()]
    } 
	
}

object disparoDerecha{
	method posicion(jugador) {
		return [jugador.position().x()+1,jugador.position().y()]
	}
}

object disparoArriba{
	method posicion(jugador){
		return [jugador.position().x(),jugador.position().y()+1]
	}
}

object disparoAbajo{
	method posicion(jugador){
		return [jugador.position().x(), jugador.position().y()-1]
	} 
}
*/



