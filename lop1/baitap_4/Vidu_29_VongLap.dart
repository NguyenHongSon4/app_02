void main()
{
  //for
  for(var i=1; i<=5; i++)
  {
    print(i);
  }

  //Iterable: List, Set
  //for-in
  var names = ["Nguyen", "Hong", "Son"];
  for (var name in names)
  {
    print(name);
  }

  //while
  var i=5;
  while(i<=5)
  {
    print(i);
    i++;
  }

  //do-while( it nhat 1 lan)
  var x=1;
  do
  {
    print(x);
    x++;
  }while(x<=5);

print('----');
  //break, continue
  var y = 1;
  do
  {
     if(y==3) continue;
    print(y);
    y++;
   
  }while(y<=5);
print('----');
}