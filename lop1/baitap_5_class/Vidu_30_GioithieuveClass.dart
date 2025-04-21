/*
Dart là một ngôn ngữ lập trình hướng đối tượng, nơi mọi thứ đều là đối tượng và
các đối tượng này được tạo ra từ các lớp (class).
 
Mỗi đối tượng trong Dart có thể có các thuộc tính (biến) và phương thức (hàm).
Thuộc tính lưu trữ dữ liệu và phương thức thực hiện các hành động.
 
Sử dụng dấu chấm (.) để tham chiếu đến một thuộc tính hoặc phương thức:
 
*/
 
import 'dart:math';
 
class Point {
  double x, y;
 
  Point(this.x, this.y);
 
  double distanceTo(Point other) {
    var dx = x - other.x;
    var dy = y - other.x;
    return sqrt(dx * dx + dy * dy);
  }
}
 
// =====================
 
class Point2 {
  double? x; // Thuoc tinh instance x, ban dau mac dinh la null
  double z = 0; // Thuoc tinh instance z, ban dau mac dinh la 0
}
 
// ====================
double X_ = 1.5;
 
class Point3 {
  double? x = X_; // Co the truy cao khai khong phu thuoc this
  //double? y = this.x; //LOI
  double? y;
  late double? z = x;
 
  Point3(this.x, this.y, this.z);
}
 
/*
Phương thức khởi tạo
Ta có thể tạo đối tượng bằng cách sử dụng phương thức khởi tạo (constructors).
Tên constructor có thể là ClassName hoặc ClassName.identifier.
*/
// ====================
class Point4 {
  final String name;
  final DateTime start = DateTime.now();
 
  Point4(this.name);
}
 
// ===================
 
/*
Thuộc tính và phương thức static
Trong Dart, thuộc tính và phương thức tĩnh (static) được sử dụng để chia sẻ dữ
liệu và chức năng giữa tất cả các đối tượng của một lớp. Điều này có nghĩa là ta không
cần phải tạo ra một đối tượng để truy cập vào các thuộc tính hoặc phương thức này
*/
class MyMath {
  static const double PI = 3.14159;
 
  static double sqr(double x) {
    return x * x;
  }
}
 
/*
Phương thức getters, setter
Trong Dart, getters và setters là các phương thức đặc biệt cung cấp quyền truy cập
đọc và ghi vào các thuộc tính của một đối tượng. Ta có thể tạo thêm các thuộc tính
bằng cách triển khai getters và setters thông qua các từ khóa get và set.
 
*/
class Rectangle {
  double left, top, width, height;
 
  Rectangle(this.left, this.top, this.width, this.height);
 
  // Dinh nghia hai thuoc tinh right
  double get right => left + width;
  set right(double value) => left = value - width;
 
  @override
  String toString() {
    return "Left: $left, Top: $top, Width: $width, Height: height";
  }
 
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Rectangle) return false;
 
    return left == other.left &&
        top == other.top &&
        width == other.width &&
        height == other.height;
  }
}
 
void main() {
  // Khoi tao doi tuong
  var p1 = Point(0, 0);
 
  var p2 = Point(3, 3);
  double distance = p1.distanceTo(p2);
  print(distance.toStringAsFixed(2));
 
  var p3 = Point2();
  print(p3.x); // getter
  print(p3.z);
  p3.z = 100; // setter
  print(p3.z);
 
  var p4 = Point4("Tung");
 
  print(MyMath.PI);
 
  print(MyMath.sqr(5));
 
  var rect = Rectangle(3, 4, 20, 15);
  print("====");
  print(rect.left);
  rect.right = 12;
  print(rect.left);
  print(rect);
}
 