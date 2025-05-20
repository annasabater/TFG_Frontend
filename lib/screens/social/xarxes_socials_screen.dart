import 'package:flutter/material.dart';
import 'package:SkyNet/screens/social/explore_screen.dart';
import 'package:SkyNet/screens/social/feed_screen.dart';

class XarxesSocialsScreen extends StatefulWidget {
  const XarxesSocialsScreen({super.key});

  @override
  State<XarxesSocialsScreen> createState() => _XarxesSocialsScreenState();
}

class _XarxesSocialsScreenState extends State<XarxesSocialsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final tabs = ['Explorar', 'Feed'];
  final icons = [Icons.explore_outlined, Icons.dynamic_feed_outlined];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // redibuja cuando cambia de pestaña
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTab(int index) {
  final isSelected = _tabController.index == index;
  final color = isSelected ? Colors.white : Colors.blueGrey.shade800;
  final bg = isSelected ? Colors.blue.shade100 : Colors.blueGrey.shade200;

  return Expanded(
    child: GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icons[index], size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                tabs[index],
                style: TextStyle(fontSize: 13, color: color),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            fontSize: 2,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: List.generate(2, _buildTab),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ExploreScreen(),
          FeedScreen(),
        ],
      ),
    );
  }
}
