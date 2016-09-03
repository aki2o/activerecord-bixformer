user = User.new(account: 'sample-taro', joined_at: Time.current)
user.save!

user.build_profile(name: 'Taro Sample', age: 24).save!

user.posts.build(status: :published, secret: false, content: 'Hello!').save!
user.posts.build(status: :wip, secret: true).save!

user.posts.first.tags.build(name: 'Hoge').save!
user.posts.first.tags.build(name: 'Fuga').save!
user.posts.first.tags.build(name: 'Foo').save!
