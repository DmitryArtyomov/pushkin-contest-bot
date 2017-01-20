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

      unless resulting_indexes.nil?
        regex = question.sub('%WORD%', 'MySwapWord').remove_punctuation_but_spaces.squeeze(' ').sub('MySwapWord','([[:word:]]+)')
        poem_line = $poems[resulting_indexes[0][0]][1][resulting_indexes[0][1]].remove_punctuation_but_spaces.squeeze(' ')
        answer = poem_line[/#{regex}/, 1]
      end
    end

    send_answer(answer, task_id)
    SaveTaskWorker.perform_async(question, task_id, level, time_received, answer)
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
