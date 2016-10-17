class SampleCsv
  class << self
    def user_all_using_indexed_association_title
      <<EOS
UserSystemCode,AccountName,JoinTime,Name,E-mail,Age,PostSystemCode1,Body1,Status1,IsSecret1,UserPost1TagName1,UserPost1TagName2,PostSystemCode2,Body2,Status2,IsSecret2,UserPost2TagName1,UserPost2TagName2,PostSystemCode3,Body3,Status3,IsSecret3,UserPost3TagName1,UserPost3TagName2
EOS
    end

    def user_all_using_indexed_association_line_new(index: nil)
      <<EOS
,import-taro#{index},2016 09 01 (15:31:21),Taro Import,"",13,,Hello!,Now on show,No,Foo,Fuga,,Good bye!,Write in Process,Yes,,,,,,,,
EOS
    end

    def post_using_mapped_tag_title
      <<EOS
PostCode,Body,Status,Tag_Hoge_Memo,Tag_Fuga_Memo,Tag_Bar_Memo
EOS
    end
  end
end
