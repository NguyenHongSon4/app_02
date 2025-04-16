/* chuoi la tap hop ky tu utf-16 */
void main()
{
  var s1 = 'Nguyen Hong Son';
  var s2 = "VN";

  double diemToan = 5;
  double diemVan = 8.3;
  var s3 = 'Hi $s1, ban dat tong diem la: ${diemToan + diemVan}';
  print(s3);

  var s6 = 'Day la mot doan \n van ban!';
  print(s6);

  var s7 = r'Day la 1 doan \n van ban';
  print(s7);

  var s8 = "Chuoi 1" + "Chuoi 2";
  print(s8);

  var s9 = 'Chuoi '
            'nay '
            'la '
            '1 chuoi';
            print(s9);
  
}