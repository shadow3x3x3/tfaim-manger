require 'csv'

module Reader
  FOOD_REF = {
    :milk       => (0..16),
    :cream      => (17..27),
    :ice        => (28..32),
    :vegetable  => (33..77),
    :dessert    => (78..90),
    :grain      => (91..127),
    :baking     => (128..140),
    :meat       => (141..172),
    :seafood    => (173..202),
    :egg        => (203..210),
    :sweet      => (211..224),
    :seasoning  => (225..250),
    :nutritious => (251..259),
    :drink      => (260..279),
    :snack      => (280..282),
    :meal       => (283..283),
    :processed  => (284..284)
  }

  def self.intake
    intake = {}
    raw_intake = CSV.read('ref/base.csv', :headers=>true)
    raw_intake.headers.each do |age_class|
      age = age_class.to_sym
      intake[age] ||= {}
      FOOD_REF.each do |food, indexs|
        intake[age][food] ||= raw_intake[age_class][indexs].map!(&:to_f)
      end
    end
    intake
  end

  def self.food_list
    list = {}
    FOOD_REF.each_key do |food|
      list[food] = format_reader(food.to_s)
    end
    list
  end

  def self.format_reader(food)
    array = []
    File.open('assets/foods/' + food, 'r:UTF-8') do |f|
      f.each_line { |line| array << line }
    end
    array
  end
end