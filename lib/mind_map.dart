import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: MindMapPage()));
}

class MindMapPage extends StatefulWidget {
  const MindMapPage({Key? key}) : super(key: key);

  @override
  State<MindMapPage> createState() => _MindMapPageState();
}

class _MindMapPageState extends State<MindMapPage> {
  List<_Node> nodes = [];

  void _addNode(Offset position) {
    setState(() {
      nodes.add(_Node(id: UniqueKey(), position: position));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind Map'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(1000),
        minScale: 0.5,
        maxScale: 3,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: (TapUpDetails details) {
            final Offset tapPosition = details.localPosition;
            _addNode(tapPosition);
          },
          child: Stack(
            children: nodes.map((node) => _buildNode(node)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNode(_Node node) {
    return Positioned(
      left: node.position.dx - 50,
      top: node.position.dy - 50,
      child: Draggable<_Node>(
        data: node,
        feedback: _NodeWidget(),
        childWhenDragging: const SizedBox.shrink(),
        onDragEnd: (details) {
          setState(() {
            node.position = details.offset;
          });
        },
        child: _NodeWidget(),
      ),
    );
  }
}

class _Node {
  final Key id;
  Offset position;

  _Node({required this.id, required this.position});
}

class _NodeWidget extends StatelessWidget {
  const _NodeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        color: Colors.lightBlueAccent,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'Node',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
