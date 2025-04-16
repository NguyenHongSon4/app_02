void main()
{
  var r = ('first', a:2, 5, 10.5);
  var point = (123, 456);
  var person = (name:'Alice', age: 24, 5);

  //Truy cap gia trong records
  //dung chi so
  print(point.$1); //123
  print(point.$2); //456
  print(person.$1);

  //dung ten
  print(person.name);
  print(person.age);

}