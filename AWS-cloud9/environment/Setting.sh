#作ったRepositoryに登録するための資材
#Cloud9から実行すればOK
# ./Setting.sh

#https://qiita.com/tatsuruM/items/fe28c032253b317d0044
#https://iret.media/42538



#ベースイメージの作成と登録
sh repo0/pushbaseimage.sh

#サンプルRepositoryの登録(SpringBoot)
sh repo1/InitRepository.sh
#サンプルRepositoryの登録(Nginx)
sh repo2/InitRepository.sh
