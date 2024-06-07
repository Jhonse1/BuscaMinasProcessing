int columnas, filas; 
int tamañoCasilla = 40; 
int totalMinas; 
Casilla[][] tablero; 
boolean juegoTerminado; 
boolean juegoGanado; 
int minasMarcadas; 
boolean mostrarMenu = true; 
String dificultadActual = "medio"; 
int alturaMenuInferior = 40; 
int alturaMenuSuperior = 40; 
int puntaje;
int tiempoInicio; 
int tiempoActual; 

void setup() {
  size(1000, 1200); // Tamaño de la ventana del juego
}

void iniciarJuego(String dificultad) {
  // Oculta el menú de dificultad y configura el juego según la dificultad seleccionada
  mostrarMenu = false;
  if (dificultad.equals("fácil")) {
    columnas = 10;
    filas = 10;
    totalMinas = 10;
  } else if (dificultad.equals("medio")) {
    columnas = 20;
    filas = 20;
    totalMinas = 40;
  } else if (dificultad.equals("difícil")) {
    columnas = 25;
    filas = 25;
    totalMinas = 99;
  }

  // Inicializa el tablero de juego y coloca las minas de forma aleatoria
  tablero = new Casilla[columnas][filas];
  for (int i = 0; i < columnas; i++) {
    for (int j = 0; j < filas; j++) {
      tablero[i][j] = new Casilla(i, j, tamañoCasilla);
    }
  }

  int minasColocadas = 0;
  while (minasColocadas < totalMinas) {
    int i = int(random(columnas));
    int j = int(random(filas));
    if (!tablero[i][j].esMina) {
      tablero[i][j].esMina = true;
      minasColocadas++;
    }
  }

  // Conteo de minas adyacentes para cada casilla del tablero
  for (int i = 0; i < columnas; i++) {
    for (int j = 0; j < filas; j++) {
      tablero[i][j].contarMinas();
    }
  }

  // Reinicia variables de control del juego y registra el tiempo de inicio
  juegoTerminado = false;
  juegoGanado = false;
  minasMarcadas = 0;
  puntaje = 0;
  tiempoInicio = millis();
  loop(); // Reanuda el bucle de dibujo
}

void draw() {
  background(136, 203, 255); // Fondo de la ventana del juego

  if (mostrarMenu) {
    mostrarMenuDificultad(); // Muestra el menú de selección de dificultad
  } else {
    // Dimensiones del tablero de juego
    int tableroAltura = filas * tamañoCasilla;
    int tableroAnchura = columnas * tamañoCasilla;

    // Ajusta la posición del tablero en la ventana
    translate((width - tableroAnchura) / 2, (height - tableroAltura - alturaMenuInferior - alturaMenuSuperior) / 2 + alturaMenuSuperior);

    // Dibuja cada casilla en el tablero
    for (int i = 0; i < columnas; i++) {
      for (int j = 0; j < filas; j++) {
        tablero[i][j].mostrar();
      }
    }

    // Muestra el menú superior con la dificultad actual, el puntaje y el tiempo transcurrido
    fill(0);
    textSize(24);
    textAlign(CENTER);
    text("Dificultad: " + dificultadActual.toUpperCase(), width / 4, alturaMenuSuperior - 70);
    text("Puntaje: " + puntaje, width / 4 - 160, alturaMenuSuperior - 70);
    tiempoActual = millis() - tiempoInicio;
    text("Tiempo: " + tiempoActual / 1000 + "s", width / 4 + 160, alturaMenuSuperior - 70);

    // Muestra mensajes de juego terminado o ganado
    if (juegoTerminado) {
      fill(0);
      textSize(32);
      textAlign(CENTER);
      text("Juego Terminado", width / 2, (height - alturaMenuInferior) / 2);
      noLoop(); // Detiene el bucle de dibujo
    } else if (juegoGanado) {
      fill(0);
      textSize(32);
      textAlign(CENTER);
      text("¡Ganaste!", width / 2, (height - alturaMenuInferior) / 2);
      noLoop(); // Detiene el bucle de dibujo
    }
  }
}

void mostrarMenuDificultad() {
  // Muestra el menú de selección de dificultad
  fill(136, 203, 255);
  rect(0, 0, width, height);
  fill(0);
  textSize(32);
  textAlign(CENTER);
  text("Selecciona la Dificultad", width / 2, height / 4);
  textSize(24);
  text("[1] Fácil", width / 2, height / 2 - 40);
  text("[2] Medio", width / 2, height / 2);
  text("[3] Difícil", width / 2, height / 2 + 40);
  text("Instrucciones", width / 2, height / 2 + 150);
  text("-Con Click derecho descubres las bombas", width / 2, height / 2 + 180);
  text("-Con [R] Reinicia el juego", width / 2, height / 2 + 210);
  text("-Con [Q] Vuelver al menu", width / 2, height / 2 + 240);
  text("-El numero descubierto indica la cantidad de bombas a su alrededor", width / 2, height / 2 + 270);
  text("Para empezar selecciona la dificultad y disfruta de el juego", width / 2, height / 2 + 320);
}

void mousePressed() {
  // Maneja la lógica del juego cuando se hace clic en el tablero
  if (!mostrarMenu && mouseY > alturaMenuSuperior && mouseY < height - alturaMenuInferior) {
    float offsetX = (width - columnas * tamañoCasilla) / 2;
    float offsetY = (height - filas * tamañoCasilla - alturaMenuInferior - alturaMenuSuperior) / 2 + alturaMenuSuperior;
    for (int i = 0; i < columnas; i++) {
      for (int j = 0; j < filas; j++) {
        if (tablero[i][j].contiene(mouseX - offsetX, mouseY - offsetY)) {
          if (mouseButton == RIGHT) {
            tablero[i][j].marcado = !tablero[i][j].marcado;
            if (tablero[i][j].marcado) {
              minasMarcadas++;
              if (tablero[i][j].esMina) {
                puntaje++;
              }
            } else {
              minasMarcadas--;
              if (tablero[i][j].esMina) {
                puntaje--;
              }
            }
          } else if (mouseButton == LEFT) {
            tablero[i][j].revelar();
            if (tablero[i][j].esMina) {
              juegoTerminado = true;
            }
          }
        }
      }
    }

    if (minasMarcadas == totalMinas && verificarVictoria()) {
      juegoGanado = true;
    }
  }
}

void keyPressed() {
  // Maneja eventos de teclado
  if (mostrarMenu) {
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
    if (key == 'r') {
      iniciarJuego(dificultadActual);
    } else if (key == 'q') {
      mostrarMenu = true;
      loop();
    }
  }
}

boolean verificarVictoria() {
  // Verifica si todas las casillas que no son minas han sido reveladas
  for (int i = 0; i < columnas; i++) {
    for (int j = 0; j < filas; j++) {
      if ((tablero[i][j].esMina && !tablero[i][j].marcado) || (!tablero[i][j].esMina && !tablero[i][j].revelado)) {
        return false;
      }
    }
  }
  return true;
}

// Clase para representar cada casilla del tablero
class Casilla {
  int x, y; 
  float w; 
  boolean esMina; 
  boolean revelado;
  boolean marcado; 
  int minasVecinas; 

  Casilla(int i, int j, float w) {
    // Constructor de la casilla
    this.x = i;
    this.y = j;
    this.w = w;
    esMina = false;
    revelado = false;
    marcado = false;
  }

  void contarMinas() {
    // Cuenta el número de minas adyacentes a la casilla
    if (esMina) {
      minasVecinas = -1;
      return;
    }
    int total = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int ni = x + i;
        int nj = y + j;
        if (ni >= 0 && ni < columnas && nj >= 0 && nj < filas) {
          if (tablero[ni][nj].esMina) {
            total++;
          }
        }
      }
    }
    minasVecinas = total;
  }

  void revelar() {
    // Revela la casilla y las casillas adyacentes si no tienen minas vecinas
    revelado = true;
    if (minasVecinas == 0) {
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          int ni = x + i;
          int nj = y + j;
          if (ni >= 0 && ni < columnas && nj >= 0 && nj < filas) {
            if (!tablero[ni][nj].revelado) {
              tablero[ni][nj].revelar(); // Llamado recursivo 
            }
          }
        }
      }
    }
  }

  boolean contiene(float px, float py) {
    // Verifica si el punto (px, py) está dentro de la casilla
    return px > x * w && px < x * w + w && py > y * w && py < y * w + w;
  }

  void mostrar() {
    // Dibuja la casilla en el tablero
    stroke(0);
    noFill();
    rect(x * w, y * w, w, w);
    if (revelado) {
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
    } else if (marcado) {
      fill(255, 0, 0);
      rect(x * w, y * w, w, w);
    }
  }
}
