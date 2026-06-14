import 'package:get_it/get_it.dart';
import 'package:ur_stylist/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ur_stylist/features/auth/data/datasources/auth_location_data_source.dart';
import 'package:ur_stylist/features/auth/data/datasources/auth_location_data_source_impl.dart';
import 'package:ur_stylist/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:ur_stylist/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ur_stylist/features/auth/domain/repositories/auth_repository.dart';
import 'package:ur_stylist/features/auth/domain/usecases/deactivate_acc.dart';
import 'package:ur_stylist/features/auth/domain/usecases/forgot_password.dart';
import 'package:ur_stylist/features/auth/domain/usecases/get_current_location_address.dart'
    as auth_usecases;
import 'package:ur_stylist/features/auth/domain/usecases/get_current_client.dart';
import 'package:ur_stylist/features/auth/domain/usecases/create_customer_address.dart';
import 'package:ur_stylist/features/auth/domain/usecases/reset_password.dart';
import 'package:ur_stylist/features/auth/domain/usecases/send_otp.dart';
import 'package:ur_stylist/features/auth/domain/usecases/sign_in.dart';
import 'package:ur_stylist/features/auth/domain/usecases/sign_out.dart';
import 'package:ur_stylist/features/auth/domain/usecases/sign_up.dart';
import 'package:ur_stylist/features/auth/domain/usecases/update_client_profile.dart';
import 'package:ur_stylist/features/auth/domain/usecases/verify_otp.dart';
import 'package:ur_stylist/features/auth/onboarding/data/datasources/stylist_onboarding_remote_data_source.dart';
import 'package:ur_stylist/features/auth/onboarding/data/datasources/stylist_onboarding_remote_data_source_impl.dart';
import 'package:ur_stylist/features/auth/onboarding/data/repositories/stylist_onboarding_repository_impl.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/repositories/stylist_onboarding_repository.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/get_active_services.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/load_existing_onboarding.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/resend_stylist_otp.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/save_basic_info.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/save_kyc.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/save_professional_details.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/save_stylist_password.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/sign_out_stylist.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/submit_wallet.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/verify_stylist_otp.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/check_startup_session.dart';
import 'package:ur_stylist/features/auth/onboarding/presentation/bloc/stylist_onboarding_bloc.dart';
import 'package:ur_stylist/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ur_stylist/features/home/data/datasources/home_remote_data_source.dart';
import 'package:ur_stylist/features/home/data/datasources/home_remote_data_source_impl.dart';
import 'package:ur_stylist/features/home/data/repositories/home_repository_impl.dart';
import 'package:ur_stylist/features/home/domain/repositories/home_repository.dart';
import 'package:ur_stylist/features/home/domain/usecases/booking_actions.dart';
import 'package:ur_stylist/features/home/domain/usecases/load_home_dashboard.dart';
import 'package:ur_stylist/features/home/presentation/bloc/home_bloc.dart';
import 'package:ur_stylist/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:ur_stylist/features/settings/data/datasources/settings_remote_data_source_impl.dart';
import 'package:ur_stylist/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:ur_stylist/features/settings/domain/repositories/settings_repository.dart';
import 'package:ur_stylist/features/settings/domain/usecases/settings_usecases.dart';
import 'package:ur_stylist/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:ur_stylist/features/shell/presentation/bloc/main_shell_cubit.dart';
import 'package:ur_stylist/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:ur_stylist/features/wallet/data/datasources/wallet_remote_data_source_impl.dart';
import 'package:ur_stylist/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:ur_stylist/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:ur_stylist/features/wallet/domain/usecases/wallet_usecases.dart';
import 'package:ur_stylist/features/wallet/presentation/bloc/wallet_bloc.dart';

final getit = GetIt.instance;
void initDependency() {
  //==================injecting auth data source===================
  getit.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  getit.registerLazySingleton<StylistOnboardingRemoteDataSource>(
    () => StylistOnboardingRemoteDataSourceImpl(),
  );
  getit.registerLazySingleton<AuthLocationDataSource>(
    () => AuthLocationDataSourceImpl(),
  );
  getit.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(),
  );
  getit.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(),
  );
  getit.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(),
  );

  // getit.registerLazySingleton(() => StripeApiService());

  //================== injecting  repository===================
  getit.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getit(), getit()),
  );
  getit.registerLazySingleton<StylistOnboardingRepository>(
    () => StylistOnboardingRepositoryImpl(getit()),
  );
  getit.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(getit()),
  );
  getit.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(getit()),
  );
  getit.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(getit()),
  );

  // ===============injectin use case=================
  // Auth use cases
  getit.registerLazySingleton(() => SignIn(getit()));
  getit.registerLazySingleton(() => SignUp(getit()));
  getit.registerLazySingleton(() => SignOut(getit()));
  getit.registerLazySingleton(() => SendOtp(getit()));
  getit.registerLazySingleton(() => VerifyOTP(getit()));
  getit.registerLazySingleton(
    () => auth_usecases.GetCurrentLocationAddress(getit()),
  );
  getit.registerLazySingleton(() => ForgotPassword(getit()));
  getit.registerLazySingleton(() => ResetPassword(getit()));
  getit.registerLazySingleton(() => GetCurrentCustomer(getit()));
  getit.registerLazySingleton(() => CreateCustomerAddress(getit()));
  getit.registerLazySingleton(() => UpdateCustomerProfile(getit()));
  getit.registerLazySingleton(() => CheckStartupSession(getit()));
  getit.registerLazySingleton(() => LoadExistingOnboarding(getit()));
  getit.registerLazySingleton(() => SaveBasicInfo(getit()));
  getit.registerLazySingleton(() => VerifyStylistOtp(getit()));
  getit.registerLazySingleton(() => ResendStylistOtp(getit()));
  getit.registerLazySingleton(() => SaveKyc(getit()));
  getit.registerLazySingleton(() => GetActiveServices(getit()));
  getit.registerLazySingleton(() => SaveProfessionalDetails(getit()));
  getit.registerLazySingleton(() => SubmitWallet(getit()));
  getit.registerLazySingleton(() => SaveStylistPassword(getit()));
  getit.registerLazySingleton(() => SignOutStylist(getit()));
  getit.registerLazySingleton(() => LoadHomeDashboard(getit()));
  getit.registerLazySingleton(() => AcceptBooking(getit()));
  getit.registerLazySingleton(() => DeclineBooking(getit()));
  getit.registerLazySingleton(() => StartBooking(getit()));
  getit.registerLazySingleton(() => CompleteBooking(getit()));
  getit.registerLazySingleton(() => LoadWalletDashboard(getit()));
  getit.registerLazySingleton(() => SubmitDepositProof(getit()));
  getit.registerLazySingleton(() => RequestWithdrawal(getit()));
  getit.registerLazySingleton(() => LoadSettingsProfile(getit()));
  getit.registerLazySingleton(() => SaveSettingsProfile(getit()));
  getit.registerLazySingleton(() => SaveSettingsAvailability(getit()));
  getit.registerLazySingleton(() => AddSettingsPortfolioPhotos(getit()));
  getit.registerLazySingleton(() => DeleteSettingsPortfolioPhoto(getit()));
  getit.registerLazySingleton(() => SaveSettingsPayoutAccount(getit()));
  getit.registerLazySingleton(() => SaveSettingsPreferences(getit()));
  getit.registerLazySingleton(() => DeactivateAccount(getit()));

  // ===========injectin bloc=================
  getit.registerFactory(
    () => AuthBloc(
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
    ),
  );
  getit.registerFactory(
    () => StylistOnboardingBloc(
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
    ),
  );
  getit.registerFactory(
    () => HomeBloc(getit(), getit(), getit(), getit(), getit(), getit()),
  );
  getit.registerFactory(() => WalletBloc(getit(), getit(), getit()));
  getit.registerFactory(
    () => SettingsBloc(
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
    ),
  );
  getit.registerFactory(() => MainShellCubit());
}
