import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantController = TextEditingController();
  List<Map<String, dynamic>> _items = [];

  @override
  void initState(){
    super.initState();
    _refreshItems();
  }


  Future<void> _createItem(Map<String, dynamic> map) async{
    await _demoBox.add(map);
  }

  Future<void> _updateItem(Map<String, dynamic> map, int itemKey) async{
    await _demoBox.put(itemKey, map);
    _refreshItems();
  }

  Future<void> _deleteItem(int item) async{
    await _demoBox.delete(item);
    _refreshItems();

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item has been deleted")),
    );
  }
  void _refreshItems(){
    final data = _demoBox.keys.map((key){
      final item = _demoBox.get(key);

      return {"key":key, "name":item['name'], "quant":item['quant']};
    }).toList();

    setState(() {
      _items = data.reversed.toList();
    });
  }
  final _demoBox = Hive.box('demoBox');

  void _showForm(BuildContext ctx, int? itemKey) async{
    if(itemKey!=null){
      final existingItem = _items.firstWhere((element) => element['key']==itemKey);
      _nameController.text = existingItem['name'];
      _quantController.text = existingItem['quant'];
    }else{
      _nameController.text = '';
      _quantController.text = '';
    }
    SizedBox(height: 100,);
    showModalBottomSheet(
    context: context,
    elevation: 5,
    isScrollControlled: true, 
    builder: (_) => Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom,
        top: 15,
        left: 15,
        right: 15,
      ),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'name'),
          ),
          SizedBox(height: 10,),

          TextField(
            controller: _quantController,
            decoration: const InputDecoration(hintText: "Enter quant"),
          ),
          SizedBox(height: 10,),

          ElevatedButton(
            onPressed: () async{
              if(itemKey!=null){
                _updateItem({"name":_nameController.text,  "quant": _quantController.text}, itemKey);
              }else{
                _createItem({"name":_nameController.text,  "quant": _quantController.text});
                _nameController.text = '';
                _quantController.text = '';
                _refreshItems();
              }
            Navigator.of(context).pop();
          }, 
          
          child: itemKey == null ? const Text("Create new") : const Text("Update"),
          ),

          
        ],
      ),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Hive demo APP'),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (_, index){
          final curItem = _items[index];
          return Card(
            color: Colors.amberAccent,
            child: ListTile(
              title: Text(curItem['name']),
              subtitle: Text(curItem['quant'].toString()),
              trailing:  Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: (){
                      _showForm(context, curItem['key']);
                    }, 
                    icon: const Icon(Icons.edit)
                    ),
                    IconButton(
                    onPressed: (){
                      _deleteItem(curItem['key']);
                    }, 
                    icon: const Icon(Icons.delete, color: Colors.red,)
                    ),
                ],
              ),
            ),
          );
        }
        
        ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          _showForm(context, null);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          ),
      ),
    );
  }
}