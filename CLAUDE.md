# CLAUDE.md — 確認促し (Kakunin Unagashi)

## プロジェクト概要

「確認促し」は、生活の中で定期的に確認が必要な項目を管理するiOSアプリ。ユーザーが項目と確認間隔を設定し、期日が来たらホーム画面に表示、確認済みボタンで完了→次のスケジュールへ自動移行する。Apple標準リマインダーにない「完了後からカウント」機能と、確認に特化したUIが最大の差別化ポイント。

### ターゲットユーザー
- 家の点検（消火器、HVAC フィルター、煙感知器）を管理したい人
- 車のメンテナンス（オイル交換、タイヤ空気圧、車検）を忘れたくない人
- 健康管理（歯科検診、健康診断、予防接種）のスケジュールを把握したい人
- 安全点検（防災グッズ確認、保険更新）を定期的に行いたい人
- お金関連（保険見直し、クレジットレポート、サブスク棚卸し）を管理したい人

### 競合との差別化
1. **確認特化UI**: タスク管理ではなく「確認→完了→次へ」のフロー特化
2. **完了後カウント**: 確認した日からN日後に次回設定（Apple Remindersにない機能）
3. **クロスドメイン**: 家・車・健康・安全・お金を1つのアプリで統合管理
4. **表示は期日のみ**: 期日が来るまで項目はホーム画面に表示されない（タスク麻痺を防止）
5. **買い切り課金**: サブスク疲れの逆を突く¥480で広告永久非表示

---

## 技術スタック

| 項目 | 技術 |
|------|------|
| 言語 | Swift |
| UI | SwiftUI（カスタムUI、デフォルトコンポーネント不使用） |
| データ保存 | SwiftData（ローカルのみ、iCloud同期なし） |
| 最低iOS | iOS 17.0 |
| デバイス | iPhone のみ |
| 広告 | Google AdMob（バナー広告） |
| 課金 | StoreKit 2（買い切り¥480で広告永久非表示） |
| 通知 | UserNotifications framework |
| ウィジェット | WidgetKit |
| ローカライズ | 日本語（デフォルト）+ 英語 |
| アーキテクチャ | MVVM |

---

## UI/UXデザインシステム — FotMob参照

### 重要: デフォルトUIは使用しない
SwiftUIの標準コンポーネント（List, Form, Toggle等）をそのまま使わず、全てカスタムビューで構築する。FotMobのデータ表示の美しさと情報密度を参照し、プレミアム感のあるUIを実現する。

### カラーシステム

```
// Light Mode
primaryAccent:      #2D8CFF  // 鮮やかなブルー（FotMobのグリーンに相当する唯一のアクセント）
background:         #FFFFFF
cardBackground:     #F5F5F5
primaryText:        #1A1A1A
secondaryText:      #8E8E93
overdueRed:         #FF3B30  // 期限超過の警告色
confirmedGreen:     #34C759  // 確認済みの成功色
separator:          #E5E5EA  // 0.5ptヘアライン

// Dark Mode
primaryAccent:      #4DA3FF  // ライトより少し明るく調整
background:         #1C1C1E
cardBackground:     #2C2C2E
primaryText:        #F5F5F5
secondaryText:      #8E8E93
overdueRed:         #FF453A
confirmedGreen:     #30D158
separator:          #38383A
```

### タイポグラフィ（SF Pro、全てシステムフォント）

| 要素 | ウェイト | サイズ |
|------|---------|--------|
| ホーム画面の日付ヘッダー | Bold | 28pt |
| カテゴリヘッダー | Semibold | 16pt |
| 項目名 | Medium | 17pt |
| 残り日数/ステータス | Bold | 22pt |
| 補助テキスト（次回確認日等） | Regular | 13pt |
| タブバーラベル | Regular | 10pt |

### デザイントークン

| トークン | 値 |
|---------|-----|
| カード角丸 | 14pt |
| ボタン角丸 | 10pt |
| カード影 | なし（色の階層で区別、FotMob方式） |
| 行パディング | 14pt（上下） |
| 水平パディング | 16pt（左右） |
| セパレータ | 0.5pt hairline |
| グリッドシステム | 8ptグリッド |
| アイコン | SF Symbols（カスタムアイコン不使用） |

### FotMob参照パターン → 確認促しへの適用

| FotMobパターン | 確認促しでの適用 |
|---------------|-----------------|
| リーグ別折りたたみカード | カテゴリ別折りたたみグループ（家、車、健康等） |
| 試合スコアの大きな太字表示 | 残り日数の大きな太字表示（「あと3日」「期限超過2日」） |
| 試合行（クレスト+チーム名+スコア） | 確認項目行（アイコン+項目名+残り日数+ステータス） |
| ワンタップでフォロー/通知トグル | ワンタップ確認済みボタン（確認ダイアログなし、即時フィードバック） |
| 水平日付ピッカー（Today下線付き） | 水平期間フィルター（「今日」「今週」「全て」アクセント下線付き） |
| ライブ試合の赤インジケーター | 期限超過項目の赤インジケーター |
| タップで試合詳細へ | タップで確認項目詳細へ（履歴、写真、メモ） |
| チームカラーの動的ヘッダー | カテゴリカラーの動的詳細ヘッダー |
| 5タブのナビゲーション | 4タブのナビゲーション |
| 試合ステータス（FT, LIVE, 予定） | 確認ステータス（確認済み✓, 期限超過!, 予定） |

### アニメーション
- 確認ボタンタップ: 緑のチェックマークがスケールインしてバウンスする微アニメーション（0.3秒）
- カテゴリ展開/折りたたみ: スムーズなスプリングアニメーション
- 行タップフィードバック: 薄いグレーのハイライト（FotMob方式）
- 画面遷移: 標準的な右からスライドイン

---

## 画面構成

### Tab 1: ホーム（メイン画面）

#### ナビゲーションヘッダー
- 左: 「確認促し」アプリ名（Bold 20pt）
- 右: 設定アイコン（SF Symbol: gearshape）

#### 水平フィルターバー
FotMobの日付ピッカーと同じパターン。水平スクロール可能なフィルタータブ：
- 「今日」（デフォルト選択、アクセント下線付き）
- 「今週」
- 「今月」
- 「全て」
- 「期限超過」

選択中のフィルターにはprimaryAccent色の下線（3pt太さ）を表示。

#### コンテンツエリア
**期日が来た項目のみ表示**（これが最大の特徴 — 期日前の項目はホーム画面に出ない）

カテゴリごとの折りたたみ可能なグループカード：

```
┌─────────────────────────────────────┐
│ 🏠 家  (3)                      ∨  │  ← カテゴリヘッダー（タップで折りたたみ）
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ エアコンフィルター掃除          │ │
│ │ 📅 2日超過          [確認済み]  │ │  ← 赤テキスト + 確認ボタン
│ └─────────────────────────────────┘ │
│ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ │  ← 0.5ptセパレータ
│ ┌─────────────────────────────────┐ │
│ │ 煙感知器テスト                  │ │
│ │ 📅 今日              [確認済み]  │ │  ← primaryAccentテキスト
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ 🚗 車  (1)                      ∨  │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ タイヤ空気圧チェック            │ │
│ │ 📅 あと3日           [確認済み]  │ │  ← 緑テキスト（余裕あり）
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

**確認済みボタン**: 
- 角丸10ptの塗りつぶしボタン（primaryAccent色）
- タップすると即座に確認処理（確認ダイアログなし、FotMob方式のワンタップ）
- 確認後: 緑チェックマークのバウンスアニメーション → 次回日程の表示 → 「間隔を変更しますか？」のインラインオプション表示（ボトムシートではなく行内に展開）

**空状態**:
確認項目がない場合:
```
（チェックマークのイラスト）
今日確認が必要な項目はありません
すべて順調です 👍
```

#### 残り日数の色分けルール
- 期限超過: `overdueRed` + "N日超過" テキスト
- 今日: `primaryAccent` + "今日" テキスト  
- 1〜3日以内: `primaryAccent` + "あとN日" テキスト
- 4日以上: `secondaryText` + "あとN日" テキスト

---

### Tab 2: 全項目一覧

登録済みの全確認項目を表示する画面。ホームが「期日のもののみ」なのに対し、こちらは全項目。

#### レイアウト
- 上部: 検索バー（カスタムデザイン、角丸14pt、cardBackground色）
- カテゴリ別の折りたたみグループ（ホームと同じカードパターン）
- 各項目行: 項目名 + 次回確認日 + スケジュールタイプアイコン
- 右上: ソートボタン（SF Symbol: arrow.up.arrow.down）
  - ソート順: 次回確認日順（デフォルト）、名前順、カテゴリ順、作成日順

#### 項目行のレイアウト
```
┌─────────────────────────────────────┐
│ [カテゴリアイコン] エアコンフィルター │
│   次回: 3月15日  ·  2週間ごと  >    │
└─────────────────────────────────────┘
```
- タップ → 項目詳細画面へ遷移
- 長押し → コンテキストメニュー（編集、削除、今すぐ確認）

---

### Tab 3: 履歴

確認済み項目の履歴をタイムラインで表示。

#### レイアウト
- 上部: 月別ナビゲーション（← 2024年3月 →）
- 日別にグループ化されたタイムライン表示

```
── 3月10日（月） ─────────────────
  ✓ エアコンフィルター掃除   10:30
    📝 "少し汚れていた"
    📷 [サムネイル]
  ✓ 煙感知器テスト           14:15

── 3月8日（土） ──────────────────
  ✓ タイヤ空気圧チェック     09:00
    📝 "前輪を2.4に調整"
```

- 各履歴エントリをタップ → 詳細表示（写真フル表示、メモ全文）
- 空状態: 「まだ確認履歴がありません」

---

### Tab 4: 設定

#### セクション構成（カスタムカードグループ）

**一般**
- 通知設定（通知時刻、事前通知の日数）
- バッジ表示（ON/OFF）
- アプリの言語（日本語/英語 — システム追従をデフォルト）
- ダークモード（ライト/ダーク/システム追従）

**課金**
- 「広告を非表示にする」カード
  - 購入前: 価格表示（¥480）+ 購入ボタン
  - 購入後: 「広告非表示: 有効 ✓」表示
- 「購入を復元」ボタン

**データ**
- データのエクスポート（JSON形式）
- データの全削除（確認ダイアログあり）

**情報**
- 利用規約
- プライバシーポリシー
- お問い合わせ（メールリンク）
- バージョン情報
- アプリを評価する（App Store リンク）

---

### 項目追加画面（モーダル / フルスクリーン）

ホーム画面右下のFABボタン（primaryAccent色、+ アイコン）からアクセス。
テンプレートなし、全て自由入力。

#### 入力フィールド

**1. 項目名**（必須）
- カスタムテキストフィールド（cardBackground色、角丸14pt）
- プレースホルダー: 「例: エアコンフィルター掃除」

**2. カテゴリ選択**（必須）
- 横スクロール可能なチップ選択UI
- デフォルトカテゴリ: 🏠 家、🚗 車、💊 健康、🛡️ 安全、💰 お金、📋 その他
- ユーザーがカスタムカテゴリを追加可能（カテゴリ名 + 絵文字選択）

**3. スケジュールタイプ選択**（必須）
カスタムセグメントコントロール（4つのタブ）:

- **定期間隔**: ピッカーで数値 + 単位（日/週/月/年）を選択
  - 例: 「2週間ごと」「3ヶ月ごと」「1年ごと」
  
- **完了後カウント**: ピッカーで数値 + 単位を選択
  - 「確認完了した日からN日/週/月後」
  - ※定期間隔との違いを説明するインラインヘルプテキスト:
    「定期間隔: カレンダー上の固定スケジュール」
    「完了後カウント: 実際に確認した日から数え直し」
  
- **特定日**: 日付ピッカー（年月日）
  - 例: 「2024年6月15日」
  - 毎年繰り返しオプション（ON/OFF）
  
- **曜日指定**: 
  - 頻度: 毎週 / 隔週 / 毎月第N
  - 曜日選択: 月〜日のチップ
  - 例: 「毎月第2土曜日」「毎週月曜日」

**4. 開始日**（必須）
- デフォルト: 今日
- 日付ピッカーで変更可能

**5. 通知時刻**（任意）
- 時刻ピッカー
- デフォルト: 設定画面のグローバル通知時刻を継承

**6. メモ**（任意）
- 複数行テキストフィールド
- プレースホルダー: 「この確認項目についてのメモ」

**7. 保存ボタン**
- 画面下部に固定配置
- primaryAccent色の塗りつぶしボタン（フル幅、角丸10pt）
- 「項目を追加」テキスト

---

### 項目詳細画面

全項目一覧やホーム画面から項目をタップで遷移。
FotMobの試合詳細画面を参照したカテゴリカラーの動的ヘッダー。

#### ヘッダー
- カテゴリカラーのグラデーション背景（上部）
- カテゴリ絵文字（大きく表示）
- 項目名（Bold 24pt、白テキスト）

#### コンテンツ

**ステータスカード**
```
┌─────────────────────────────────┐
│  次回確認日                      │
│  3月15日（土）         あと5日   │
│                                 │
│  スケジュール: 2週間ごと         │
│  前回確認: 3月1日               │
│                                 │
│      [ 今すぐ確認する ]          │
└─────────────────────────────────┘
```

**設定情報カード**
- スケジュールタイプと間隔
- 通知時刻
- カテゴリ
- 作成日
- メモ（あれば）

**確認履歴セクション**
- この項目の直近10件の確認履歴
- 各エントリ: 日時 + メモ + 写真サムネイル
- 「全ての履歴を見る」リンク → 履歴タブの該当項目フィルター

#### アクションバー（画面下部固定）
- 「今すぐ確認する」ボタン（primaryAccent、フル幅）
- その下に小さく「編集」「削除」リンク

---

### 確認フロー（最重要UX）

ユーザーが「確認済み」をタップした後のフロー:

#### Step 1: 即時確認（ワンタップ）
- ホーム画面の「確認済み」ボタン or 詳細画面の「今すぐ確認する」をタップ
- 緑チェックマークのバウンスアニメーション（0.3秒）
- ハプティックフィードバック（.success）

#### Step 2: 確認時オプション（インライン展開）
ボタンの位置にインラインで展開（モーダルやシートではない）:

```
✓ 確認しました！

📷 写真を追加          📝 メモを追加
          
次回: 3月29日（2週間後）
[ 間隔を変更 ]  [ OK ]
```

- 「写真を追加」: カメラ or フォトライブラリから選択
- 「メモを追加」: テキスト入力フィールドが展開
- 「間隔を変更」: タップでスケジュール編集UIが展開
- 「OK」: そのまま次回スケジュール確定、項目がホーム画面から消える

#### Step 3: 次回スケジュール自動計算
- **定期間隔**: 元の期日 + 間隔 = 次回期日
- **完了後カウント**: 今日（確認日）+ 間隔 = 次回期日
- **特定日（毎年）**: 来年の同日
- **曜日指定**: 次の該当曜日を計算

---

## データモデル（SwiftData）

### CheckItem（確認項目）
```swift
@Model
final class CheckItem {
    var id: UUID
    var name: String                          // 項目名
    var category: CheckCategory               // カテゴリ
    var scheduleType: ScheduleType            // スケジュールタイプ
    var intervalValue: Int                     // 間隔の数値（例: 2）
    var intervalUnit: IntervalUnit             // 間隔の単位（日/週/月/年）
    var specificDate: Date?                    // 特定日（特定日タイプの場合）
    var dayOfWeek: Int?                        // 曜日（0=日, 1=月, ..., 6=土）
    var weekOrdinal: Int?                      // 第N週（曜日指定の場合: 1-5, 0=毎週）
    var nextDueDate: Date                      // 次回確認期日
    var notificationTime: Date?               // 通知時刻
    var memo: String?                          // メモ
    var createdAt: Date                        // 作成日
    var updatedAt: Date                        // 更新日
    
    @Relationship(deleteRule: .cascade)
    var confirmations: [Confirmation]          // 確認履歴
}
```

### Confirmation（確認履歴）
```swift
@Model
final class Confirmation {
    var id: UUID
    var confirmedAt: Date                      // 確認日時
    var memo: String?                          // 確認時メモ
    var photoData: Data?                       // 写真データ（JPEG圧縮）
    
    @Relationship(inverse: \CheckItem.confirmations)
    var checkItem: CheckItem?
}
```

### CheckCategory（カテゴリ）
```swift
@Model
final class CheckCategory {
    var id: UUID
    var name: String                           // カテゴリ名
    var emoji: String                          // 絵文字アイコン
    var colorHex: String                       // カテゴリカラー（Hex）
    var sortOrder: Int                         // 並び順
    var isDefault: Bool                        // デフォルトカテゴリかどうか
    
    @Relationship(deleteRule: .nullify)
    var items: [CheckItem]
}
```

### Enums
```swift
enum ScheduleType: String, Codable {
    case fixedInterval      // 定期間隔
    case afterCompletion    // 完了後カウント
    case specificDate       // 特定日
    case dayOfWeek          // 曜日指定
}

enum IntervalUnit: String, Codable {
    case day    // 日
    case week   // 週
    case month  // 月
    case year   // 年
}
```

### デフォルトカテゴリ（初回起動時に作成）
| 絵文字 | 名前（日本語） | 名前（英語） | カラー |
|--------|--------------|-------------|--------|
| 🏠 | 家 | Home | #4A90D9 |
| 🚗 | 車 | Vehicle | #E67E22 |
| 💊 | 健康 | Health | #27AE60 |
| 🛡️ | 安全 | Safety | #E74C3C |
| 💰 | お金 | Finance | #F39C12 |
| 📋 | その他 | Other | #8E8E93 |

---

## 通知システム

### プッシュ通知（UserNotifications）
- 各項目の期日当日、設定された時刻にローカル通知を送信
- 通知コンテンツ:
  - タイトル: 「確認の時間です」 / "Time to Check"
  - ボディ: 「[項目名]の確認をしましょう」 / "Check [item name]"
  - カテゴリアクション: 「確認済み」ボタン（通知から直接完了可能）
- 事前通知オプション: 1日前にも通知を送信可能（設定で有効化）

### バッジ
- アプリアイコンに未確認項目数をバッジ表示
- 確認済みにするたびにバッジ数を更新

### iOSウィジェット（WidgetKit）

**Small Widget (systemSmall)**
```
┌──────────────┐
│ 確認促し      │
│              │
│   3          │
│  未確認       │
│              │
│ 次: フィルター │
└──────────────┘
```

**Medium Widget (systemMedium)**
```
┌────────────────────────────────┐
│ 確認促し          今日 3件     │
│                               │
│ 🏠 エアコンフィルター   2日超過 │
│ 🏠 煙感知器テスト       今日   │
│ 🚗 タイヤ空気圧     あと3日   │
└────────────────────────────────┘
```

- ウィジェットタップ → アプリのホーム画面を開く
- 個別項目タップ → 該当項目の詳細画面を開く（Deep Link）

---

## AdMob広告

### バナー広告の配置
- ホーム画面の下部（タブバーの上）にバナー広告を表示
- 広告サイズ: アダプティブバナー（GADAdSizeBanner）
- 全項目一覧画面にも同様に配置
- 履歴画面と設定画面には広告なし

### 広告非表示（買い切り課金）
- StoreKit 2 で Non-Consumable IAP として実装
- Product ID: `com.yourapp.kakuninunagashi.removeads`
- 価格: ¥480（日本）/ $3.99（US）
- 購入後: 全画面から広告を永久非表示
- 購入復元機能を設定画面に配置

### 広告表示ルール
- 課金済みユーザー: 広告一切表示なし
- 未課金ユーザー: ホーム画面と全項目一覧画面にバナー広告
- 項目追加画面、詳細画面、確認フロー中は広告非表示（UXを妨げない）

---

## ローカライズ

### 対応言語
1. **日本語**（ja） — デフォルト言語、第一市場
2. **英語**（en） — グローバル市場

### ローカライズ方針
- String Catalog（.xcstrings）を使用
- 全てのユーザー向けテキストをLocalizedStringKeyで管理
- 日付フォーマットはロケール依存（DateFormatter.localizedString）
- 数値フォーマットもロケール依存

### 主要な翻訳キー例
| キー | 日本語 | 英語 |
|------|--------|------|
| tab.home | ホーム | Home |
| tab.all | 全項目 | All Items |
| tab.history | 履歴 | History |
| tab.settings | 設定 | Settings |
| home.filter.today | 今日 | Today |
| home.filter.thisWeek | 今週 | This Week |
| home.filter.thisMonth | 今月 | This Month |
| home.filter.all | 全て | All |
| home.filter.overdue | 期限超過 | Overdue |
| status.overdue | %d日超過 | %d days overdue |
| status.today | 今日 | Today |
| status.daysLeft | あと%d日 | %d days left |
| button.confirm | 確認済み | Confirmed |
| button.addItem | 項目を追加 | Add Item |
| confirm.done | 確認しました！ | Confirmed! |
| confirm.addPhoto | 写真を追加 | Add Photo |
| confirm.addMemo | メモを追加 | Add Memo |
| confirm.changeInterval | 間隔を変更 | Change Interval |
| schedule.fixed | 定期間隔 | Fixed Interval |
| schedule.afterCompletion | 完了後カウント | After Completion |
| schedule.specificDate | 特定日 | Specific Date |
| schedule.dayOfWeek | 曜日指定 | Day of Week |
| empty.noItems | 今日確認が必要な項目はありません | No items to check today |
| empty.allGood | すべて順調です 👍 | All good! 👍 |
| purchase.removeAds | 広告を非表示にする | Remove Ads |
| purchase.price | ¥480 | $3.99 |
| purchase.restored | 購入を復元しました | Purchase Restored |

---

## App Store提出要件

### 必須画面・機能
- 利用規約画面（Webビュー or アプリ内テキスト）
- プライバシーポリシー画面
- App Tracking Transparency（ATT）許可ダイアログ（AdMob使用のため）
  - ATT許可前は広告をパーソナライズなしで表示
  - ATTリクエストは初回広告表示時にトリガー

### App Storeメタデータ

**日本語**
- アプリ名: 確認促し - 定期リマインダー
- サブタイトル: 点検・確認チェック管理
- キーワード: 定期,繰り返し,リマインダー,チェック,確認,点検,メンテナンス,タスク,通知,スケジュール

**英語**
- App Name: Kakunin - Recurring Reminders
- Subtitle: Periodic Check & Task Tracker
- Keywords: recurring,periodic,maintenance,check,routine,checklist,household,cleaning,schedule,inspection

### プライバシー
- データ収集: 使用状況データ（AdMobの広告識別子のみ）
- 課金済みユーザー: データ収集なし
- App Privacy の「Data Used to Track You」セクション: 広告IDのみ（課金で解除可能と明記）

---

## プロジェクト構成

```
KakuninUnagashi/
├── App/
│   ├── KakuninUnagashiApp.swift          // @main エントリポイント
│   └── ContentView.swift                  // TabView ルート
│
├── Models/
│   ├── CheckItem.swift                    // 確認項目モデル
│   ├── Confirmation.swift                 // 確認履歴モデル
│   ├── CheckCategory.swift                // カテゴリモデル
│   └── Enums.swift                        // ScheduleType, IntervalUnit
│
├── ViewModels/
│   ├── HomeViewModel.swift                // ホーム画面ロジック
│   ├── AllItemsViewModel.swift            // 全項目一覧ロジック
│   ├── HistoryViewModel.swift             // 履歴画面ロジック
│   ├── AddItemViewModel.swift             // 項目追加ロジック
│   ├── ItemDetailViewModel.swift          // 項目詳細ロジック
│   └── SettingsViewModel.swift            // 設定画面ロジック
│
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift                 // ホームタブ
│   │   ├── FilterBarView.swift            // 水平フィルターバー
│   │   ├── CategoryGroupView.swift        // カテゴリ別折りたたみカード
│   │   ├── CheckItemRowView.swift         // 確認項目行
│   │   ├── ConfirmationInlineView.swift   // 確認後のインライン展開UI
│   │   └── EmptyStateView.swift           // 空状態
│   │
│   ├── AllItems/
│   │   ├── AllItemsView.swift             // 全項目タブ
│   │   └── AllItemsRowView.swift          // 全項目行
│   │
│   ├── History/
│   │   ├── HistoryView.swift              // 履歴タブ
│   │   ├── MonthNavigatorView.swift       // 月別ナビゲーション
│   │   └── HistoryEntryView.swift         // 履歴エントリ
│   │
│   ├── Settings/
│   │   ├── SettingsView.swift             // 設定タブ
│   │   ├── NotificationSettingsView.swift // 通知設定
│   │   └── PurchaseCardView.swift         // 課金カード
│   │
│   ├── AddItem/
│   │   ├── AddItemView.swift              // 項目追加画面
│   │   ├── ScheduleTypePicker.swift       // スケジュールタイプ選択
│   │   ├── CategoryChipView.swift         // カテゴリチップ
│   │   └── IntervalPickerView.swift       // 間隔ピッカー
│   │
│   ├── ItemDetail/
│   │   ├── ItemDetailView.swift           // 項目詳細画面
│   │   ├── StatusCardView.swift           // ステータスカード
│   │   └── ItemHistoryListView.swift      // 項目別履歴リスト
│   │
│   └── Components/
│       ├── CustomCardView.swift           // 汎用カードコンポーネント
│       ├── CustomButtonView.swift         // 汎用ボタン
│       ├── CustomTextFieldView.swift      // 汎用テキストフィールド
│       ├── CustomSegmentControl.swift     // カスタムセグメントコントロール
│       ├── SeparatorView.swift            // ヘアラインセパレータ
│       └── CategoryBadgeView.swift        // カテゴリバッジ
│
├── Services/
│   ├── NotificationManager.swift          // 通知管理
│   ├── ScheduleCalculator.swift           // 次回日程計算ロジック
│   ├── StoreKitManager.swift              // 課金管理（StoreKit 2）
│   └── AdMobManager.swift                 // AdMob広告管理
│
├── Utilities/
│   ├── DateHelper.swift                   // 日付ユーティリティ
│   ├── ColorTheme.swift                   // カラーテーマ定義
│   ├── DesignTokens.swift                 // デザイントークン定数
│   └── ExportManager.swift                // データエクスポート
│
├── Widget/
│   ├── KakuninWidget.swift                // ウィジェットメイン
│   ├── SmallWidgetView.swift              // Small ウィジェット
│   ├── MediumWidgetView.swift             // Medium ウィジェット
│   └── WidgetDataProvider.swift           // ウィジェット用データ提供
│
├── Resources/
│   ├── Localizable.xcstrings              // ローカライズ文字列
│   └── Assets.xcassets                    // 画像アセット
│
└── Info.plist
```

---

## 実装優先度

### Phase 1: MVP（コア機能）
1. SwiftDataモデル定義とデフォルトカテゴリ作成
2. ホーム画面（フィルターバー + カテゴリグループ + 確認ボタン）
3. 項目追加画面（4つのスケジュールタイプ全対応）
4. 確認フロー（ワンタップ確認 + テキストメモ + 写真メモ）
5. スケジュール計算ロジック（全4タイプ）
6. プッシュ通知
7. ダーク/ライトモード対応

### Phase 2: 完成度向上
8. 全項目一覧画面（検索 + ソート）
9. 項目詳細画面（カテゴリカラーヘッダー + 履歴表示）
10. 履歴画面（タイムライン表示）
11. AdMob広告統合
12. StoreKit 2 買い切り課金
13. バッジ表示

### Phase 3: ウィジェット + 仕上げ
14. iOSウィジェット（Small + Medium）
15. ローカライズ（英語）
16. ATTダイアログ
17. 設定画面（通知設定、データエクスポート、利用規約、プライバシーポリシー）
18. アニメーション仕上げ
19. App Store 提出準備（スクリーンショット、説明文）

---

## コーディング規約

### Swift
- Swift 5.9+
- Strict Concurrency Checking 有効
- @MainActor を ViewModelに適用
- async/await を非同期処理に使用
- guard let / if let でオプショナルを安全にアンラップ

### SwiftUI
- デフォルトコンポーネントは使わず、全てカスタム実装
- ViewModifier でスタイルを共通化
- @Observable マクロ（iOS 17+）をViewModelに使用
- 環境値（@Environment）でカラースキームを取得

### 命名規則
- ファイル名: PascalCase（例: HomeView.swift）
- 変数/関数: camelCase（例: nextDueDate）
- 定数: camelCase（例: cornerRadius）
- プロトコル: PascalCase + 形容詞（例: Confirmable）
- 日本語コメントOK、コード自体は英語

---

## 注意事項

- 写真データは JPEG 圧縮（compressionQuality: 0.7）でSwiftDataに直接保存
- 大量の写真保存によるストレージ肥大化に注意 → 写真は最大解像度1024pxにリサイズしてから保存
- ウィジェットとアプリ間のデータ共有は App Group を使用
- 通知はUNUserNotificationCenterでローカル通知として管理
- 通知の登録上限（64件）に注意 → 直近の確認期日から優先的に通知を登録
- AdMob SDK は Swift Package Manager で導入
- StoreKit 2 のトランザクション監視はアプリ起動時に開始
