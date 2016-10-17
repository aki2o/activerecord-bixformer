class SampleEntry
  class << self
    def user_all_using_indexed_association
      {
        attributes: {
          id: :string,
          account: :string,
          joined_at: [:time, format: :ymdhms]
        },
        associations: {
          profile: {
            attributes: {
              name: :string,
              email: :string,
              age: :integer
            }
          },
          posts: {
            type: [:indexed, size: 3],
            attributes: {
              id: :string,
              content: :string,
              status: :enumerize,
              secret: :booletania
            },
            associations: {
              tags: {
                type: [:indexed, size: 2],
                attributes: {
                  name: :string
                }
              }
            }
          }
        }
      }
    end

    def post_using_mapped_tag
      {
        attributes: {
          id: :string,
          content: :string,
          status: :enumerize
        },
        associations: {
          tags: {
            type: [
              :mapped,
              key: :name,
              in: %w( Hoge Fuga Foo ),
              translate: -> (name) { name == 'Foo' ? 'Bar' : name }
            ],
            attributes: {
              memo: :string
            }
          }
        }
      }
    end
  end
end
