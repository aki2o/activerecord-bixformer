# コレは何？

データベースのレコードを ActiveRecord を介して、他のデータ形式にインポート/エクスポートする処理をサポートするフレームワークです。  

以下のような特徴があります。  

* `accepts_nested_attributes_for` で定義された関連モデルを同時に扱える
* インポート時、インポートデータが正当な値かどうかをチェックする
* 設定用クラスを定義して使い、モデル、属性単位で処理をカスタマイズ可能

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

本フレームワークには以下のような概念を持った構成要素があります。

### Plan

インポート/エクスポートの一連の処理をどのように処理するかを定義する設定ファイルの役割です。  

### Model

ActiveRecord のモデルに対応して、そのモデルのインポート/エクスポート処理を担当するクラスです。  

ActiveRecord::Bixformer::Model::Base を継承した独自クラスを定義し、  
Planを適切に定義することで、それを使用して処理内容を切り替えることができます。  

### Attribute

ActiveRecord のモデルの持つ属性に対応して、その属性のインポート/エクスポート処理を担当するクラスです。  

ActiveRecord::Bixformer::Attribute::Base を継承した独自クラスを定義し、  
Planを適切に定義することで、それを使用して処理内容を切り替えることができます。  

## 使い方

### 1. Planの実装

ActiveRecord::Bixformer::Plan の機能を持ったクラスを以下のように定義して下さい。  

```ruby
class SamplePlan
  include ActiveRecord::Bixformer::Plan

  # [bixformer_for] インポート/エクスポート対象のモデル名の指定
  #
  #   - 文字列/シンボルで指定
  #
  #   例えば、usersテーブルのデータが対象であれば、 user です
  #
  bixformer_for :user


  # [bixformer_entry] インポート/エクスポート対象の属性/関連モデルと、それらの処理方法の定義
  #
  #   - ハッシュを返すProcオブジェクトかメソッド名/シンボルで指定
  #   - ここで指定された属性/関連モデルのみが処理対象となる
  #   - キーに指定可能な値は、 type, attributes, associations のいずれか
  #
  bixformer_entry -> do
    {
      # 対象モデル（上の例なら user ）の処理を担当するModelクラス名
      # 省略可能で、省略された場合は :base が指定される
      # 指定可能な値については、「本フレームワークに定義されたModel一覧」を参照
      # または、独自クラスを定義し、 bixformer_load_namespace を設定して
      type: :base,
      
      # 処理対象の属性名をキー、その処理を担当するAttributeクラス名を値に持つハッシュ
      attributes: {
      
        # 指定可能な値については、「本フレームワークに定義されたAttribute一覧」を参照
        # または、独自クラスを定義し、 module_load_namespaces を設定
        name: :base,
        
        # クラス名を配列にすると、2番目以降の要素は
        # Attributeインスタンス（この場合は、 ActiveRecord::Bixformer::Attribute::Time ）に渡される
        # 指定可能な値については、「本フレームワークに定義されたAttribute一覧」を参照
        joined_at: [:time, format: :ymdhms]
        
      },
      
      # 処理対象の関連名をキー、その処理を定義したハッシュを値に持つハッシュ
      associations: {

        # 関連名（例えば、 user.posts で関連レコードが辿れるなら posts ）で指定
        posts: {
        
          # 関連モデルの定義は、同じように、 type, attributes, associations が定義可能
          
          # type も、配列にすると、2番目以降の要素は
          # Modelインスタンス（この場合は、 ActiveRecord::Bixformer::Model::XXX::Indexed ）に渡される
          # XXX には処理対象のデータ形式（例えば、 Csv ）が入ります
          # 指定可能な値については、「本フレームワークに定義されたModel一覧」を参照
          type: [:indexed, size: 3]
          
        }
      }
    }
  end


  # [bixformer_preferred_skip_attributes] インポート時に、有効な値でない場合に、登録対象としない属性の定義
  #
  #   - 配列を返すProcオブジェクトかメソッド名/シンボルで指定
  #   - 有効な値については、「インポート時に有効な値」を参照
  #
  bixformer_preferred_skip_attributes :skippable_attributes

  def skippable_attributes
    [
      # ルートの要素は、対象モデル（上の例なら user ）への指定
      # bixformer_entry で定義されている属性で指定
      :name,
      
      # 関連名でも指定可能
      # この場合は、その関連モデルの処理対象の属性全てが有効な値でない場合に登録対象から外れる
      :posts,
      
      # 関連モデルの持つ要素を個別指定したい場合は、最後にハッシュで定義
      posts: [
      
        # ここは、postsに対する指定
        # 上の階層と同じようにネストして定義可能
        :title
        
      ]
    ]
  end


  # [bixformer_required_attributes] インポート時に、有効な値でない場合に、インポート自体を行わない属性の定義
  #
  #   - 配列を返すProcオブジェクトかメソッド名/シンボルで指定
  #   - データ構成は、 bixformer_preferred_skip_attributes と同様
  #
  bixformer_required_attributes -> do
    [
      # joined_atが有効な値でないデータは無視されて、インポートされない
      :joined_at
    ]
  end


  # [bixformer_unique_attributes] インポート時に、 primary_key 以外で更新処理を行う属性の定義
  #
  #   インポートは、対象の ActiveRecord モデルの primary_key （通常は id ）に対応するインポートデータの有無によって、
  #   追加か更新かを判定しますが、 primary_key の属性がインポートデータに含まれていない場合でも、
  #   更新処理を行いたい場合に、対象レコードを特定できる属性を設定するためのものです。
  #
  #   - 配列を返すProcオブジェクトかメソッド名/シンボルで指定
  #   - データ構成は、 bixformer_preferred_skip_attributes と同様
  #
  bixformer_unique_attributes -> do
    [
      :name, :birthday,
      
      posts: [:user_id, :title]
      
      # 上記の場合、 user は name, birthday で特定され、 user.posts は user_id, title で特定されます
      
      # foreign_key（上記の場合、 user_id ）は、bixformer_entry で指定されていなくても構いません
      # 自動で、データベースの正しい値で補完されます
      
      # それ以外のもので、インポートデータに有効な値がなかった場合は、更新はせず、追加になります
      
      # モデルやDBに、実際にユニークインデックスが定義されていなくても指定可能です
      # ただし、その場合は、条件に合致したレコードが複数あった場合、どれが更新されるか保証できません
    ]
  end


  # [bixformer_required_condition] インポート時に、インポートデータに必ず追加する条件の定義
  #
  #   - ハッシュを返すProcオブジェクトかメソッド名/シンボルで指定
  #   - bixformer_for で指定されたモデル（上記の場合、 user ）のインポートデータに自動で追加されます
  #
  bixformer_required_condition -> do
    {
      # 対象モデル（上の例なら user ）は、現在処理対象になっている group に属している
      group_id: current_group.id
      
      # インポートデータに primary_key や bixformer_unique_attributes がある場合、
      # 更新レコードをデータベース検索しますが、その際にも条件に追加されます
      
      # 関連モデルの場合は、この設定の有無に関わらず、親レコードの foreign_key が使用されるため、
      # 関連モデルへの指定はできません
      
      # primary_key が指定されているのに、データベース検索に失敗した場合には、
      # ActiveRecord::RecordNotFound 例外が raise されます
    }
  end


  # [bixformer_default_values] インポート時に、有効な値でない場合に、代わりにインポートする値の定義
  #
  #   - ハッシュを返すProcオブジェクトかメソッド名/シンボルで指定
  #   - この設定は、他の設定項目が全て処理された後のインポートデータに対して処理されます
  #   - インポートデータに対象のキー自体が存在していない（ bixformer_preferred_skip_attributes で指定されてる）属性には何もしません
  #
  bixformer_default_values -> do
    {
      # 単純な値のみ指定可能
      name: '名無しの権兵衛',

      # 関連モデルに対する指定
      posts: {
        title: '無題'
      }
    }
  end


  # [bixformer_translation_config] インポート/エクスポートで行われる translation の設定の定義
  #
  #   - CSVでは
  #     - カラム名に使用されます
  #
  #   - ハッシュを返すProcオブジェクトかメソッド名/シンボルで指定
  #   - キーに指定可能な値は、 scope, extend_scopes のいずれか
  #
  bixformer_translation_config -> do
    {
      # 基点のスコープ
      scope: :bixformer,
      
      # translation を検索するスコープを、基点のスコープ配下に増やしたい場合に指定
      extend_scopes: [:version2, :version1]
      
      # 上記の場合、ユーザが投稿したタイトルは
      #
      # bixformer.version2.user/posts.title
      # bixformer.version1.user/posts.title
      # bixformer.user/posts.title
      #
      # の順で検索され、最初に見つかった translation を実行します
      
      # translation が見つからなかったり、失敗した場合は、エラーになります
    }
  end


  # [bixformer_load_namespace] 独自クラスを探索する namespace の定義
  #
  #   - 文字列で指定
  #   - bixformer_entry で指定された独自クラスは、 "ここで指定した値::クラス種別::クラス名" で検索されます
  #   - クラス種別は、 Model, Attribute のいずれかです
  #   - クラス名は、bixformer_entry で指定した値を camelize した値です
  #
  bixformer_load_namespace "MyModule::Bixformer"

end
```

### 2. インポート/エクスポートの実装

インポート/エクスポートの処理を定義した Plan と、 ActiveRecord::Bixformer::From/To 配下に  
定義された各データ形式のインポート/エクスポート用クラスを使います。  

以下に、各データ形式の簡単なサンプルを示します。  

#### CSVの場合

```ruby
plan = SamplePlan.new

# エクスポート
bixformer = ActiveRecord::Bixformer::To::Csv.new(plan)

csv_data = CSV.generate do |csv|
  csv << bixformer.csv_title_row

  User.all.each do |user|
    csv << bixformer.csv_body_row(user)
  end
end

# インポート
bixformer = ActiveRecord::Bixformer::From::Csv.new(plan)

CSV.parse(csv_data).each do |csv_row|

  if csv_row.header_row?

    raise ArgumentError unless bixformer.verify_csv_titles(csv_row)

  else

    attributes = bixformer.assignable_attributes(csv_row)
    user       = User.new
    
    user.assign_attributes(attributes)
    user.save!

  end
end
```

## その他

### 本フレームワークに定義されたModel一覧

Model は各データ形式毎に異なる処理が必要になるため、データ形式毎に使えるクラスが異なります。  

#### CSV

* base
    * has_one な関連モデル用。 has_many な関連モデルには使えない
* indexed
    * has_many な関連モデル用。 has_one な関連モデルには使えない
    * `size` オプションでインポート/エクスポートするサイズを指定
    * 属性の translation は `投稿%{index}のタイトル` のように指定
    * モデルの translation は `ユーザ%{index}の` のように指定（関連モデルがさらに indexed だった場合に使われます）

### 本フレームワークに定義されたAttribute一覧

Attribute は、基本的にデータ形式に依らず、使用可能な想定をしています。  

* string
    * エクスポートでは `to_s` し、インポートでは `strip` して `presence` する
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
    * インポートでは、インポートデータ、エクスポートでは、 ActiveRecord のインスタンスが引数となる
    * インポート/エクスポートする値を返すこと

### インポート時に有効な値

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

