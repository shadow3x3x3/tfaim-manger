require 'csv'

module Reader
  def self.base
    base_data = {
      :milk       => [],
      :cream      => [],
      :ice        => [],
      :vegetable  => [],
      :dessert    => [],
      :grain      => [],
      :baking     => [],
      :meat       => [],
      :seafood    => [],
      :egg        => [],
      :sweat      => [],
      :seasoning  => [],
      :nutritious => [],
      :drink      => [],
      :snack      => [],
      :meal       => [],
      :processed  => []
    }
    CSV.foreach('ref/base.csv').with_index do |row, index|
      case index
      when 0..16
        base_data[:milk] << split_by_ages(row)
      when 17..27
        base_data[:cream] << split_by_ages(row)
      when 28..32
        base_data[:ice] << split_by_ages(row)
      when 33..77
        base_data[:vegetable] << split_by_ages(row)
      when 78..90
        base_data[:dessert] << split_by_ages(row)
      when 91..127
        base_data[:grain] << split_by_ages(row)
      when 128..140
        base_data[:baking] << split_by_ages(row)
      when 141..172
        base_data[:meat] << split_by_ages(row)
      when 173..202
        base_data[:seafood] << split_by_ages(row)
      when 203..210
        base_data[:egg] << split_by_ages(row)
      when 211..224
        base_data[:sweat] << split_by_ages(row)
      when 225..250
        base_data[:seasoning] << split_by_ages(row)
      when 251..259
        base_data[:nutritious] << split_by_ages(row)
      when 260..279
        base_data[:drink] << split_by_ages(row)
      when 280..282
        base_data[:snack] << split_by_ages(row)
      when 283
        base_data[:meal] << split_by_ages(row)
      when 284
        base_data[:processed] << split_by_ages(row)
      end
    end
    base_data
  end

  def self.split_by_ages(row)
    row.map!(&:to_f)
    return {
      :kid      => row[0..1],
      :child    => row[2..7],
      :teenager => row[8..13],
      :adult    => row[13..18],
      :older    => row[19..24]
    }
  end
end