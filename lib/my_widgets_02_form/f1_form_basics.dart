import 'package:flutter/material.dart';

class FormBasicDemo extends StatefulWidget{
  const FormBasicDemo({super.key});

  @override
  State<StatefulWidget> createState() => _FormBasicDemoSate();
}

class _FormBasicDemoSate extends State<FormBasicDemo>{
  //Su dung Global key de truy cap form
  final _formKey = GlobalKey<FormState>();
  String? _name;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Form cơ bản"),
      ),

      body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Họ & tên",
                      hintText: "Nhập họ tên của bạn",
                      border: OutlineInputBorder()
                    ),
                  ),

                  SizedBox(height: 20,),
                  Row(
                    children: [
                      ElevatedButton(onPressed: (){
                        if(_formKey.currentState!.validate()){
                          _formKey.currentState!.save();
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Xin chào $_name"))
                          );
                        }
                      }, child: Text("Submit")),
                      SizedBox(width: 20,),
                      ElevatedButton(onPressed: (){
                        _formKey.currentState!.reset();
                        setState(() {
                          _name = null;
                        });
                      }, child: Text("Reset")),
                    ],
                  )
                ],
              )
          ),
      ),
    );
  }
}
