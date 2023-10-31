import wollok.game.*

object juego {
	
	method iniciar() {
		
		
        // CONFIG
        self.configurarVentana()
	
        //	VISUALES
        game.addVisual(jugador)
        movimiento.configurarFlechas(jugador)
        

      	self.generarIvasores()
      	
      	
      	generadorEscenario.generar(width, height)
      	
      	
      	
      	
		game.start()
		
	}
method configurarVentana(){
		const width = 15
		const height = 15
		game.width(width)
		game.height(height)
		game.title("tankes")
		game.boardGround("fondo2.jpg")
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
	
	method colition(){
		game.colli
	}
	
	
	
}

object jugador {
	var pos = game.at(1,1)
	var property image = "tanke.png"
	var property direction = derecha
	
	method position(pos1) { pos = pos1}
	method position() = pos
	
	method disparar(){
			direction.disparar(pos.x(), pos.y())
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
		jugador.direction(direccion)
		jugador.image(direccion.image())
	}
	
}

class Direccion{
	
	method disparar(x,y){
		juego.explosion(game.at(self.xDeExplosion(x), self.yDeExplosion(y)))		
	}
	
	method xDeExplosion(x){
		return x
	}
	
	method yDeExplosion(y){
		return y
	}
}

object izquierda inherits Direccion { 
    var property image = "tankeizquierda.png"
    method siguiente(position) = position.left(1) 
    
	override method xDeExplosion(x){
		return x - 3
	}
}

object derecha inherits Direccion { 
	var property image = "tanke.png"
	method siguiente(position) = position.right(1) 
	override method xDeExplosion(x){
		return x + 3
	}
}

object abajo inherits Direccion  { 
	var property image = "tankeabajo.png"
	method siguiente(position) = position.down(1) 
	override method yDeExplosion(y){
		return y - 3
	}
}

object arriba inherits Direccion  { 
	var property image = "tankearriba.png"
	method siguiente(position) = position.up(1) 
	override method yDeExplosion(y){
		return y + 3
	}
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
	
	method desaparecer() {
		if(game.hasVisual(self)){
			game.removeVisual(self)
		    game.removeTickEvent("acercarse")
		}
		
		
	}
	
		
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




//los condicionales para apuntar--
//
//
//
//
//
//que aparezca enemigos hasta tener mil puntos
//
//el maximo de enemigos sea
//
//3 colisiones:
//tanque -> obstáculo   los enemigos aparecen uno encima del otro y encima de un obstaculo--
//explosión -> tanque enemigo   la explosion no destruye al enemigo ni al obstculo
//tanque enemigo -> tanque
//
//usar algo de herencia -> crear un enemigo distinto que se aleja


   