class SampleEntryDefinition
  class << self
    def user_all_using_indexed_association
      {
        attributes: {
          id: :base,
          account: :base,
          joined_at: [:time, format: :ymdhms]
        },
        associations: {
          profile: {
            attributes: {
              name: :base,
              email: :base,
              age: :base
            }
          },
          posts: {
            type: [:indexed, size: 3],
            attributes: {
              id: :base,
              content: :base,
              status: :enumerize,
              secret: :booletania
            },
            associations: {
              tags: {
                type: [:indexed, size: 2],
                attributes: {
                  name: :base
                }
              }
            }
          }
        }
      }
    end
  end
end
