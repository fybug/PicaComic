import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pica_comic/eh_network/eh_models.dart';
import 'package:pica_comic/views/eh_views/eh_widgets/eh_gallery_tile.dart';
import 'package:pica_comic/views/widgets/show_network_error.dart';

import '../../base.dart';

class EhHomePageLogic extends GetxController{
  bool loading = true;
  Galleries? galleries;
  void getGallery() async{
    galleries = await ehNetwork.getGalleries(ehNetwork.ehBaseUrl);
    loading = false;
    update();
  }
  void retry(){
    loading = true;
    update();
  }
}

class EhHomePage extends StatelessWidget {
  const EhHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EhHomePageLogic>(
      builder: (logic){
        if(logic.loading){
          logic.getGallery();
          return const Center(
            child: CircularProgressIndicator(),
          );
        }else if(logic.galleries!=null){
          return CustomScrollView(
            slivers: [
              SliverGrid(
                delegate: SliverChildBuilderDelegate(
                    childCount: logic.galleries!.length,
                        (context, i){
                      if(i==logic.galleries!.length-1){
                        ehNetwork.getNextPageGalleries(logic.galleries!).then((v)=>logic.update());
                      }
                      return EhGalleryTile(logic.galleries![i]);
                    }
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: comicTileMaxWidth,
                  childAspectRatio: comicTileAspectRatio,
                ),
              ),
              if(logic.galleries!.next!=null)
                SliverToBoxAdapter(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 80,
                    child: const Center(
                      child: SizedBox(
                        width: 20,height: 20,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }else{
          return showNetworkError(context, logic.retry, showBack:false, eh: true);
        }
      },
    );
  }
}