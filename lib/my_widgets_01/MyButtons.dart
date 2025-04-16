import "package:flutter/material.dart";

class MyButtons extends StatelessWidget {
  const MyButtons({super.key});

  @override
  Widget build(BuildContext context) {
    // Tra ve Scaffold - widget cung cap bo cuc Material Design co ban
    // Man hinh
    return Scaffold(
      // Tiêu đề của ứng dụng
      appBar: AppBar(
        // Tieu de
        title: Text("App 02"),
        // Mau nen
        backgroundColor: Colors.blue,
        // Do nang/ do bong cua AppBar
        elevation: 4,
        actions: [
          IconButton(
            onPressed: () {
              print("b1");
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              print("b2");
            },
            icon: Icon(Icons.abc),
          ),
          IconButton(
            onPressed: () {
              print("b3");
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),

      body: Center(
          child: Column(
              children: [
                // Tao mot khoang cach
                SizedBox(height: 50,),
                // Text co ban
                ElevatedButton(onPressed: () {
                  print("Click here!");
                },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                  ),
                  child: Text("Click here!", style: TextStyle(fontSize: 22)),
                ),
                SizedBox(height: 20),
                TextButton(onPressed: () {},
                    child: Text("Button 2", style: TextStyle(fontSize: 24),
                    )
                ),

                SizedBox(height: 20),
                TextButton(onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,

                    ),
                    child: Text("Button 3", style: TextStyle(fontSize: 24)),
                ),

                SizedBox(height: 20),
                IconButton(onPressed: (){}, icon: Icon(Icons.add)
                ),

                SizedBox(height: 20),
                FloatingActionButton(onPressed: (){}, child: Icon(Icons.favorite),
                ),

                SizedBox(height: 20),
                ElevatedButton(onPressed: (){
                  print("Click ME!!");
                },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 10,
                  ),
                    child: Text("Click ME!!", style: TextStyle(fontSize: 24)),
                ),

                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: (){},
                  icon: Icon(Icons.favorite),
                 label: Text("Yêu Thích"),
                ),

                SizedBox(height: 20),
                TextButton.icon(
                  onPressed: (){},
                  icon: Icon(Icons.favorite),
                  label: Text("Yêu Thích"),
                ),
                
                InkWell(
                  onTap: (){
                    print("Inkwell được nhấn!");
                  },
                  splashColor: Colors.blue.withOpacity(0.5),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical:10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text("Button tùy chỉnh với InkWell, nhấn thử nhé!"),
                  ),
                )
              ]
          )),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("pressed");
        },
        child: const Icon(Icons.add_ic_call),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Tìm kiếm"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Cá nhân"),
        ],
      ),
    );
  }
}
