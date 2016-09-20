class SamplePreferredSkipAttribute
  class << self
    def user_all_default
      [
        :id,
        "posts" => [
          :id,
          :status,
          :secret,
          :tags,
          "tags" => [:name]
        ]
      ]
    end
  end
end
