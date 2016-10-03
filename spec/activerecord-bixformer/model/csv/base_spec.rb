require 'spec_helper'

describe ActiveRecord::Bixformer::Model::Csv::Base do
  it_should_behave_like "ActiveRecord::Bixformer::ModelCallback",
                        User.all.first,
                        CSV.parse(
                          [
                            SampleCsv.user_all_using_indexed_association_title,
                            SampleCsv.user_all_using_indexed_association_line_new
                          ].join,
                          headers: true
                        ).first
end
