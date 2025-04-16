
typedef IntList = List<int>;
typedef ListMapper<X> =  Map<X, List<X>>;

void main()
{
  IntList l1 = [1,2,3,4,5];
  print(l1);

  IntList l2 = [1,2,3,4,5,6,7];
  print(l2);

  IntList l3 = [8,9,10,11];
  print(l3);

  Map<String, List<String>> m1 = {};
  ListMapper<String> m2 = {};
}