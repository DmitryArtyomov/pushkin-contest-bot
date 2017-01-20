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
      answer = $level_1[question.remove_punctuation]
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
