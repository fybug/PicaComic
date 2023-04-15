import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../tools/proxy.dart';

Future<Dio> request() async{
  /*
  这是一个历史遗留
  在进行实现检测并应用代理的工作时, 我并不知道HttpOverrides.global的配置会影响到dio
   */
  var dio = Dio()
    ..interceptors.add(LogInterceptor());
  if(!GetPlatform.isWeb) {
    //var proxy = await getProxy();
    await setNetworkProxy();//更新代理设置
  }
  return dio;
}