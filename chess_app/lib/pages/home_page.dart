import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Automated Chess App", 
            style: GoogleFonts.lato()
          ),
          centerTitle: true,
          backgroundColor: Colors.lightGreen,  
        ),
        body: Center(
          child: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        "https://images.chesscomfiles.com/uploads/v1/chess_term/448a4fda-07bb-11ed-a1cf-49f9647914b8.10b09be0.630x354o.d30cf282395b@2x.png"),
                    fit: BoxFit.cover
                  ),
              ),
          ),
        ));
  }
}
