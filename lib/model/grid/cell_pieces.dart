part of grid;

class CellPiece extends Piece {
  Cell cell;
  Grid grid;

  CellPiece(this.grid, this.cell) {
    if (!grid.table.contains(cell)) {
      throw new Exception(
        'cell out of grid(${grid.table.size.columnCount}, ${grid.table.size.rowCount}) '
        '- column: ${cell.column}, row: ${cell.row}');
    }
    shape = PieceShape.RECT;
  }
  
  fromJsonMap(Map<String, Object> jsonMap) {
    super.fromJsonMap(jsonMap);
    cell = new Cell.fromJson(jsonMap['cell']);
  }

  Map<String, Object> toJsonMap() {
    var jsonMap = super.toJsonMap();
    jsonMap['cell'] = cell.toJsonMap();
    return jsonMap;
  }
  
  bool isDirectNeighborOf(CellPiece np) {
    return cell.column == np.cell.column - 1 || 
           cell.column == np.cell.column + 1 || 
           cell.row == np.cell.row - 1 || 
           cell.row == np.cell.row + 1;
  }
  
  bool isDiagonalNeighborOf(CellPiece np) {
    return (cell.column == np.cell.column - 1 && cell.row == np.cell.row - 1) ||
           (cell.column == np.cell.column + 1 && cell.row == np.cell.row - 1) ||
           (cell.column == np.cell.column - 1 && cell.row == np.cell.row + 1) ||
           (cell.column == np.cell.column + 1 && cell.row == np.cell.row + 1);
  }
  
  bool isNeighborOf(CellPiece np) {
    return isDirectNeighborOf(np) || isDiagonalNeighborOf(np);
  }
  
  swap(CellPiece np) {
    var cpx = x;
    var cpy = y;
    var cpc = cell.column;
    var cpr = cell.row;
    x = np.x;
    y = np.y;
    cell.column = np.cell.column;
    cell.row = np.cell.row;
    np.x = cpx;
    np.y = cpy;
    np.cell.column = cpc;
    np.cell.row = cpr;
  }
  
  move(Direction direction) {
    switch(direction) {
      case Direction.LEFT:
        cell.column = cell.column - 1; 
        break;
      case Direction.RIGHT:
        cell.column = cell.column + 1; 
        break;
      case Direction.UP:
        cell.row = cell.row - 1; 
        break;
      case Direction.DOWN:
        cell.row = cell.row + 1; 
        break;
      case Direction.LEFT_UP:
        cell.column = cell.column - 1; 
        cell.row = cell.row - 1; 
        break;
      case Direction.RIGHT_UP:
        cell.column = cell.column + 1; 
        cell.row = cell.row - 1;
        break;
      case Direction.LEFT_DOWN:
        cell.column = cell.column - 1;
        cell.row = cell.row + 1; 
        break;
      case Direction.RIGHT_DOWN:
        cell.column = cell.column + 1;
        cell.row = cell.row + 1;
    }
  }
}

class CellPieces {
  List<CellPiece> _list;
  
  Grid grid;

  CellPieces(this.grid) {
    _list = new List<CellPiece>();
  }
  
  fromJsonList(List<Map<String, Object>> jsonList) {
    jsonList.forEach((jsonMap) {
      var cell = jsonMap['cell'];
      var cp = cellPiece(cell['column'], cell['row']);
      if (cp != null) {
        cp.fromJsonMap(jsonMap);
      }
    });
  }
  
  fromJsonString(String jsonString) {
    List<Map<String, Object>> jsonList = JSON.decode(jsonString);
    fromJsonList(jsonList);
  }
  
  List<CellPiece> toList() {
    return _list.toList();
  }
  
  List<Map<String, Object>> toJsonList() {
    var jsonList = new List<Map<String, Object>>();
    forEach((CellPiece cp) => jsonList.add(cp.toJsonMap()));
    return jsonList;
  }
  
  String toJsonString() => JSON.encode(toJsonList());

  int get length => _list.length;
  Iterator get iterator => _list.iterator;
  
  add(CellPiece cp) => _list.add(cp);
  empty() => forEach((CellPiece cp) => cp.tag.empty());

  forEach(f(CellPiece cp)) => _list.forEach(f);
  bool any(bool f(CellPiece cp)) => _list.any(f);
  bool every(bool f(CellPiece cp)) => _list.every(f);
  CellPiece maxCellPiece() => 
      _list.reduce((CellPiece cp1, CellPiece cp2) => cp1.compareTo(cp2) == -1 ? cp2 : cp1);
  
  select() => forEach((CellPiece cp) => cp.isSelected = true);
  deselect() => forEach((CellPiece cp) => cp.isSelected = false);
  
  CellPiece firstSelectedCellPiece() {
    for (CellPiece cp in this) {
      if (cp.isSelected) {
        return cp;
      }
    }
    return null;
  }
  
  CellPiece cellPiece(int column, int row) {
    for (CellPiece cp in this) {
      if (cp.cell.isIn(column, row)) return cp;
    }
    return null;
  }
  
  CellPiece neighbor(CellPiece cp, Direction direction) {
    CellPiece neighbor;
    switch(direction) {
      case Direction.LEFT:
        neighbor = cellPiece(cp.cell.column - 1, cp.cell.row); 
        break;
      case Direction.RIGHT:
        neighbor = cellPiece(cp.cell.column + 1, cp.cell.row); 
        break;
      case Direction.UP:
        neighbor = cellPiece(cp.cell.column, cp.cell.row - 1); 
        break;
      case Direction.DOWN:
        neighbor = cellPiece(cp.cell.column, cp.cell.row + 1); 
        break;
      case Direction.LEFT_UP:
        neighbor = cellPiece(cp.cell.column - 1, cp.cell.row - 1); 
        break;
      case Direction.RIGHT_UP:
        neighbor = cellPiece(cp.cell.column + 1, cp.cell.row - 1); 
        break;
      case Direction.LEFT_DOWN:
        neighbor = cellPiece(cp.cell.column - 1, cp.cell.row + 1); 
        break;
      case Direction.RIGHT_DOWN:
        neighbor = cellPiece(cp.cell.column + 1, cp.cell.row + 1); 
    }  
    return neighbor;
  }
  
  CellPiece randomCellPiece() => _list[randomInt(length)];
  CellPiece randomAvailableCellPiece() {
    if (any((CellPiece cp) => cp.tag.isEmpty)) {
      var rc = randomCellPiece();
      if (rc.tag.isEmpty) return rc;
      else return randomAvailableCellPiece();
    }
    return null;
  }
  
  move(Direction direction) {
    var moved = false;
    for (CellPiece cp in this) {
      if (!cp.tag.isEmpty) {
        CellPiece np = neighbor(cp, direction);
        if (np != null && np.tag.isEmpty) {
          cp.swap(np);
          moved = true;
        }     
      }
    }
    if (moved) move(direction);
  }
  
  merge(Direction direction) {
    var merged = false;
    for (CellPiece cp in this) {
      if (!cp.tag.isEmpty) {
        CellPiece n = neighbor(cp, direction);
        if (n != null && !n.tag.isEmpty) {
          if (cp.tag.number == n.tag.number) {
            n.tag.number = n.tag.number + n.tag.number;
            cp.tag.empty();
            merged = true;
          }
        }
      }
    }
    if (merged) merge(direction);
  }
}
