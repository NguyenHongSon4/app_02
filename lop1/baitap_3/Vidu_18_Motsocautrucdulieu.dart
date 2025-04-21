void main()
{
  List<String> list1 = ['A', 'B', 'C']; //tao list truc tiep
  var list2 = [1,2,3]; //su dung var de tu nhan biet kieu du lieu
  List<String> list3 = []; //list rong
  var list4 = List<int>.filled(3,0); //list co kich thuoc co dinh

  //1.Thêm phần tử
  list1.add('D'); //thêm 1 phần tử

  list1.addAll(['A', 'C']); //Thêm nhìu ptpt

  list1.insert(0, 'Z'); //chèn 1 pt

  list1.insertAll(1, ['1','0']); //chèn nhìu ptpt
  print(list1);
  //2.Xóa phần tử
  list1.remove('A'); //Xóa pt có giá trị A
  list1.removeAt(0); //Xóa pt ở vị trí 0
  list1.removeLast; //Xóa pt ở tại vị trí cuối cùng
  list1.removeWhere((e)=>e=='B'); //Xóa theo điều kiện
  list1.clear();
  print(list1);

  //3. Truy câpj phần tử
  print(list2[0]); //Lấy phần tửử ở vị trí 0
  print(list2.first); //Lấy phần tử đầu tiên
  print(list2.last); //Lấy phần tử cuối cùngcùng
  print(list2.length); //Lấy độ dài list

  //4.Kiểm tra
  print(list2.isEmpty); //Kiểm tra rỗng
  print('List 3: ${list3.isNotEmpty?'Không rỗng' : 'Rỗng'}');
  print(list4.contains(1));
  print(list4.contains(0));
  print(list4.lastIndexOf(0));

  //5.Biến đổi
  list4 = [2,1,3,9,0,10];
  print(list4);
  list4.sort(); //Sap xep tang dan
  print(list4);
  list4.reversed; //Dao nguoc
  print(list4.reversed);
  list4 = list4.reversed.toList();
  print(list4);

  //7.Cắt & nối
  var subList = list4.sublist(1,3); //cắt 1 sublist từ 1 đến <3
  print(subList);
  var strJoined = list4.join(",");
  print(strJoined);

  //8.Duyệt các phần tử
  for (var element in list4) {
    print(element);
  }


}