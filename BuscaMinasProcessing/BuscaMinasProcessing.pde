int cols, filas; 
int w = 40; 
int totalMinas; 
Casilla[][] cuadricula; 
boolean juegoTerminado; 
boolean juegoGanado; 
int minasMarcadas; 
boolean mostrarMenu = true; 
String dificultadActual = "medio"; 
int alturaMenu = 40; 
int alturaMenuSuperior = 40; 

int tiempoInicio;
int tiempoFin; 
int tiempoTranscurrido; 

// Configuración inicial de la ventana de juego
void setup() {
  size(1000, 1200); 
}

// Función para iniciar el juego con la dificultad especificada
void iniciarJuego(String dificultad) {
  mostrarMenu = false; 
  // Configuración de las variables según la dificultad seleccionada
  if (dificultad.equals("fácil")) {
    cols = 10;
    filas = 10;
    totalMinas = 10;
  } else if (dificultad.equals("medio")) {
    cols = 20;
    filas = 20;
    totalMinas = 40;
  } else if (dificultad.equals("difícil")) {
    cols = 21;
    filas = 21;
    totalMinas = 99;
  }

  // Inicialización de la cuadrícula de casillas
  cuadricula = new Casilla[cols][filas];
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < filas; j++) {
      cuadricula[i][j] = new Casilla(i, j, w);
    }
  }

  // Colocación aleatoria de las minas en la cuadrícula
  int minasColocadas = 0;
  while (minasColocadas < totalMinas) {
    int i = int(random(cols));
    int j = int(random(filas));
    if (!cuadricula[i][j].esMina) {
      cuadricula[i][j].esMina = true;
      minasColocadas++;
    }
  }

  // Conteo de minas adyacentes para cada casilla
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < filas; j++) {
      cuadricula[i][j].contarMinas();
    }
  }

  // Reinicio de variables de juego y tiempo
  juegoTerminado = false;
  juegoGanado = false;
  minasMarcadas = 0;
  tiempoInicio = millis(); // Registro del tiempo de inicio del juego
  loop(); 
}

// Función para dibujar elementos en la ventana de juego
void draw() {
  background(136, 203, 255); // Fondo del juego

  // Comprobar si se debe mostrar el menú de dificultad o el juego
  if (mostrarMenu) {
    mostrarMenuDificultad(); // Mostrar menú de dificultad
  } else {
    // Dimensiones del tablero de juego
    int alturaTablero = filas * w;
    int anchuraTablero = cols * w;

    // Ajuste de la posición del tablero en la ventana
    translate((width - anchuraTablero) / 2, (height - alturaTablero - alturaMenu - alturaMenuSuperior) / 2 + alturaMenuSuperior);

    // Dibujar cada casilla en la cuadrícula
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < filas; j++) {
        cuadricula[i][j].mostrar();
      }
    }

    // Mostrar la dificultad y el tiempo transcurrido
    fill(0);
    textSize(24);
    textAlign(CENTER);
    text("Dificultad: " + dificultadActual.toUpperCase(), width / 4, alturaMenuSuperior - 70);

    // Calcular y mostrar el tiempo transcurrido
    if (!juegoTerminado && !juegoGanado) {
      tiempoTranscurrido = millis() - tiempoInicio;
    }
    int segundos = (tiempoTranscurrido / 1000) % 60;
    int minutos = (tiempoTranscurrido / (1000 * 60)) % 60;
    text("Tiempo: " + nf(minutos, 2) + ":" + nf(segundos, 2), width / 5 * 3, alturaMenuSuperior - 70);

    // Mostrar mensaje de juego terminado o ganado
    if (juegoTerminado) {
      fill(0);
      textSize(32);
      textAlign(CENTER);
      text("Juego Terminado", width / 2, (height - alturaMenu) / 2);
      noLoop(); // Detener el bucle de dibujo
    } else if (juegoGanado) {
      fill(0);
      textSize(32);
      textAlign(CENTER);
      text("¡Ganaste!", width / 2, (height - alturaMenu) / 2);
      noLoop(); // Detener el bucle de dibujo
    }
  }
}

// Función para mostrar el menú de selección de dificultad
void mostrarMenuDificultad() {
  // Color del menu
  fill(136, 203, 255);
  rect(0, 0, width, height);
  fill(0);
  textSize(32);
  textAlign(CENTER);
  // Opciones de dificultad
  text("Selecciona la Dificultad", width / 2, height / 4);
  textSize(24);
  text("[1] Fácil", width / 2, height / 2 - 40);
  text("[2] Medio", width / 2, height / 2);
  text("[3] Difícil", width / 2, height / 2 + 40);
  text("Instrucciones", width / 2, height / 2 + 160);
  // Instrucciones del juego
  text("-Con Click derecho descubres las bombas", width / 2, height / 2 + 180);
  text("-Con r Reinicia el juego", width / 2, height / 2 + 200);
  text("-Con q Vuelver al menu", width / 2, height / 2 + 220);
  text("-El numero descubierto indica la cantidad de bombas a su alrededor", width / 2, height / 2 + 240);
  text("Para empezar selecciona la dificultad y disfruta de el juego", width / 2, height / 2 + 300);
}

// Función para manejar eventos del mouse
void mousePressed() {
  if (!mostrarMenu && mouseY > alturaMenuSuperior && mouseY < height - alturaMenu) {
    // Calcular la posición de la casilla seleccionada
    float offsetX = (width - cols * w) / 2;
    float offsetY = (height - filas * w - alturaMenu - alturaMenuSuperior) / 2 + alturaMenuSuperior;
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < filas; j++) {
        // Verificar si se hizo clic en una casilla
        if (cuadricula[i][j].contiene(mouseX - offsetX, mouseY - offsetY)) {
          // Si se hizo clic derecho, marcar o desmarcar la casilla
          if (mouseButton == RIGHT) {
            cuadricula[i][j].marcada = !cuadricula[i][j].marcada;
            minasMarcadas += cuadricula[i][j].marcada ? 1 : -1;
          }
          // Si se hizo clic izquierdo, descubrir la casilla
          else if (mouseButton == LEFT) {
            cuadricula[i][j].descubrir();
            if (cuadricula[i][j].esMina) {
              juegoTerminado = true;
              tiempoFin = millis(); // Registro del tiempo de finalización del juego
            }
          }
        }
      }
    }

    // Verificar si se ha ganado el juego
    if (minasMarcadas == totalMinas && comprobarVictoria()) {
      juegoGanado = true;
      tiempoFin = millis(); // Registro del tiempo de finalización del juego
    }
  }
}

// Función para manejar eventos del teclado
void keyPressed() {
  if (mostrarMenu) {
    // Iniciar el juego con la dificultad seleccionada
    if (key == '1') {
      dificultadActual = "fácil";
      iniciarJuego(dificultadActual);
    } else if (key == '2') {
      dificultadActual = "medio";
      iniciarJuego(dificultadActual);
    } else if (key == '3') {
      dificultadActual = "difícil";
      iniciarJuego(dificultadActual);
    }
  } else {
    // Reiniciar el juego o volver al menú principal
    if (key == 'r') {
      iniciarJuego(dificultadActual);
    } else if (key == 'q') {
      mostrarMenu = true;
      loop(); // Reanudar el bucle de dibujo
    }
  }
}

// Función para verificar si se ha ganado el juego
boolean comprobarVictoria() {
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < filas; j++) {
      // Si hay una casilla no descubierta o una mina no marcada, el juego no está ganado
      if ((cuadricula[i][j].esMina && !cuadricula[i][j].marcada) || (!cuadricula[i][j].esMina && !cuadricula[i][j].descubierta)) {
        return false;
      }
    }
  }
  return true; // Todas las condiciones se cumplen, el juego está ganado
}

// Definición de la clase Casilla para representar cada celda en el juego
class Casilla {
  // Contenido posible de una casilla
  int x, y; 
  float w; 
  boolean esMina; 
  boolean descubierta; 
  boolean marcada; 
  int minasVecinas; 

  // Constructor de la casilla
  Casilla(int i, int j, float w) {
    this.x = i;
    this.y = j;
    this.w = w;
    esMina = false;
    descubierta = false;
    marcada = false;
  }

  // Método para contar las minas adyacentes a la casilla
  void contarMinas() {
    if (esMina) {
      minasVecinas = -1;
      return;
    }
    int total = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int ni = x + i;
        int nj = y + j;
        if (ni >= 0 && ni < cols && nj >= 0 && nj < filas) {
          if (cuadricula[ni][nj].esMina) {
            total++;
          }
        }
      }
    }
    minasVecinas = total;
  }

  // Método para descubrir una casilla
  void descubrir() {
    descubierta = true;
    if (minasVecinas == 0) {
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          int ni = x + i;
          int nj = y + j;
          if (ni >= 0 && ni < cols && nj >= 0 && nj < filas) {
            if (!cuadricula[ni][nj].descubierta) {
              cuadricula[ni][nj].descubrir();
            }
          }
        }
      }
    }
  }

  // Método para verificar si un punto está dentro de la casilla
  boolean contiene(float px, float py) {
    return px > x * w && px < x * w + w && py > y * w && py < y * w + w;
  }

  // Método para mostrar la casilla en la pantalla
  void mostrar() {
    stroke(0);
    noFill();
    rect(x * w, y * w, w, w);
    if (descubierta) {
      if (esMina) {
        fill(127);
        ellipse(x * w + w * 0.5, y * w + w * 0.5, w * 0.5, w * 0.5);
      } else {
        fill(200);
        rect(x * w, y * w, w, w);
        if (minasVecinas > 0) {
          fill(0);
          textAlign(CENTER);
          textSize(30);
          text(minasVecinas, x * w + w * 0.5, y * w + w - 4);
        }
      }
    } else if (marcada) {
      fill(255, 0, 0);
      rect(x * w, y * w, w, w);
    }
  }
}

