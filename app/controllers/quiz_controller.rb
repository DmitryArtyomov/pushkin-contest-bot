class QuizController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def task
    level = params['level'].to_i
    task_id = params['id']
    question = params['question']
    time_received = Time.now.to_i
    render json: 'OK'

    answer = nil

    case level
    when 1
      answer = $level_1[question.remove_all_punctuation]
    when 2
      resulting_indexes = find_poem_line(question)
      answer = find_swapped_word(question, resulting_indexes)      
    when 3, 4
      resulting_indexes = nil
      answers = []
      question.split("\n").each do |question_line|
        if resulting_indexes.nil?
          resulting_indexes = find_poem_line(question_line)
          answers.push(find_swapped_word(question_line, resulting_indexes))
        else
          resulting_indexes = [[resulting_indexes[0][0],resulting_indexes[0][1] + 1]]
          answers.push(find_swapped_word(question_line, resulting_indexes))
        end
      end
      answer = answers.join(',')
    when 5
      word_indexes = []      
      split_question = question.remove_punctuation_but_spaces.split(' ')
      # Find poems indexes for each word
      split_question.each do |question_word|
        word_indexes.push($level_2[question_word])
      end
      resulting_indexes = []
      # For each word try to find poem which includes every other word      
      word_indexes.each do |word_index|
        temp = []
        word_indexes.each do |index|
          temp.push(index)
        end
        temp.delete(word_index)
        res = nil
        temp.each do |temp_index|
          if res.nil?
            res = temp_index
          else
            res &= temp_index
          end
        end
        resulting_indexes.push(res)
      end
      # The word where it wouldn't be nil - the replaced word
      arr_index = resulting_indexes.find_index { |x| !x.empty? }
      unless arr_index.nil?
        replaced_word = split_question[arr_index]

        poem_index = resulting_indexes[arr_index][0][0]
        poem_line_index = resulting_indexes[arr_index][0][1]
        source_poem = $poems[poem_index][1][poem_line_index]
        source_word = source_poem.remove_punctuation_but_spaces.split(' ')[arr_index]

        answer = source_word + ',' + replaced_word
      end

    end

    send_answer(answer, task_id)
    SaveTaskWorker.perform_async(question, task_id, level, time_received, answer)
  end  
  
  def find_swapped_word(question, indexes)
    answer = nil    
    unless indexes.nil?
      unless $poems[indexes[0][0]][1][indexes[0][1]].nil?
        regex = question.sub('%WORD%', 'MySwapWord').remove_punctuation_but_spaces.squeeze(' ').strip.sub('MySwapWord','([[:word:]]+)')
        poem_line = $poems[indexes[0][0]][1][indexes[0][1]].remove_punctuation_but_spaces.strip.squeeze(' ')
        answer = poem_line[/#{regex}/, 1]
      end
    end
    answer
  end

  def find_poem_line(question)
    search_result = []
    question.remove_word.remove_punctuation_but_spaces.split(' ').each do |question_word|
      search_result.push($level_2[question_word])
    end
    search_result.compact!
    resulting_indexes = nil
    search_result.each do |s_result|
      if resulting_indexes.nil?
        resulting_indexes = s_result
      else
        resulting_indexes &= s_result
      end
    end
    resulting_indexes
  end

  def send_answer(answer, task_id)
    uri = URI("http://pushkin.rubyroidlabs.com/quiz")
    parameters = {
      answer: answer,
      token: '85c77f698e01d77746bff95927f5bd00',
      task_id: task_id
    }    
    Net::HTTP.post_form(uri, parameters)
  end
end
