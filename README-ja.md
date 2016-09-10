# コレは何？

データベースのレコードを ActiveRecord を介して、他のデータ形式にインポート/エクスポートする処理をサポートするフレームワークです。  

以下のような特徴があります。  

* `accepts_nested_attributes_for` で定義された関連モデルを同時にインポート/エクスポート可能
* インポートデータに `primary_key` が含まれる場合、それが正当な値かどうかをチェック
* 設定用クラスを定義して使い、モデル、属性単位で処理をカスタマイズ可能
* その設定用クラスを複数定義して、実行時に切り替え可能

現在のところ、インポート/エクスポート可能なデータ形式は

* CSV

です。

## インストール

Gemfile に  

```ruby
gem 'activerecord-bixformer'
```

と記述し、  

    $ bundle

とするか、もしくは、  

    $ gem install activerecord-bixformer

## 構成要素

本フレームワークの構成要素と役割は以下のようになっています。

### Modeler

インポート/エクスポートの一連の処理をどのように処理するかを定義する設定ファイルの役割です。  
処理実行時に、複数登録された本クラスのインスタンス群から採用するものを決定するフローになっていて、
バージョンや条件による処理内容の切り替えを容易にできます。  

### Runner

インポート/エクスポートの一連の処理を実行するクラスです。  
本クラスをそのまま利用するだけでも、インポート/エクスポートが可能です。  

### Model

ActiveRecord のモデルに対応して、そのモデルのインポート/エクスポート処理を担当するクラスです。  

ActiveRecord::Bixformer::Model::Base を継承した独自クラスを定義し、  
Modelerを適切に定義することで、それを使用して処理内容を切り替えることができます。  

### Attribute

ActiveRecord のモデルの持つ属性に対応して、その属性のインポート/エクスポート処理を担当するクラスです。  

ActiveRecord::Bixformer::Attribute::Base を継承した独自クラスを定義し、  
Modelerを適切に定義することで、それを使用して処理内容を切り替えることができます。  

# 使い方

## 1. Modelerの実装

ActiveRecord::Bixformer::Modeler::Base を継承して、以下のメソッドを適切に設定して下さい。  

### model_name

インポート/エクスポート対象のモデル名を返して下さい。  
例えばusersテーブルのデータが対象であれば、 `:user` です。  

### entry_definition

インポート/エクスポート対象の属性と、それをどのように処理するかを定義した以下のようなハッシュを返して下さい。  

```ruby
{
  # 対象モデル（上の例なら user ）の処理を担当するModelクラス名
  # 省略可能で、省略された場合は :base が指定される
  # 指定可能な値については、「本フレームワークに定義されたModel一覧」を参照
  # または、独自クラスを定義し、 module_load_namespaces を設定
  type: :base,
  
  # 処理対象の属性名をキー、その処理を担当するAttributeクラス名を値に持つハッシュ
  attributes: {
    # 指定可能な値については、「本フレームワークに定義されたAttribute一覧」を参照
    # または、独自クラスを定義し、 module_load_namespaces を設定
    name: :base,
    # クラス名を配列にすると、2番目以降の要素はAttributeクラスに渡される
    joined_at: [:time, format: :ymdhms]
  },
  
  # 処理対象の関連名をキー、その処理を定義したハッシュを値に持つハッシュ
  associations: {
    posts: {
      # 同じように、 type, attributes, associations が定義可能
      
      # 配列にすると、2番目以降の要素はModelクラスに渡される
      type: [:indexed, size: 3]
    }
  }
}
```

### optional_attributes

インポート時に、有効な値でない場合に、登録対象としない属性を定義した以下のような配列を返して下さい。  

```ruby
[
  # 対象モデル（上の例なら user ）の属性名。 entry_definition で定義されていること
  :name,
  
  # 関連名も指定可能。この場合は、その関連モデルの処理対象の属性全てが有効な値でない場合
  :posts,
  
  # 関連モデルの持つ要素を個別指定したい場合は、ハッシュで定義
  posts: [
    # 同じように定義可能
    :title
  ]
]
```

#### 有効な値

有効な値かどうかの判定は、現在、以下の実装となっています。  

```ruby
def presence_value?(value)
  case value
  when ::Hash
    value.values.any? { |v| presence_value?(v) }
  when ::Array
    value.any? { |v| presence_value?(v) }
  when ::String
    ! value.blank?
  when ::TrueClass, ::FalseClass
    true
  else
    value ? true : false
  end
end
```

### required_attributes

インポート時に、有効な値でない場合に、インポート自体を行わない属性を定義した配列を返して下さい。  
データ構成は、 `optional_attributes` と同様です。  

### unique_indexes

インポートは、対象の ActiveRecord モデルの `primary_key` に対応するインポートデータの有無によって、  
追加か更新かを判定しますが、 `primary_key` の属性がインポートデータに含まれていない場合でも、  
更新処理を行いたい場合に、対象レコードを特定できる属性を定義した配列を返して下さい。  
データ構成は、 `optional_attributes` と同様です。  

```ruby
[
  :name, :birthday,
  posts: [:user_id, :title]
]
```

* 上記の場合、 user は name, birthday で特定され、 user.posts は user_id, title で特定されます
* foreign_key（上記の場合、 user_id ）は、インポートデータの有無に関わらず、データベースの正しい値で補完されます
* それ以外のもので、インポートデータに有効な値がなかった場合は、更新はせず、追加になります
* モデルやDBに、実際にユニークインデックスが定義されていなくても指定可能です
* ただし、その場合は、条件に合致したレコードが複数あった場合、どれが更新されるか保証できません

### required_condition

インポート時に、 `model_name` のインポートデータに `primary_key` がある場合、それが正しい値かどうかを
検証するための条件を定義した以下のようなハッシュを返して下さい。  

```ruby
{
  # 対象モデル（上の例なら user ）は、現在処理対象になっている group に属しているはず
  group_id: current_group.id
}
```

* `primary_key` や `unique_indexes` が指定されている場合のデータベース検索の条件に追加されます
* 関連モデルの場合は、親レコードの foreign_key が代わりに使用されます

### default_values

インポート時に、有効な値でない場合に、代わりにインポートする値を定義した以下のようなハッシュを返して下さい。  

```ruby
{
  name: '名無しの権兵衛',
  posts: {
    title: '無題'
  }
}
```

### translation_config

インポート/エクスポートで行われる translation の設定を定義した以下のようなハッシュを返して下さい。  

```ruby
{
  # 基点のスコープ
  scope: :bixformer,
  
  # translation を試みるスコープを、基点のスコープ配下に増やしたい場合に指定
  extend_scopes: [:version1, :version2]
}
```

上記の場合、ユーザが投稿したタイトルは

`bixformer.version2.user/posts.title`  
`bixformer.version1.user/posts.title`  
`bixformer.user/posts.title`  

の順で検索されます。translation が見つからなかった場合は、エラーになります。  

* CSVでは
    * カラム名に使用されます

### module_load_namespaces

`entry_definition` で指定されたクラス名のクラスを探索する namespace を定義した配列を返して下さい。  
ActiveRecord::Bixformer::Modeler::Base には、以下のように定義されています。  

```ruby
def module_load_namespaces(module_type)
  [
    "::ActiveRecord::Bixformer::#{module_type.to_s.camelize}::#{format.to_s.camelize}",
    "::ActiveRecord::Bixformer::#{module_type.to_s.camelize}",
  ]
end
```

* 要素の先頭から、 `要素::クラス名.to_s.classify.constantize` を試し、成功したものを採用します
* `module_type` には、 `:model` / `:attribute` / `:generator` のいずれかが渡されます
* `format` は、対象のデータ形式（ `:csv` ）になります

## 2. Runner を実装

CSVを扱う簡単なサンプルコードは以下のような感じになります。  

```ruby
runner = ActiveRecord::Bixformer::Runner::Csv.new

runner.add_modeler(Your::Modeler.new)

csv_data = runner.export(User.all, force_quotes: true)

runner.import(csv_data)
```

## その他

### 本フレームワークに定義されたModel一覧

For CSV

* base
    * has_one な関連モデル用。 has_many な関連モデルには使えない
* indexed
    * has_many な関連モデル用。 has_one な関連モデルには使えない
    * `size` オプションでインポート/エクスポートするサイズを指定
    * 属性の translation は `投稿%{index}のタイトル` のように指定
    * モデルの translation は `ユーザ%{index}の` のように指定（関連モデルがさらに indexed だった場合に使われます）

### 本フレームワークに定義されたAttribute一覧

* base
    * エクスポートでは `to_s` し、インポートでは `presence` する
* boolean
    * `true` / `false` オプションに、それぞれに対応する文字列を指定。デフォルトは、 `"true"` / `"false"`
    * インポート時、合致しない値は `nil` になる
* date
    * `format` オプションで、 `Date::DATE_FORMATS` のキーを指定。デフォルトは、 `default`
    * インポート時、合致しない値はエラーになる
* time
    * `format` オプションで、 `Time::DATE_FORMATS` のキーを指定。デフォルトは、 `default`
    * インポート時、合致しない値はエラーになる
* booletania
    * 詳細は、 https://github.com/ryoff/booletania
    * インポート時、合致しない値は `nil` になる
* enumerize
    * 詳細は、 https://github.com/brainspec/enumerize
    * インポート時、合致しない値はエラーになる
* override
    * モデルに処理を委譲する
    * モデルに `override_import_属性名` / `override_export_属性名` を定義すること
    * インポートでは、インポートデータ、エクスポートでは、 ActiveRecord の属性値が引数となる
    * インポート/エクスポートする値を返すこと

