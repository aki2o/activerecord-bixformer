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
  end
end
