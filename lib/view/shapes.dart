part of boarding;

prepareRoundedRect(CanvasElement canvas, num x, num y, num width, num height, num radius) {
  // http://stackoverflow.com/questions/1255512/how-to-draw-a-rounded-rectangle-on-html-canvas
  var r2d = PI / 180;
  //ensure that the radius isn't too large for x
  if ((width - x) - (2 * radius) < 0) {radius = (( width - x ) / 2);}
  //ensure that the radius isn't too large for y
  if ((height - y) - (2 * radius) < 0 ) {radius = ((height - y) / 2 );}
  var context = canvas.getContext('2d');
  context
    ..beginPath()
    ..moveTo(x + radius, y)
    ..lineTo(width - radius, y)
    ..arc(width - radius, y + radius, radius, r2d * 270, r2d * 360, false)
    ..lineTo(width, height - radius)
    ..arc(width - radius, height - radius, radius, r2d * 0, r2d * 90, false)
    ..lineTo(x + radius, height)
    ..arc(x + radius, height - radius, radius, r2d * 90, r2d * 180, false)
    ..lineTo(x, y + radius)
    ..arc(x + radius, y + radius, radius, r2d * 180, r2d * 270, false)
    ..closePath();
}

List<Map<String, num>> prepareStars(CanvasElement canvas, int count, {int spikes: 5}) {
  var stars = new List<Map>();
  for (var i = 0; i < count; i++) {
    var sx = randomNum(canvas.width);
    var sy = randomNum(canvas.height);
    var outerRadius = randomNum(spikes + 2);
    var innerRadius = randomNum(spikes - 2);
    var star = new Map<String, num>();
    star['sx'] = sx;
    star['sy'] = sy;
    star['spikes'] = spikes;
    star['outerRadius'] = outerRadius;
    star['innerRadius'] = innerRadius;
    stars.add(star);
  }
  return stars;
}

drawStars(CanvasElement canvas, List<Map<String, num>> stars) {
  for (var i = 0; i < stars.length; i++) {
    var star = stars[i];
    var sx = star['sx'];
    var sy = star['sy'];
    var spikes = star['spikes'];
    var outerRadius = star['outerRadius'];
    var innerRadius = star['innerRadius'];
    drawStar(canvas, sx, sy, spikes, outerRadius, innerRadius);
  }
}

drawRandomStars(CanvasElement canvas, int count) {
  for (var i = 0; i < count; i++) {
    var sx = randomNum(canvas.width);
    var sy = randomNum(canvas.height);
    var spikes = 5;
    var outerRadius = randomNum(7);
    var innerRadius = randomNum(4);
    drawStar(canvas, sx, sy, spikes, outerRadius, innerRadius);
  }
}

drawStar(CanvasElement canvas, num sx, num sy, num spikes,
         num outerRadius, num innerRadius,
         {String color: 'white', String borderColor: 'black'}) {
  var rot = PI / 2 * 3;
  var x = sx;
  var y = sy;
  var step = PI / spikes;
  var context = canvas.getContext('2d');

  context.strokeStyle = borderColor;
  context.fillStyle = color;
  context.beginPath();
  context.moveTo(sx,sy-outerRadius);
  for (var i = 0; i < spikes; i++) {
    x = sx + cos(rot) * outerRadius;
    y = sy + sin(rot) * outerRadius;
    context.lineTo(x, y);
    rot += step;

    x = sx + cos(rot) * innerRadius;
    y = sy + sin(rot) * innerRadius;
    context.lineTo(x,y);
    rot += step;
  }
  context.lineTo(sx, sy - outerRadius);
  context.stroke();
  context.fill();
  context.closePath();
}

drawDistanceLine(CanvasElement canvas, Piece p1, Piece p2, num minDistance) {
  //RGBA color: rgba(red, green, blue, alpha).
  //The alpha number is between 0.0 (fully transparent) and 1.0 (fully opaque).
  var distance12 = distance(p1, p2);
  if (distance12 <= minDistance) {
    var d = 1.2 - distance12 / minDistance;
    var c = 'rgba(255, 255, 255, $d)';
    new Line(canvas, p1.x, p1.y, p2.x, p2.y, color: c).draw();
  }
}

abstract class Shape {
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  num x, y, width, height, lineWidth;
  String color, borderColor;

  Shape(this.canvas, this.x, this.y, this.width, this.height,
      this.lineWidth, this.color, this.borderColor) {
    context = canvas.getContext('2d');
  }

  draw();
}

class Circle extends Shape {
  num radius;

  Circle(CanvasElement canvas, num x, num y, this.radius,
      {num lineWidth: 1, String color: 'white', String borderColor: 'black'}):
      super(canvas, x, y, null, null, lineWidth, color, borderColor) {
    width = radius * 2;
    height = radius * 2;
  }

  draw() {
    context
        ..lineWidth = lineWidth
        ..fillStyle = color
        ..strokeStyle = borderColor
        ..beginPath()
        ..arc(x, y, radius, 0, PI * 2)
        ..closePath()
        ..fill()
        ..stroke();
  }
}

class Rect extends Shape {
  Rect(CanvasElement canvas, num x, num y, num width, num height,
       {num lineWidth: 1, String color: 'white', String borderColor: 'black'}):
       super(canvas, x, y, width, height, lineWidth, color, borderColor);

  draw() {
    context
        ..lineWidth = lineWidth
        ..fillStyle = color
        ..strokeStyle = borderColor
        ..beginPath()
        ..rect(x, y, width, height)
        ..closePath()
        ..fill()
        ..stroke();
  }
}

class Square extends Rect {
  num length;

  Square(CanvasElement canvas, num x, num y, num width,
      {num lineWidth: 1, String color: 'white', String borderColor: 'black'}):
        length = width,
      super(canvas, x, y, width, width,
          lineWidth: lineWidth, color: color, borderColor: borderColor);
}

class SelectedRect extends Rect {
  static const int sss = 8; // selection square size

  SelectedRect(CanvasElement canvas, num x, num y, num width, num height,
        {num lineWidth: 1, String color: 'white', String borderColor: 'black'}):
        super(canvas, x, y, width, height,
            lineWidth: lineWidth, color: color, borderColor: borderColor);

  draw() {
    super.draw();
    context
        ..fillStyle = 'black'
        ..beginPath()
        ..rect(x, y, sss, sss)
        ..rect(x + width - sss, y, sss, sss)
        ..rect(x + width - sss, y + height - sss, sss, sss)
        ..rect(x, y + height - sss, sss, sss)
        ..closePath()
        ..fill();
  }
}

class RoundedRect extends Rect {
  num radius;
  num r2d = PI/180;

  RoundedRect(CanvasElement canvas, num x, num y, num width, num height,
      {num this.radius: 10, num lineWidth: 1,
        String color: 'white', String borderColor: 'black'}):
      super(canvas, x, y, width, height,
          lineWidth: lineWidth, color: color, borderColor: borderColor);

  draw() {
    prepareRoundedRect(canvas, x, y, x + width, y + height, 10);
    context
      ..lineWidth = lineWidth
      ..fillStyle = color
      ..strokeStyle = borderColor
      ..fill()
      ..stroke();
  }
}

class Vehicle extends RoundedRect {
  Vehicle(CanvasElement canvas, num x, num y, num width, num height,
      {num lineWidth: 1, String color: 'white', String borderColor: 'black'}):
      super(canvas, x, y, width, height,
          lineWidth: lineWidth, color: color, borderColor: borderColor);

  draw() {
    super.draw();
    context
      ..beginPath()
      ..fillStyle = '#000000'
      ..rect(x + 12, y - 3, 14, 6)
      ..rect(x + width - 26, y - 3, 14, 6)
      ..rect(x + 12, y + height - 3, 14, 6)
      ..rect(x + width - 26, y + height - 3, 14, 6)
      ..fill()
      ..closePath();
  }
}

class Line extends Shape {
  num x1, y1;

  Line(CanvasElement canvas, num x, num y, this.x1, this.y1,
      {num lineWidth: 1, String color: 'black', String borderColor: 'black'}):
      super(canvas, x, y, lineWidth, null, lineWidth, color, borderColor);

  draw() {
    context
        ..lineWidth = lineWidth
        ..strokeStyle = color
        ..beginPath()
        ..moveTo(x, y)
        ..lineTo(x1, y1)
        ..closePath()
        ..stroke();
  }
}

class OneOfLines extends Shape {
  num x1, y1;

  OneOfLines(CanvasElement canvas, num x, num y, this.x1, this.y1,
      {num lineWidth: 1, String color: 'black', String borderColor: 'black'}):
      super(canvas, x, y, lineWidth, null, lineWidth, color, borderColor);

  draw() {
    context
        ..lineWidth = lineWidth
        ..strokeStyle = color
        ..moveTo(x, y)
        ..lineTo(x1, y1);
  }
}

class Tag extends Shape {
  num size, maxWidth;
  String text;

  Tag(CanvasElement canvas, num x, num y, this.size, this.text,
      {num lineWidth: 1, num this.maxWidth,
        String color: 'black', String borderColor: 'black'}):
      super(canvas, x, y, null, null, lineWidth, color, borderColor) {
    this.width = size;
    this.height = size;
  }

  draw() {
    context
        ..font = '${size}px sans-serif'
        ..fillStyle = color
        ..textAlign = 'center'
        ..beginPath()
        ..fillText(text, x, y)
        ..closePath();
  }
}

class OneOfTags extends Shape {
  num size, maxWidth;
  String text;

  OneOfTags(CanvasElement canvas, num x, num y, this.size, this.text,
      {num lineWidth: 1, num this.maxWidth,
        String color: 'black', String borderColor: 'black'}):
      super(canvas, x, y, null, null, lineWidth, color, borderColor) {
    this.width = size;
    this.height = size;
  }

  draw() {
    context
        ..font = '${size}px sans-serif'
        ..fillStyle = color
        ..textAlign = 'center'
        ..fillText(text, x, y, maxWidth);
  }
}



