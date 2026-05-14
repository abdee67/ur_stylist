import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ur_stylist/features/home/presentation/bloc/home_bloc.dart';
import 'package:ur_stylist/features/home/presentation/pages/home_page.dart';
import 'package:ur_stylist/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:ur_stylist/features/settings/presentation/pages/settings_page.dart';
import 'package:ur_stylist/features/shell/presentation/bloc/main_shell_cubit.dart';
import 'package:ur_stylist/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:ur_stylist/features/wallet/presentation/pages/wallet_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHomeData());
    context.read<WalletBloc>().add(const WalletStarted());
    context.read<SettingsBloc>().add(const SettingsStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainShellCubit, int>(
      builder: (context, index) {
        return BlocBuilder<HomeBloc, HomeState>(
          builder: (context, homeState) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              body: IndexedStack(
                index: index,
                children: const [HomePage(), WalletPage(), SettingsPage()],
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: index,
                onTap: context.read<MainShellCubit>().setTab,
                selectedItemColor: Colors.pink,
                items: [
                  BottomNavigationBarItem(
                    icon: _BadgedIcon(
                      icon: Iconsax.calendar_1,
                      count: homeState.pendingCount,
                    ),
                    label: 'Home',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Iconsax.wallet_2),
                    label: 'Wallet',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Iconsax.setting_2),
                    label: 'Settings',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _BadgedIcon extends StatelessWidget {
  final IconData icon;
  final int count;

  const _BadgedIcon({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -8,
            top: -8,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: Colors.red,
              child: Text(
                count > 9 ? '9+' : '$count',
                style: const TextStyle(color: Colors.white, fontSize: 9),
              ),
            ),
          ),
      ],
    );
  }
}
