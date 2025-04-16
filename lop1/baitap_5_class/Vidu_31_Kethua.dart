class Product{
  double price;
  int quantity;
  String name;
 
  Product(this.price, {this.quantity = 0, this.name=""});
 
  void showTotal(){
    print("Totol price is: ${price*quantity}");
  }
}
 
class Tablet extends Product{
  double width = 0;
  double height = 0;
 
  Tablet(this.width, this.height, double price): super(price, quantity: 1){
    this.name = "Ipad Pro";
  }
 
  @override
  void showTotal() {
    print("Name Tablet sS:  $name");
    super.showTotal();
  }
}
 
void main(){
  var tablet = Tablet(6, 8, 600);
  tablet.showTotal();
}
 
// Abstract, Interface