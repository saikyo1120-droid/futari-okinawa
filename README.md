# おめでと島ぐらし

さいけうとゆいちゃんの沖縄5泊6日誕生日旅行、ふたりだけのサイト。


## 保存先（Supabase）の設定
- `supabase_setup.sql` を Supabase の SQL Editor で一度実行すると、保存用の表・写真の保存場所・ふたりだけの許可・リアルタイム更新がそろいます（何度実行しても壊れません）。
- サイト下部の「せつぞくチェック」で、どこまで設定できているかを確認できます。保存に失敗したときも自動でこの画面がひらきます。

## 編集について
- `index.html` がこのサイトの唯一のソースです（CSS・JS・データすべて入り）。ここを直接編集してコミットすると GitHub Actions が公開します。
- 地図：`ISLANDS`（海岸線のSVGパス、10単位=1km）、`COORDS`（既定の行き先の緯度経度）、`REGIONS`・`LANDMARKS`・`EXPRESSWAY`・`ROUTE58`。編集画面で「地図で検索する名前」を入れて保存すると Nominatim（OpenStreetMap）で座標を自動取得します。

## 背景の3Dシーン
- `tools/hero-scene.html` が島の背景（three.js で描いたトイ風のジオラマ）の元データです。`npm i three` した場所で `tools/hero-capture.py` を実行すると `back / foam / front / water` の各レイヤーを書き出せます（`water` は海のマスク用）。
