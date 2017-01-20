class String
  def remove_all_punctuation
    self.gsub(/[^[:word:]]/, '').gsub('_','')
  end

  def remove_punctuation_but_spaces
    self.gsub(/[^[:word:]\s]/, '').gsub('_','')
  end

  def remove_word
    self.gsub('%WORD%', '')
  end
end

$poems = JSON.parse(File.read("./db/poems.json"))

$level_1 = {}

$poems.each do |poem|
  poem[1].each do |line|
    $level_1[line.remove_all_punctuation] = poem[0]
  end
end


$level_2 = {}

$poems.each_with_index do |poem, poem_index|
  poem[1].each_with_index do |line, line_index|
    line.remove_punctuation_but_spaces.split(' ').each do |word|
      $level_2[word] = [] if $level_2[word].nil?
      $level_2[word].push([poem_index, line_index])
    end
  end
end
