import 'package:buscador_de_gifs/views/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _filtro;
  int _offset = 0;

  Future<Map> _obterGifs() async {
    http.Response resposta;

    if (_filtro == null || _filtro.isEmpty)
      resposta = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=2sTxBA2bJMcArRAfTYxG3nTlyj08Jt9v&limit=20&rating=G");
    else
      resposta = await http.get("https://api.giphy.com/v1/gifs/search?api_key=2sTxBA2bJMcArRAfTYxG3nTlyj08Jt9v&q=$_filtro&limit=19&offset=$_offset&rating=G&lang=en");
  
    return json.decode(resposta.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquise Aqui:",
                border: OutlineInputBorder(),
                labelStyle: TextStyle(
                  color: Colors.white
                )
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18
              ),
              textAlign: TextAlign.center,
              onSubmitted: (texto) {
                _filtro = texto;
                _offset = 0;

                setState(() {});
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _obterGifs(),
              builder: (contexto, requisicao) {
                switch (requisicao.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                  default:
                    if (requisicao.hasError) return Container();
                    return _criarTabelasGifs(contexto, requisicao);
                }
              }
            )
          )
        ],
      ),
    );
  }

  int _obterTamanho(List dados) {
    if (_filtro == null) {
      return dados.length;
    }

    return dados.length + 1;
  }

  Widget _criarTabelasGifs(BuildContext contexto, AsyncSnapshot requisicao) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10
      ),
      itemCount: _obterTamanho(requisicao.data["data"]),
      itemBuilder: (contexto, indice) {
        if (_filtro == null || indice < requisicao.data["data"].length)
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage, 
              image: requisicao.data["data"][indice]["images"]["fixed_height"]["url"],
              height: 300,
              fit: BoxFit.cover
            ),
            onTap: () {
              Navigator.push(
                contexto, 
                MaterialPageRoute(
                  builder: (contexto) => GifPage(requisicao.data["data"][indice])
                )
              );
            },
            onLongPress: () {
              Share.share(requisicao.data["data"][indice]["images"]["fixed_height"]["url"]);
            },
          );

        return Container(
          child: GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 70,
                ),
                Text(
                  "Carregar mais...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22
                  ),
                )
              ],
            ),
            onTap: () {
              _offset += 19;
              setState(() {});
            },
          ),
        );
      }
    );
  }
}