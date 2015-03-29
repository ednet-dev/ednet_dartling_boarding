part of grid;

class Grid {
  Table table;
  var color = new Color('white');

  CellPieces cellPieces;

  Grid(this.table) {
    color.border = color.main;
    cellPieces = new CellPieces(this);
    var cellPiece;
    for (var column = 0; column < table.columnCount; column++) {
      for (var row = 0; row < table.rowCount; row++) {
        cellPiece = newCellPiece(this, new Cell(column, row));
        cellPieces.add(cellPiece);
      }
    }
    for (CellPiece cp in cellPieces) {
      cp.width = table.cellWidth;
      cp.height = table.cellHeight;
      cp.x = cp.width * cp.cell.column;
      cp.y = cp.height * cp.cell.row;
    }
  }
  
  Position get position => table.position;
  num get x => table.position.x;
  num get y => table.position.y;
  Area get area => table.area;
  num get width => table.area.width;
  num get height => table.area.height;
  Size get size => table.size;
  int get columnCount => table.size.columnCount;
  int get rowCount => table.size.columnCount;
  num get cellWidth => table.cellWidth;
  num get cellHeight => table.cellHeight;

  CellPiece newCellPiece(Grid grid, Cell cell) => new CellPiece(grid, cell);

  bool contains(Cell cell) => table.contains(cell);
  
  CellPiece cellPiece(int column, int row) => cellPieces.cellPiece(column, row);
  CellPiece randomCellPiece() => cellPieces.randomCellPiece();
}

class MazeCell extends CellPiece { 
  static const String wallColor = 'black';
  static const String pathColor = 'orange';
  
  MazeCell(MazeGrid grid, Cell cell): super(grid, cell) {
    line.width = 0; 
    color.main = wallColor; 
  }
}

//www.migapro.com/depth-first-search
class MazeGrid extends Grid {
  MazeGrid(Table table): super(table) {
    if (columnCount.isOdd || rowCount.isOdd) {
      var msg = 'Maze grid size must be an even integer: (${size.columnCount}, ${size.rowCount})';
      print(msg);
      throw new Exception(msg);
    }
    var sp = randomCellPiece();
    path(sp.cell.column, sp.cell.row);
  }
  
  path(int c, int r) {
    var dds = new List<DirectDirection>();
    for (var i = 0; i < 4; i++) {
      dds.add(randomDirectDirection());
    }
    for (var dd in dds) {
      switch(dd) {
        case DirectDirection.LEFT:
          // if 2 cells left is outside
          if (c - 2 <= 0) {
            continue;
          }
          var cp1 = cellPieces.cellPiece(c - 1, r);
          var cp2 = cellPieces.cellPiece(c - 2, r);
          if (!cp2.tag.isMarked) {     // if wall
              cp2.tag.isMarked = true; // path
              cp1.tag.isMarked = true;
              path(c - 2, r);
          }
          break;
        case DirectDirection.RIGHT:
          // if 2 cells right is outside
          if (c + 2 >= table.size.columnCount - 1) {
            continue;
          }
          var cp1 = cellPieces.cellPiece(c + 1, r);
          var cp2 = cellPieces.cellPiece(c + 2, r);
          if (!cp2.tag.isMarked) {
              cp2.tag.isMarked = true;
              cp1.tag.isMarked = true;
              path(c + 2, r);
          }          
          break;
        case DirectDirection.UP:
          // if 2 cells up is outside
          if (r - 2 <= 0) {
            continue;
          }
          var cp1 = cellPieces.cellPiece(c, r - 1);
          var cp2 = cellPieces.cellPiece(c, r - 2);
          if (!cp2.tag.isMarked) {
              cp2.tag.isMarked = true;
              cp1.tag.isMarked = true;
              path(c, r - 2);
          }
          break;
        case DirectDirection.DOWN:
          // if 2 cells down is outside
          if (r + 2 >= table.size.rowCount - 1) {
            continue;
          }
          var cp1 = cellPieces.cellPiece(c, r + 1);
          var cp2 = cellPieces.cellPiece(c, r + 2);
          if (!cp2.tag.isMarked) {
              cp2.tag.isMarked = true;
              cp1.tag.isMarked = true;
              path(c, r + 2);
          }    
      }
    }
  }
  
  CellPiece newCellPiece(Grid grid, Cell cell) => new MazeCell(this, cell);
}

