class Modeler::User < ActiveRecord::Bixformer::Modeler::Base
  def model_name
    :user
  end

  def entry_definitions
    {
      attributes: {
        id: :base,
        account: :base,
        joined_at: :base
      },
      associations: {
        profile: {
          attributes: {
            name: :base,
            age: :base
          }
        },
        posts: {
          type: :indexed,
          arguments: {
            size: 5,
          },
          attributes: {
            id: :base,
            status: :enumerize,
            private: :boolean
          },
          associations: {
            tags: {
              type: :indexed,
              arguments: {
                size: 3,
              },
              attributes: {
                name: :base
              }
            }
          }
        }
      }
    }
  end

  def optional_attributes
    [
      :id,
      
    ]
  end
end
