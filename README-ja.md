# Activerecord::Bixformer

## コレは何？

データベースのレコードを ActiveRecord を介して、他のデータ形式にインポート/エクスポートする処理をサポートするフレームワークです。  

以下のような特徴があります。  

* `accepts_nested_attributes_for` で定義された関連モデルも同時にインポート/エクスポート可能
* 設定用クラスを定義して使う。それにより、モデル、属性単位で処理をカスタマイズ可能
* その設定用クラスを複数定義して、実行時に切り替え可能

現在のところ、インポート/エクスポート可能なデータ形式は

* CSV

です。

## Installation

Gemfileに  

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

## Modelerの設定

ActiveRecord::Bixformer::Modeler::Base を継承して、以下のメソッドを適切に設定して下さい。  

### model_name

インポート/エクスポート対象のモデル名を返して下さい。  
例えばusersテーブルのデータが対象であれば、 `:user` です。  

### entry_definitions

インポート/エクスポート対象の属性と、それをどのように処理するかを定義した以下のようなハッシュを返して下さい。  

```ruby
{
  # 対象モデル（上の例なら user ）の処理を担当するModelクラス名
  # 省略可能で、省略された場合は :base が指定される
  # 指定可能な値については、「本フレームワークに定義されたModel一覧」を参照
  type: :base,

  # 処理対象の属性名をキー、その処理を担当するAttributeクラス名を値に持つハッシュ
  attributes: {
    # 指定可能な値については、「本フレームワークに定義されたAttribute一覧」を参照
    name: :base,
    # クラス名を配列にすると、2番目以降の要素はAttributeクラスに渡される
    joined_at: [:time, format: :ymdhms]
  },

  # 処理対象の関連モデル名をキー、その処理を定義したハッシュを値に持つハッシュ
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
  # 対象モデル（上の例なら user ）の属性名。 entry_definitions で定義されていること
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

* 上記の場合、 user は name, birthday で特定され、 user.post は user_id, title で特定されます
* foreign_key（上記の場合、 user_id ）は、
* モデルやDBで、実際にユニークインデックスがなくても指定可能です
* ただし、その場合は、条件に合致したどのレコードが更新されるかは保証できません

### default_value_map

インポート時に、有効な値でない場合に、代わりにインポートする値を定義した以下のようなハッシュを返して下さい。  

```ruby
{
  name: '名無しの権兵衛',
  posts: {
    title: '無題'
  }
}
```


#### 本フレームワークに定義されたModel一覧

* base

csv

* 

#### 本フレームワークに定義されたAttribute一覧

* base
* boolean
* date
* time
* booletania ( https://github.com/ryoff/booletania )
* enumerize ( https://github.com/brainspec/enumerize )
* override

##### Attributeで受け取れる引数




## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/activerecord-bixformer.

