class SampleUniqueAttribute
  class << self
    def user_all_default
      [
        profile: [:user_id],
        posts: [
          tags: [:post_id, :name]
        ]
      ]
    end
  end
end
