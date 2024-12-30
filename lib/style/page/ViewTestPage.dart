

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ViewTestPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _ViewTestPageState();

}

class _ViewTestPageState extends State<ViewTestPage>{
  @override
  Widget build(BuildContext context) {
     return Scaffold(
       body: Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.center,
           children:[
             Text("Test line 1"),
             Text("Test line 2",style: TextStyle(color: Colors.yellow),),
             Icon(Icons.add,color: Colors.yellow,),
             TextField(),
             SizedBox(
                 width: 150,
                 height: 110,
                 child: Image.network("https://img.freepik.com/free-photo/painting-mountain-lake-with-mountain-background_188544-9126.jpg"))
           ]
         ),
       ),
     );
  }

}