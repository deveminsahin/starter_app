// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:chopper/chopper.dart' as _i31;
import 'package:flutter/material.dart' as _i409;
import 'package:flutter_bloc/flutter_bloc.dart' as _i331;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:go_router/go_router.dart' as _i583;
import 'package:hydrated_bloc/hydrated_bloc.dart' as _i67;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:starter_app/app/view/app.dart' as _i508;
import 'package:starter_app/core/api/interceptors/network_error_handler.dart'
    as _i390;
import 'package:starter_app/core/application/app_error_handling_service.dart'
    as _i287;
import 'package:starter_app/core/application/app_monitoring_service.dart'
    as _i329;
import 'package:starter_app/core/application/bootstrap_service.dart' as _i715;
import 'package:starter_app/core/di/modules/bloc_module.dart' as _i728;
import 'package:starter_app/core/di/modules/error_module.dart' as _i895;
import 'package:starter_app/core/di/modules/logging_module.dart' as _i216;
import 'package:starter_app/core/di/modules/navigation_module.dart' as _i874;
import 'package:starter_app/core/di/modules/network_module.dart' as _i823;
import 'package:starter_app/core/di/modules/platform_module.dart' as _i815;
import 'package:starter_app/core/di/modules/storage_module.dart' as _i513;
import 'package:starter_app/core/domain/base/event_dispatcher.dart' as _i696;
import 'package:starter_app/core/domain/ports/i_certificate_service.dart'
    as _i787;
import 'package:starter_app/core/domain/ports/i_data_filter.dart' as _i439;
import 'package:starter_app/core/domain/ports/i_error_reporter.dart' as _i449;
import 'package:starter_app/core/domain/ports/i_monitoring_initializer.dart'
    as _i752;
import 'package:starter_app/core/domain/ports/i_platform_info.dart' as _i314;
import 'package:starter_app/core/domain/ports/i_secure_storage.dart' as _i663;
import 'package:starter_app/core/domain/ports/i_session_manager.dart' as _i65;
import 'package:starter_app/core/domain/ports/i_token_refresh_notifier.dart'
    as _i533;
import 'package:starter_app/core/domain/ports/i_token_storage.dart' as _i170;
import 'package:starter_app/core/domain/ports/i_websocket_manager.dart'
    as _i354;
import 'package:starter_app/core/domain/ports/ports.dart' as _i944;
import 'package:starter_app/core/error/exception_handler.dart' as _i1007;
import 'package:starter_app/core/error/sensitive_data_filter.dart' as _i458;
import 'package:starter_app/core/feature_flags/feature_flag_service.dart'
    as _i1025;
import 'package:starter_app/core/feature_flags/i_feature_flag_service.dart'
    as _i185;
import 'package:starter_app/core/infrastructure/circuit_breaker/circuit_breaker_config.dart'
    as _i448;
import 'package:starter_app/core/infrastructure/error/sentry_monitoring_initializer.dart'
    as _i245;
import 'package:starter_app/core/infrastructure/security/certificate_service.dart'
    as _i55;
import 'package:starter_app/core/infrastructure/session/session_manager_impl.dart'
    as _i79;
import 'package:starter_app/core/infrastructure/storage/secure_storage_impl.dart'
    as _i629;
import 'package:starter_app/core/infrastructure/storage/token_storage_impl.dart'
    as _i1047;
import 'package:starter_app/core/infrastructure/token/token_refresh_notifier_impl.dart'
    as _i540;
import 'package:starter_app/core/infrastructure/websocket/websocket_manager.dart'
    as _i944;
import 'package:starter_app/core/logging/i_app_logger.dart' as _i632;
import 'package:starter_app/core/navigation/app_router.dart' as _i954;
import 'package:starter_app/core/navigation/auth_change_notifier.dart' as _i247;
import 'package:starter_app/core/navigation/page_builder.dart' as _i18;
import 'package:starter_app/core/presentation/bloc/bloc.dart' as _i455;
import 'package:starter_app/core/presentation/failure_message/email_failure_mapper.dart'
    as _i1023;
import 'package:starter_app/core/presentation/failure_message/failure_mapper_registry.dart'
    as _i184;
import 'package:starter_app/core/presentation/failure_message/infrastructure_failure_mapper.dart'
    as _i659;
import 'package:starter_app/core/presentation/failure_message/name_failure_mapper.dart'
    as _i91;
import 'package:starter_app/core/presentation/failure_message/password_failure_mapper.dart'
    as _i270;
import 'package:starter_app/core/presentation/services/failure_message_service.dart'
    as _i313;
import 'package:starter_app/core/theme/app_theme.dart' as _i238;
import 'package:starter_app/features/auth/application/usecases/check_user_exists.dart'
    as _i12;
import 'package:starter_app/features/auth/application/usecases/get_current_user.dart'
    as _i23;
import 'package:starter_app/features/auth/application/usecases/login.dart'
    as _i505;
import 'package:starter_app/features/auth/application/usecases/logout.dart'
    as _i718;
import 'package:starter_app/features/auth/application/usecases/refresh_token.dart'
    as _i368;
import 'package:starter_app/features/auth/application/usecases/register.dart'
    as _i482;
import 'package:starter_app/features/auth/application/usecases/watch_auth_changes.dart'
    as _i266;
import 'package:starter_app/features/auth/application/usecases/watch_session_expired.dart'
    as _i635;
import 'package:starter_app/features/auth/domain/repositories/i_auth_repository.dart'
    as _i870;
import 'package:starter_app/features/auth/domain/services/user_registration_service.dart'
    as _i772;
import 'package:starter_app/features/auth/infrastructure/datasources/auth_api_service.dart'
    as _i986;
import 'package:starter_app/features/auth/infrastructure/datasources/auth_remote_data_source.dart'
    as _i737;
import 'package:starter_app/features/auth/infrastructure/datasources/auth_websocket_data_source.dart'
    as _i394;
import 'package:starter_app/features/auth/infrastructure/mappers/auth_exception_mapper.dart'
    as _i161;
import 'package:starter_app/features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i889;
import 'package:starter_app/features/auth/presentation/bloc/auth_bloc.dart'
    as _i55;
import 'package:starter_app/features/auth/presentation/failure_message/auth_failure_mapper.dart'
    as _i984;
import 'package:starter_app/features/profile/application/usecases/get_profile.dart'
    as _i0;
import 'package:starter_app/features/profile/domain/repositories/i_user_profile_repository.dart'
    as _i148;
import 'package:starter_app/features/profile/infrastructure/datasources/profile_api_service.dart'
    as _i927;
import 'package:starter_app/features/profile/infrastructure/datasources/user_profile_remote_data_source.dart'
    as _i937;
import 'package:starter_app/features/profile/infrastructure/mappers/profile_exception_mapper.dart'
    as _i458;
import 'package:starter_app/features/profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i45;
import 'package:starter_app/features/profile/presentation/bloc/profile_bloc.dart'
    as _i493;
import 'package:starter_app/features/profile/presentation/failure_message/profile_failure_mapper.dart'
    as _i873;
import 'package:synchronized/synchronized.dart' as _i409;

const String _development = 'development';
const String _staging = 'staging';
const String _production = 'production';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    final storageModule = _$StorageModule();
    final blocModule = _$BlocModule();
    final platformModule = _$PlatformModule();
    final navigationModule = _$NavigationModule();
    final loggingModule = _$LoggingModule();
    final errorModule = _$ErrorModule();
    gh.factory<_i161.AuthExceptionMapper>(
      () => const _i161.AuthExceptionMapper(),
    );
    gh.factory<_i458.ProfileExceptionMapper>(
      () => const _i458.ProfileExceptionMapper(),
    );
    gh.singleton<_i409.Lock>(() => networkModule.provideTokenRefreshLock());
    gh.singleton<_i448.CircuitBreakerConfig>(
      () => networkModule.provideCircuitBreakerConfig(),
    );
    await gh.singletonAsync<_i67.HydratedStorage>(
      () => storageModule.provideHydratedStorage(),
      preResolve: true,
    );
    gh.singleton<_i184.FailureMapperRegistry>(
      () => _i184.FailureMapperRegistry(),
    );
    gh.singleton<_i238.AppTheme>(() => const _i238.AppTheme());
    gh.lazySingleton<_i455.ThemeCubit>(() => blocModule.provideThemeCubit());
    gh.lazySingleton<_i455.LocaleCubit>(() => blocModule.provideLocaleCubit());
    gh.lazySingleton<_i390.NetworkErrorHandler>(
      () => networkModule.provideNetworkErrorHandler(),
    );
    gh.lazySingleton<_i314.IPlatformInfo>(
      () => platformModule.providePlatformInfo(),
    );
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => storageModule.provideSharedPreferences(),
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => storageModule.provideFlutterSecureStorage(),
    );
    gh.lazySingleton<_i1007.ExceptionHandler>(
      () => const _i1007.ExceptionHandler(),
    );
    gh.lazySingleton<_i752.IMonitoringInitializer>(
      () => const _i245.SentryMonitoringInitializer(),
    );
    gh.singleton<_i533.ITokenRefreshNotifier>(
      () => _i540.TokenRefreshNotifierImpl(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i409.NavigatorObserver>(
      () => navigationModule.provideAppRouterObserver(),
    );
    gh.lazySingleton<_i439.IDataFilter>(
      () => const _i458.SensitiveDataFilter(),
    );
    gh.singleton<String>(
      () => networkModule.provideWebSocketBaseUrl(),
      instanceName: 'websocketBaseUrl',
    );
    gh.lazySingleton<_i696.IEventDispatcher>(
      () => _i696.EventDispatcher(),
      dispose: (i) => i.dispose(),
    );
    gh.singleton<_i65.ISessionManager>(
      () => _i79.SessionManagerImpl(),
      dispose: (i) => i.dispose(),
    );
    gh.singleton<_i18.PageBuilder>(() => navigationModule.providePageBuilder());
    gh.lazySingleton<_i632.IAppLogger>(
      () => loggingModule.provideLogger(),
      registerFor: {_development, _staging, _production},
    );
    gh.lazySingleton<_i449.IErrorReporter>(
      () => errorModule.provideDevelopmentReporter(),
      registerFor: {_development},
    );
    gh.lazySingleton<_i185.IFeatureFlagService>(
      () => _i1025.FeatureFlagService(gh<_i632.IAppLogger>()),
    );
    gh.singleton<_i787.ICertificateService>(
      () => _i55.CertificateService(gh<_i632.IAppLogger>()),
    );
    gh.lazySingleton<_i663.ISecureStorage>(
      () => _i629.SecureStorageImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i449.IErrorReporter>(
      () => errorModule.provideStagingReporter(gh<_i439.IDataFilter>()),
      registerFor: {_staging, _production},
    );
    gh.factory<_i873.ProfileFailureMapper>(
      () => _i873.ProfileFailureMapper(gh<_i184.FailureMapperRegistry>()),
    );
    gh.singleton<_i1023.EmailFailureMapper>(
      () => _i1023.EmailFailureMapper(gh<_i184.FailureMapperRegistry>()),
    );
    gh.singleton<_i659.InfrastructureFailureMapper>(
      () =>
          _i659.InfrastructureFailureMapper(gh<_i184.FailureMapperRegistry>()),
    );
    gh.singleton<_i91.NameFailureMapper>(
      () => _i91.NameFailureMapper(gh<_i184.FailureMapperRegistry>()),
    );
    gh.singleton<_i270.PasswordFailureMapper>(
      () => _i270.PasswordFailureMapper(gh<_i184.FailureMapperRegistry>()),
    );
    gh.singleton<_i984.AuthFailureMessageMapper>(
      () => _i984.AuthFailureMessageMapper(gh<_i184.FailureMapperRegistry>()),
    );
    gh.singleton<_i944.ICircuitBreaker>(
      () => networkModule.provideCircuitBreaker(
        gh<_i632.IAppLogger>(),
        gh<_i448.CircuitBreakerConfig>(),
      ),
    );
    gh.lazySingleton<_i329.AppMonitoringService>(
      () => _i329.AppMonitoringService(
        gh<_i632.IAppLogger>(),
        gh<_i449.IErrorReporter>(),
        gh<_i314.IPlatformInfo>(),
        gh<_i752.IMonitoringInitializer>(),
      ),
    );
    gh.lazySingleton<_i313.FailureMessageService>(
      () => _i313.FailureMessageService(
        gh<_i184.FailureMapperRegistry>(),
        gh<_i632.IAppLogger>(),
      ),
    );
    gh.factory<_i635.WatchSessionExpired>(
      () => _i635.WatchSessionExpired(gh<_i65.ISessionManager>()),
    );
    gh.lazySingleton<_i170.ITokenStorage>(
      () => _i1047.TokenStorageImpl(gh<_i663.ISecureStorage>()),
    );
    gh.lazySingleton<_i354.IWebSocketManager>(
      () => _i944.WebSocketManager(
        gh<String>(instanceName: 'websocketBaseUrl'),
        gh<_i632.IAppLogger>(),
      ),
    );
    gh.singleton<_i331.BlocObserver>(
      () => blocModule.provideBlocObserver(gh<_i632.IAppLogger>()),
    );
    gh.lazySingleton<_i287.AppErrorHandlingService>(
      () => _i287.AppErrorHandlingService(
        gh<_i632.IAppLogger>(),
        gh<_i449.IErrorReporter>(),
      ),
    );
    gh.singleton<_i31.ChopperClient>(
      () => networkModule.provideChopperClient(
        gh<_i632.IAppLogger>(),
        gh<_i390.NetworkErrorHandler>(),
        gh<_i944.ITokenStorage>(),
        gh<_i944.ISessionManager>(),
        gh<_i944.ITokenRefreshNotifier>(),
        gh<_i409.Lock>(),
        gh<_i944.ICircuitBreaker>(),
        gh<_i944.ICertificateService>(),
      ),
    );
    gh.singleton<_i715.BootstrapService>(
      () => _i715.BootstrapService(
        gh<_i67.HydratedStorage>(),
        gh<_i67.BlocObserver>(),
        gh<_i329.AppMonitoringService>(),
        gh<_i287.AppErrorHandlingService>(),
        gh<_i787.ICertificateService>(),
      ),
    );
    gh.lazySingleton<_i986.AuthApiService>(
      () => _i986.AuthApiService.create(gh<_i31.ChopperClient>()),
    );
    gh.lazySingleton<_i927.ProfileApiService>(
      () => _i927.ProfileApiService.create(gh<_i31.ChopperClient>()),
    );
    gh.lazySingleton<_i394.IAuthWebSocketDataSource>(
      () => _i394.AuthWebSocketDataSource(
        gh<_i354.IWebSocketManager>(),
        gh<_i170.ITokenStorage>(),
        gh<_i533.ITokenRefreshNotifier>(),
        gh<_i632.IAppLogger>(),
      ),
    );
    gh.lazySingleton<_i937.IUserProfileRemoteDataSource>(
      () =>
          _i937.UserProfileRemoteDataSourceImpl(gh<_i927.ProfileApiService>()),
    );
    gh.lazySingleton<_i737.IAuthRemoteDataSource>(
      () => _i737.AuthRemoteDataSourceImpl(gh<_i986.AuthApiService>()),
    );
    gh.lazySingleton<_i148.IUserProfileRepository>(
      () => _i45.UserProfileRepositoryImpl(
        gh<_i937.IUserProfileRemoteDataSource>(),
        gh<_i1007.ExceptionHandler>(),
        gh<_i458.ProfileExceptionMapper>(),
      ),
    );
    gh.lazySingleton<_i870.IAuthRepository>(
      () => _i889.AuthRepositoryImpl(
        gh<_i737.IAuthRemoteDataSource>(),
        gh<_i394.IAuthWebSocketDataSource>(),
        gh<_i170.ITokenStorage>(),
        gh<_i1007.ExceptionHandler>(),
        gh<_i161.AuthExceptionMapper>(),
      ),
    );
    gh.factory<_i12.CheckUserExists>(
      () => _i12.CheckUserExists(gh<_i870.IAuthRepository>()),
    );
    gh.factory<_i718.Logout>(() => _i718.Logout(gh<_i870.IAuthRepository>()));
    gh.factory<_i368.RefreshTokenUseCase>(
      () => _i368.RefreshTokenUseCase(gh<_i870.IAuthRepository>()),
    );
    gh.factory<_i266.WatchAuthChanges>(
      () => _i266.WatchAuthChanges(gh<_i870.IAuthRepository>()),
    );
    gh.factory<_i0.GetProfile>(
      () => _i0.GetProfile(gh<_i148.IUserProfileRepository>()),
    );
    gh.factory<_i772.UserRegistrationService>(
      () => _i772.UserRegistrationService(
        gh<_i870.IAuthRepository>(),
        gh<_i696.IEventDispatcher>(),
      ),
    );
    gh.factory<_i482.Register>(
      () => _i482.Register(gh<_i772.UserRegistrationService>()),
    );
    gh.factory<_i493.ProfileBloc>(
      () =>
          _i493.ProfileBloc(gh<_i0.GetProfile>(), gh<_i696.IEventDispatcher>()),
    );
    gh.factory<_i23.GetCurrentUser>(
      () => _i23.GetCurrentUser(
        gh<_i870.IAuthRepository>(),
        gh<_i696.IEventDispatcher>(),
      ),
    );
    gh.factory<_i505.Login>(
      () => _i505.Login(
        gh<_i870.IAuthRepository>(),
        gh<_i696.IEventDispatcher>(),
      ),
    );
    gh.factory<_i55.AuthBloc>(
      () => _i55.AuthBloc(
        gh<_i12.CheckUserExists>(),
        gh<_i505.Login>(),
        gh<_i482.Register>(),
        gh<_i718.Logout>(),
        gh<_i23.GetCurrentUser>(),
        gh<_i266.WatchAuthChanges>(),
        gh<_i635.WatchSessionExpired>(),
        gh<_i632.IAppLogger>(),
      ),
    );
    gh.lazySingleton<_i247.AuthChangeNotifier>(
      () => _i247.AuthChangeNotifier(gh<_i55.AuthBloc>()),
    );
    gh.lazySingleton<_i954.AppRouter>(
      () => _i954.AppRouter(
        gh<_i409.NavigatorObserver>(),
        gh<_i18.PageBuilder>(),
        gh<_i247.AuthChangeNotifier>(),
      ),
    );
    gh.singleton<_i583.GoRouter>(
      () => navigationModule.provideGoRouter(gh<_i954.AppRouter>()),
    );
    gh.factoryParam<_i508.App, _i409.Key?, dynamic>(
      (key, _) => _i508.App(
        routerConfig: gh<_i583.GoRouter>(),
        logger: gh<_i632.IAppLogger>(),
        pageBuilder: gh<_i18.PageBuilder>(),
        themeCubit: gh<_i455.ThemeCubit>(),
        localeCubit: gh<_i455.LocaleCubit>(),
        authBloc: gh<_i55.AuthBloc>(),
        profileBloc: gh<_i493.ProfileBloc>(),
        failureMessageService: gh<_i313.FailureMessageService>(),
        appTheme: gh<_i238.AppTheme>(),
        key: key,
      ),
    );
    return this;
  }
}

class _$NetworkModule extends _i823.NetworkModule {}

class _$StorageModule extends _i513.StorageModule {}

class _$BlocModule extends _i728.BlocModule {}

class _$PlatformModule extends _i815.PlatformModule {}

class _$NavigationModule extends _i874.NavigationModule {}

class _$LoggingModule extends _i216.LoggingModule {}

class _$ErrorModule extends _i895.ErrorModule {}
