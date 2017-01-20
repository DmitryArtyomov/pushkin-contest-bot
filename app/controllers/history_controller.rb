class HistoryController < ApplicationController

  def index
    @tasks = []
    count = $redis.get('task_count').to_i    
    (0...count).each do |i|
      data = $redis.get("task#{i}")
      @tasks.push(JSON.parse(data)) unless data.nil?
    end
    @tasks.reverse!
  end
end
