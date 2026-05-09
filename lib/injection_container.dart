import 'package:get_it/get_it.dart';
import 'package:ur_stylist/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ur_stylist/features/auth/data/datasources/auth_location_data_source.dart';
import 'package:ur_stylist/features/auth/data/datasources/auth_location_data_source_impl.dart';
import 'package:ur_stylist/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:ur_stylist/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ur_stylist/features/auth/domain/repositories/auth_repository.dart';
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
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/sign_out_stylist.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/submit_wallet.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/usecases/verify_stylist_otp.dart';
import 'package:ur_stylist/features/auth/onboarding/presentation/bloc/stylist_onboarding_bloc.dart';
import 'package:ur_stylist/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ur_stylist/features/home/presentation/bloc/home_bloc.dart';

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

  // getit.registerLazySingleton(() => StripeApiService());

  //================== injecting  repository===================
  getit.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getit(), getit()),
  );
  getit.registerLazySingleton<StylistOnboardingRepository>(
    () => StylistOnboardingRepositoryImpl(getit()),
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
  getit.registerLazySingleton(() => LoadExistingOnboarding(getit()));
  getit.registerLazySingleton(() => SaveBasicInfo(getit()));
  getit.registerLazySingleton(() => VerifyStylistOtp(getit()));
  getit.registerLazySingleton(() => ResendStylistOtp(getit()));
  getit.registerLazySingleton(() => SaveKyc(getit()));
  getit.registerLazySingleton(() => GetActiveServices(getit()));
  getit.registerLazySingleton(() => SaveProfessionalDetails(getit()));
  getit.registerLazySingleton(() => SubmitWallet(getit()));
  getit.registerLazySingleton(() => SignOutStylist(getit()));

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
    ),
  );
  getit.registerFactory(() => HomeBloc());
}
