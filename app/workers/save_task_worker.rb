class SaveTaskWorker
  include Sidekiq::Worker

  def perform(question, task_id, level, time_received, answer)
    $redis ||= Redis.new    
    task = {
      'question' => question,
      'task_id' => task_id,
      'level' => level,
      'time_received' => time_received,
      'answer' => answer
    }
    count = $redis.get('task_count').to_i
    count = 0 if count.nil?
    $redis.set('task_count', (count + 1).to_s)
    $redis.set("task#{count}", task.to_json)
  end
end
