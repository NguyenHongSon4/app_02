import '../model/sinhvien.dart';
import '../model/lophoc.dart';

void main() {
  var sv = SinhVien("Nguyen Van A", 20, "SV001", 8.5);
  print(sv.hoTen);

  sv.hoTen = 'Nguyen Van B';
  print(sv.hoTen);

  sv.hoTen = "";
  print(sv.hoTen);

  print(sv.xepLoai());

  sv.hienThiThongTin();

  // ----------------------
  var lopHoc = LopHoc("21DTHF1");
  lopHoc.themSinhVien(SinhVien("Nguyen Hoang Son", 18, 'SV001', 9.5));
  lopHoc.themSinhVien(SinhVien('Pham Hoang Anh', 19, 'SV002', 7.5));
  lopHoc.themSinhVien(SinhVien('Nguyen Van Cuong', 22, 'SV003', 4.6));
  lopHoc.themSinhVien(SinhVien('Nguyen Hong Diem', 21, 'SV004', 6.4));
  lopHoc.hienThiDanhSach();
}
