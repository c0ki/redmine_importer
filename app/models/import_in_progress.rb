require 'nkf'
require 'iconv'

class ImportInProgress < ActiveRecord::Base
  unloadable
  belongs_to :user
  belongs_to :project
  
  before_save :encode_csv_data
  
  private
  def encode_csv_data
    return if self.csv_data.blank?

    if self.encoding == 'ISO'
      converter = Iconv.new('UTF-8', 'iso-8859-1')
      self.csv_data = converter.iconv(self.csv_data)
      self.encoding = 'U';
    end

    nkf_encode = nil

    case self.encoding
      when "U"
        nkf_encode = "-W"
      when "EUC"
        nkf_encode = "-E"
      when "S"
        nkf_encode = "-S"
    end

    self.csv_data = NKF.nkf("#{nkf_encode} -w", self.csv_data) if nkf_encode.nil?
  end
end
