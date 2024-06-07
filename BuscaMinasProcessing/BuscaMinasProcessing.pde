int cols, rows;
int w = 40; 
int totalMines;
Casilla[][] grid;
boolean gameOver;
boolean gameWon;
int flaggedMines;
boolean showMenu = true;
String currentDifficulty = "medio";
int menuHeight = 40; 
int topMenuHeight = 40; 

int startTime; 
int endTime;   
int elapsedTime; 

void setup() {
  size(1000, 1200); 
}

void iniciarJuego(String dificultad) {
  showMenu = false;
  if (dificultad.equals("fácil")) {
    cols = 10;
    rows = 10;
    totalMines = 10;
  } else if (dificultad.equals("medio")) {
    cols = 20;
    rows = 20;
    totalMines = 40;
  } else if (dificultad.equals("difícil")) {
    cols = 21;
    rows = 21;
    totalMines = 99;
  }

  grid = new Casilla[cols][rows];
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      grid[i][j] = new Casilla(i, j, w);
    }
  }

  int minesPlaced = 0;
  while (minesPlaced < totalMines) {
    int i = int(random(cols));
    int j = int(random(rows));
    if (!grid[i][j].isMine) {
      grid[i][j].isMine = true;
      minesPlaced++;
    }
  }

  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      grid[i][j].countMines();
    }
  }

  gameOver = false;
  gameWon = false;
  flaggedMines = 0;
  startTime = millis(); 
  loop();
}

void draw() {
  background(255);

  if (showMenu) {
    showDifficultyMenu();
  } else {
    int tableroAltura = rows * w;
    int tableroAnchura = cols * w;

    translate((width - tableroAnchura) / 2, (height - tableroAltura - menuHeight - topMenuHeight) / 2 + topMenuHeight);

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        grid[i][j].show();
      }
    }

    fill(0);
    textSize(24);
    textAlign(CENTER);
    text("Dificultad: " + currentDifficulty.toUpperCase(), width / 4, topMenuHeight - 70);

    if (!gameOver && !gameWon) {
      elapsedTime = millis() - startTime;
    }
    
    int seconds = (elapsedTime / 1000) % 60;
    int minutes = (elapsedTime / (1000 * 60)) % 60;
    
    text("Tiempo: " + nf(minutes, 2) + ":" + nf(seconds, 2), width / 5 * 3, topMenuHeight - 70);

    if (gameOver) {
      fill(0);
      textSize(32);
      textAlign(CENTER);
      text("Juego Terminado", width / 2, (height - menuHeight) / 2);
      noLoop();
    } else if (gameWon) {
      fill(0);
      textSize(32);
      textAlign(CENTER);
      text("¡Ganaste!", width / 2, (height - menuHeight) / 2);
      noLoop();
    }
  }
}

void showDifficultyMenu() {
  fill(255);
  rect(0, 0, width, height);
  fill(0);
  textSize(32);
  textAlign(CENTER);
  text("Selecciona la Dificultad", width / 2, height / 4);
  textSize(24);
  text("[1] Fácil", width / 2, height / 2 - 40);
  text("[2] Medio", width / 2, height / 2);
  text("[3] Difícil", width / 2, height / 2 + 40);
  text("Instrucciones", width / 2, height / 2 + 160);
  text("-Con Click derecho descubres las bombas", width / 2, height / 2 + 180);
  text("-Con r Reinicia el juego", width / 2, height / 2 + 200);
  text("-Con q Vuelver al menu", width / 2, height / 2 + 220);
  text("-El numero descubierto indica la cantidad de bombas a su alrededor", width / 2, height / 2 + 240);
  text("Para empezar selecciona la dificultad y disfruta de el juego", width / 2, height / 2 + 300);
}

void mousePressed() {
  if (!showMenu && mouseY > topMenuHeight && mouseY < height - menuHeight) {
    float offsetX = (width - cols * w) / 2;
    float offsetY = (height - rows * w - menuHeight - topMenuHeight) / 2 + topMenuHeight;
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        if (grid[i][j].contains(mouseX - offsetX, mouseY - offsetY)) {
          if (mouseButton == RIGHT) {
            grid[i][j].flagged = !grid[i][j].flagged;
            flaggedMines += grid[i][j].flagged ? 1 : -1;
          } else if (mouseButton == LEFT) {
            grid[i][j].reveal();
            if (grid[i][j].isMine) {
              gameOver = true;
              endTime = millis(); 
            }
          }
        }
      }
    }

    if (flaggedMines == totalMines && checkWin()) {
      gameWon = true;
      endTime = millis(); 
    }
  }
}

void keyPressed() {
  if (showMenu) {
    if (key == '1') {
      currentDifficulty = "fácil";
      iniciarJuego(currentDifficulty);
    } else if (key == '2') {
      currentDifficulty = "medio";
      iniciarJuego(currentDifficulty);
    } else if (key == '3') {
      currentDifficulty = "difícil";
      iniciarJuego(currentDifficulty);
    }
  } else {
    if (key == 'r') {
      iniciarJuego(currentDifficulty);
    } else if (key == 'q') {
      showMenu = true;
      loop();
    }
  }
}

boolean checkWin() {
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if ((grid[i][j].isMine && !grid[i][j].flagged) || (!grid[i][j].isMine && !grid[i][j].revealed)) {
        return false;
      }
    }
  }
  return true;
}

class Casilla {
  int x, y;
  float w;
  boolean isMine;
  boolean revealed;
  boolean flagged;
  int neighboringMines;

  Casilla(int i, int j, float w) {
    this.x = i;
    this.y = j;
    this.w = w;
    isMine = false;
    revealed = false;
    flagged = false;
  }

  void countMines() {
    if (isMine) {
      neighboringMines = -1;
      return;
    }
    int total = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int ni = x + i;
        int nj = y + j;
        if (ni >= 0 && ni < cols && nj >= 0 && nj < rows) {
          if (grid[ni][nj].isMine) {
            total++;
          }
        }
      }
    }
    neighboringMines = total;
  }

  void reveal() {
    revealed = true;
    if (neighboringMines == 0) {
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          int ni = x + i;
          int nj = y + j;
          if (ni >= 0 && ni < cols && nj >= 0 && nj < rows) {
            if (!grid[ni][nj].revealed) {
              grid[ni][nj].reveal();
            }
          }
        }
      }
    }
  }

  boolean contains(float px, float py) {
    return px > x * w && px < x * w + w && py > y * w && py < y * w + w;
  }

  void show() {
    stroke(0);
    noFill();
    rect(x * w, y * w, w, w);
    if (revealed) {
      if (isMine) {
        fill(127);
        ellipse(x * w + w * 0.5, y * w + w * 0.5, w * 0.5, w * 0.5);
      } else {
        fill(200);
        rect(x * w, y * w, w, w);
        if (neighboringMines > 0) {
          fill(0);
          textAlign(CENTER);
          textSize(30);
          text(neighboringMines, x * w + w * 0.5, y * w + w - 4);
        }
      }
    } else if (flagged) {
      fill(255, 0, 0);
      rect(x * w, y * w, w, w);
    }
  }
}
