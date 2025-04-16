/*
Stream là gì?
 
Nếu Future giống như đợi một món ăn, thì Stream giống như xem một kênh YouTube:
 
Bạn đăng ký kênh (lắng nghe stream)
Video mới liên tục được đăng tải (stream phát ra dữ liệu)
Bạn xem từng video khi nó xuất hiện (xử lý dữ liệu từ stream)
Kênh có thể đăng tải nhiều video theo thời gian (stream phát nhiều giá trị)
 
Stream trong Dart là chuỗi các sự kiện hoặc dữ liệu theo thời gian,
không chỉ một lần như Future.
 
*/
 
import 'dart:async';
 
void ViDuStream(){
  Stream<int> stream = Stream.periodic(Duration(seconds: 1), (x)=>x+1).take(5);
 
  // Lắng nghe stream
  stream.listen(
    (so) => print("Nhan duoc so: $so"),
    onDone: () => print("Stream da hoan thanh"),
    onError: (loi) => print("Co loi: $loi"),
  );
}
 
void main(){
  ViDuStream();
}