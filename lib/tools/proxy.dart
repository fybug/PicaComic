import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../base.dart';

///获取系统设置中的代理, 仅windows,安卓有效
Future<String?> getProxy() async{
  //手动设置的代理
  if(appdata.settings[8]!="0")  return appdata.settings[8];
  //对于安卓, 将获取WIFI设置中的代理
  //Web端流量走系统代理且无法进行设置
  if(GetPlatform.isWeb) return null;

  const channel = MethodChannel("kokoiro.xyz.pica_comic/proxy");
  var res = await channel.invokeMethod("getProxy");
  if(res == "No Proxy") return null;
  //windows上部分代理工具会将代理设置为http=127.0.0.1:8888;https=127.0.0.1:8888;ftp=127.0.0.1:7890的形式
  //下面的代码从中提取正确的代理地址
  if(res[0] == 'h'){
    var temp = "";
    bool status = false;
    bool status2 = false;
    for(int i = 0;i < res.length;i++){
      if(!status){
        //找到第一个等号
        if(res[i] == '='){
          status = true;
        }
      }else{
        if(res[i]==' ' || res[i]==';'){
          if(status2){
            break;
          }
          continue;
        }
        status2 = true;
        temp += res[i];
      }
    }
    res = temp;
  }
  return res;
}

ProxyHttpOverrides? proxyHttpOverrides;

///获取代理设置并应用
Future<void> setNetworkProxy() async{
  //Image加载使用的是Image.network()和CachedNetworkImage(), 均使用flutter内置http进行网络请求
  var proxy = await getProxy();
  if(kDebugMode){
    print("Set Proxy $proxy");
  }
  if(proxyHttpOverrides==null){
    proxyHttpOverrides = ProxyHttpOverrides(proxy);
    HttpOverrides.global = proxyHttpOverrides;
  }else{
    proxyHttpOverrides!.proxy = proxy;
  }
}

class ProxyHttpOverrides extends HttpOverrides {
  String? proxy;
  ProxyHttpOverrides(this.proxy);
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.findProxy = (uri) => proxy==null ? "DIRECT" : 'PROXY $proxy;';
    client.badCertificateCallback = (X509Certificate cert, String host, int port)=>true;
    return client;
  }
}