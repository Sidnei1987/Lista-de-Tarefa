import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List  _listaTarefas = [];
  Map <String, dynamic> _ultimaTarefaRemovida = Map();
  TextEditingController _controllerTarefa = TextEditingController();

   Future<File> _getFile() async {

    final diretorio = await getApplicationDocumentsDirectory();
    return File( "${diretorio.path}/dados.json" );

  }
  _salvarTarefa(){

     String textoDigitado = _controllerTarefa.text;

     Map<String, dynamic> tarefa = Map();
     tarefa ["titulo"] = textoDigitado;
     tarefa ["realizada"] = false;

     setState(() {
       _listaTarefas.add(tarefa);
     });
     _salvarArquivo();
     _controllerTarefa.text = "";

  }

  _salvarArquivo() async {

    var arquivo = await _getFile();

    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString( dados );


  }

  _lerArquivo() async {

    try{

      final arquivo = await _getFile();
      return arquivo.readAsString();

    }catch(e){
       return null;
    }

  }
   @override
  void initState() {
    super.initState();
    _lerArquivo().then( (dados){
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    } );
  }

  Widget criarItemLista (context, index){

     final item = _listaTarefas[index] ["titulo"];

    return Dismissible(
        key: Key (DateTime.now().microsecondsSinceEpoch.toString() ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction){

          //recuperar ultimo item excluido
          _ultimaTarefaRemovida = _listaTarefas[index];

          //Remove item da lista
          _listaTarefas.removeAt(index);
          _salvarArquivo();

          //snackbar
          final snackbar  = SnackBar(
            //backgroundColor: Colors.red, // para muda a cor do alerta
            duration: Duration(seconds: 5), // duração de tempo para ele sumi
              content: Text("Tarefa removida"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: (){
                setState(() {
                  //desfazer a ação de item removido
                  _listaTarefas.insert(index, _ultimaTarefaRemovida);
                });


                _salvarArquivo();

              },
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackbar);

        },
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children:<Widget> [
              Icon(
                  Icons.delete,
                color: Colors.white,
              )
            ],
          ),
        ),
        child: CheckboxListTile(

          value: _listaTarefas [index] ["realizada"],

          onChanged: (valorAlterado){
            setState(() {
              _listaTarefas [index] ["realizada"] = valorAlterado;
            });
            _salvarArquivo();
            // print("valor: " + valorAlterado.toString() );
          },

          title: Text (_listaTarefas[index]['titulo']) ,
        )
    );

  }

  @override
  Widget build(BuildContext context) {

    //_salvarAriquivo();

    return Scaffold(
      appBar: AppBar(
          title: Text("Lista de tarefa"),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,// deixa o botão centralizado
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 6,
        child: Icon(Icons.add),
        onPressed: (){
          
          showDialog(
              context: context,
              builder: (context){

                return AlertDialog(
                  title: Text("adicionar tarefa"),
                  content: TextField(
                    controller: _controllerTarefa,
                    decoration: InputDecoration(
                      labelText: "Digite sua tarefa"
                    ),
                    onChanged: (text){

                    },
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancelar")
                    ),

                    ElevatedButton(
                        onPressed: (){
                          //salvar
                          _salvarTarefa();
                          Navigator.pop(context);
                        },
                        child: Text("Salvar")
                    ),
                  ],
                );
              },
          );
        },
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
                itemCount: _listaTarefas.length,
                  itemBuilder: criarItemLista
              ),
          ),
        ],
      ),
      // bottomNavigationBar: BottomAppBar(
      //   shape: CircularNotchedRectangle(),//para fazer um integração de armonia entre botãoNaviBar e o floatBotao
      //   child: Row(
      //     children: <Widget>[
      //       IconButton(
      //           onPressed: (){},
      //           icon: Icon(Icons.menu)
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
