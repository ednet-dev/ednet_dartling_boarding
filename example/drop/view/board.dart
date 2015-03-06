part of drop;

class Board extends Surface {
  static const int pieceCount = 10;
  static const String drop = 'drop';
  static const String hitCount = 'hitCount';
  
  FallingPieces fallingPieces;
  bool isGameOver;
  InputElement pieceCountInput = querySelector('#piece-count');
  LabelElement hitCountLabel = querySelector('#hit-count');
  
  Board(CanvasElement canvas) : super(canvas) {
    init(pieceCount);
    querySelector('#save').onClick.listen((e) {
      save();
    });
    querySelector('#load').onClick.listen((e) {
      load();
    });
    querySelector('#restart').onClick.listen((e) {
      restart();
    });
    querySelector('#start').onClick.listen((e) {
      start();
    });
    canvas.onMouseDown.listen((MouseEvent e) {
      fallingPieces.forEach((FallingPiece fp) {      
        var x = e.offset.x;
        var y = e.offset.y;
        if (fp.contains(x, y)) {
          if (fp.isSelected) {
            fp.isVisible = false;
            var invisibleCount = fallingPieces.invisibleCount();
            hitCountLabel.text = invisibleCount.toString();
            if (invisibleCount == pieceCount) {
              isGameOver = true;
            }
          } else {
            fp.isSelected = true;
          }
        }
      });
    });
    window.animationFrame.then(gameLoop);
  }
  
  init(int numberOfPieces) {
    fallingPieces = new FallingPieces(numberOfPieces);
    fallingPieces.randomInit();
    pieceCountInput.value = numberOfPieces.toString();
    hitCountLabel.text = '0';
    isGameOver = false;
  }
  
  gameLoop(num delta) {
    if (!isGameOver) {
      draw();
    }
    window.animationFrame.then(gameLoop);
  }
  
  draw() {
    clear();
    fallingPieces.forEach((FallingPiece fp) {
      fp.move();
      if (fp.isVisible) {
        if (fp.isSelected) {
          var r = fp.width / 2;
          new Circle(this, fp.x + r, fp.y + r, r, color: 'black').draw();
        } else {
          new Square(this, fp.x, fp.y, fp.width, color: fp.colorCode).draw();
        }
      }
    });
  }
  
  save() {
    window.localStorage[drop] = fallingPieces.toJsonString();
    window.localStorage[hitCount] = fallingPieces.invisibleCount().toString();
  }
  
  load() {
    String gameString = window.localStorage[drop];
    if (gameString != null) { 
      fallingPieces.fromJsonString(gameString);
      pieceCountInput.value = fallingPieces.length.toString();
    } else {
      pieceCountInput.value = pieceCount.toString();
    }
    String hitCountString = window.localStorage[hitCount]; 
    if (hitCountString != null) { 
      hitCountLabel.text = hitCountString;
    } else {
      hitCountLabel.text = '0';
    }
  }
  
  restart() {
    fallingPieces.forEach((FallingPiece fp) {
      fp.isVisible = true;
      fp.isSelected = false;
    });
    hitCountLabel.text = '0';
    isGameOver = false;
  }
  
  start() {
    try {
      init(int.parse(pieceCountInput.value));
    } on FormatException catch(e) {
      init(pieceCount);
    }
  }
}
