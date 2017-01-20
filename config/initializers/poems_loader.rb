class String
  def remove_punctuation
    self.gsub(/[^[:word:]]/, '').gsub('_','')
  end
end

$poems = JSON.parse(File.read("./db/poems.json"))

$level_1 = {}

$poems.each do |poem|
  poem[1].each do |line|
    $level_1[line.remove_punctuation] = poem[0]
  end
end
