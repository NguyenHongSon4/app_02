void main()
{
  Object obj='Hello';
  if(obj is String)
    {
      print('obj la mot String');
    }

  if (obj is! int)
  {
    print("Obj khong phai la so nguyen int");
  }

//Ep kieu
String str = obj as String;
print(str.toUpperCase());
}