import "package:flutter/material.dart";

class MyScaffold extends StatelessWidget {
  const MyScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    // Trả về một Scaffold - widget cung cấp bố cục Material Design cơ bản
    return Scaffold(
      // AppBar - thanh ứng dụng ở trên cùng
      appBar: AppBar(
        // Tiêu đề của AppBar
        title: const Text('My Scaffold Demo'),
        // Màu nền của AppBar
        backgroundColor: Colors.blue,
        // Độ nâng (đổ bóng) của AppBar
        elevation: 4,
        // Danh sách các nút hành động bên phải AppBar
        actions: [
          // Nút biểu tượng tìm kiếm
          IconButton(
            onPressed: () {
              print("search");
            },
            icon: const Icon(Icons.search),
          ),
          // Nút biểu tượng ...
          IconButton(
            onPressed: () {
              print("...");
            },
            icon: const Icon(Icons.more_vert),
          ), // Nút biểu tượng ...
          IconButton(
            onPressed: () {
              print("abc");
            },
            icon: const Icon(Icons.abc),
          ),
        ],
      ),

      body: Center(child: Text("Nội dung chính")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("OK");
        },
        child: const Icon(Icons.add),
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

class MyText extends StatelessWidget {
  const MyText({super.key});

  @override
  Widget build(BuildContext context) {
    // Trả về một Scaffold - widget cung cấp bố cục Material Design cơ bản
    return Scaffold(
      // AppBar - thanh ứng dụng ở trên cùng
      appBar: AppBar(
        // Tiêu đề của AppBar
        title: const Text('My Scaffold Demo'),
        // Màu nền của AppBar
        backgroundColor: Colors.red,
        // Độ nâng (đổ bóng) của AppBar
        elevation: 4,
        // Danh sách các nút hành động bên phải AppBar
        actions: [
          // Nút biểu tượng tìm kiếm
          IconButton(
            onPressed: () {
              print("search");
            },
            icon: const Icon(Icons.search),
          ),
          // Nút biểu tượng ...
          IconButton(
            onPressed: () {
              print("...");
            },
            icon: const Icon(Icons.more_vert),
          ), // Nút biểu tượng ...
          IconButton(
            onPressed: () {
              print("abc");
            },
            icon: const Icon(Icons.abc),
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text cơ bản
            const Text("Văn bản thường"),

            const SizedBox(height: 20),

            // Text với style
            Text(
              "Văn bản khác",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Those on board were taken to a hospital, officials said, and three of them were transported to a burn center.'
                  ' Radio transmissions indicated the pilot reported an “open door” just before the crash.',
              style: TextStyle(color: Colors.green, fontSize: 30),
              textAlign: TextAlign.center,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("OK");
        },
        child: const Icon(Icons.add),
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

class MyContainer extends StatelessWidget {
  const MyContainer({super.key});

  @override
  Widget build(BuildContext context) {
    // Trả về một Scaffold - widget cung cấp bố cục Material Design cơ bản
    return Scaffold(
      // AppBar - thanh ứng dụng ở trên cùng
      appBar: AppBar(
        // Tiêu đề của AppBar
        title: const Text('My Scaffold Demo'),
        // Màu nền của AppBar
        backgroundColor: Colors.yellow,
        // Độ nâng (đổ bóng) của AppBar
        elevation: 4,
        // Danh sách các nút hành động bên phải AppBar
        actions: [
          // Nút biểu tượng tìm kiếm
          IconButton(
            onPressed: () {
              print("search");
            },
            icon: const Icon(Icons.search),
          ),
          // Nút biểu tượng ...
          IconButton(
            onPressed: () {
              print("...");
            },
            icon: const Icon(Icons.more_vert),
          ), // Nút biểu tượng ...
          IconButton(
            onPressed: () {
              print("abc");
            },
            icon: const Icon(Icons.abc),
          ),
        ],
      ),

      body: Center(
        child: Container(
          width: 300,
          height: 300,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Align(
            alignment: Alignment.center,
            child: const Text(
              "Container with BoxDecoration <3",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("OK");
        },
        child: const Icon(Icons.add),
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

class MyColumnAndRow extends StatelessWidget {
  const MyColumnAndRow({super.key});

  @override
  Widget build(BuildContext context) {
    // Trả về một Scaffold - widget cung cấp bố cục Material Design cơ bản
    return Scaffold(
      // AppBar - thanh ứng dụng ở trên cùng
      appBar: AppBar(
        // Tiêu đề của AppBar
        title: const Text('My Scaffold Demo'),
        // Màu nền của AppBar
        backgroundColor: Colors.blue,
        // Độ nâng (đổ bóng) của AppBar
        elevation: 4,
        // Danh sách các nút hành động bên phải AppBar
        actions: [
          // Nút biểu tượng tìm kiếm
          IconButton(
            onPressed: () {
              print("search");
            },
            icon: const Icon(Icons.search),
          ),
          // Nút biểu tượng ...
          IconButton(
            onPressed: () {
              print("...");
            },
            icon: const Icon(Icons.more_vert),
          ), // Nút biểu tượng ...
          IconButton(
            onPressed: () {
              print("abc");
            },
            icon: const Icon(Icons.abc),
          ),
        ],
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Container(width: 50, height: 50, color: Colors.red),
              Container(width: 50, height: 50, color: Colors.blue),
              Container(width: 50, height: 50, color: Colors.grey),
            ],
          ),
          // Column lồng trong Column chính
          Column(
            children: [
              Container(
                width: 100,
                height: 50,
                color: Colors.orange,
                margin: const EdgeInsets.symmetric(vertical: 10),
              ),
              Container(
                width: 100,
                height: 50,
                color: Colors.amberAccent,
                margin: const EdgeInsets.symmetric(vertical: 10),
              ),
            ],
          ),
          // Row với các thuộc tính khác nhau
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 100,
                color: Colors.amber,
              ),
              const SizedBox(width: 10),
              Container(
                width: 50,
                height: 50,
                color: Colors.pink,
              ),
              const SizedBox(width: 10),
              Container(
                width: 50,
                height: 150,
                color: Colors.brown,
              ),
            ],
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("OK");
        },
        child: const Icon(Icons.add),
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