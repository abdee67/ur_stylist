import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ur_stylist/features/home/presentation/bloc/home_bloc.dart';
import 'package:ur_stylist/features/home/presentation/widgets/service_carousel.dart';
import 'package:ur_stylist/features/home/presentation/widgets/greeting_header.dart';
import 'package:ur_stylist/features/home/presentation/widgets/search_bar.dart';
import 'package:ur_stylist/injection_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeBloc _homeBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _homeBloc = getit<HomeBloc>()..add(LoadHomeData());
      _isInitialized = true;
    }
  }

  bool _isInitialized = false;

  @override
  void initState() {
    _refreshHomeData();
    super.initState();
  }

  void _refreshHomeData() {
    context.read<HomeBloc>().add(LoadHomeData());
  }

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //context.read<HomeBloc>().add(LoadHomeData());
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SafeArea(
        //bottom: false, // Allow content to flow behind the bottom nav bar
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          //padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GreetingHeader(),
              const SizedBox(height: 20),
              const SearchBarWidget(),
              const SizedBox(height: 20),
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoadSuccess) {
                    return RefreshIndicator(
                      onRefresh: () async => _refreshHomeData,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            ServicesCarousel(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  } else if (state is HomeLoadFailure) {
                    return Center(child: Text(state.message));
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
