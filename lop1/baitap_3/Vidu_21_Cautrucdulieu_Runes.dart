void main()
{
  String str = 'Hello';
  Runes runes1 = str.runes;

  Runes runes2 = Runes('\u2665'); //<3
  print(runes2);

  Runes runes3 = Runes('\u{1F600}'); //:)
  print(runes3);

}