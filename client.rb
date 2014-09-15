require 'bundler/setup'
Bundler.require(:default)

Dotenv.load

module Logan
  class Todo
    attr_accessor :todolist_id
  end
end

logan = Logan::Client.new(ENV.fetch('BASECAMP_ACCOUNT_ID'), { username: ENV.fetch('BASECAMP_USERNAME'), password: ENV.fetch('BASECAMP_PASSWORD') }, "bcx-todos (#{ENV.fetch('EMAIL')})")

todos_with_due_dates = []
projects = logan.projects
todolists = logan.todolists

todolists.each do |todolist|
  if todolist.remaining_count > 0
    todolist.remaining_todos.each do |todo|
      todos_with_due_dates << todo if todo.due_at
    end
  end
end

todos_with_due_dates.sort_by(&:due_at).group_by(&:due_at).each_with_index do |(due_at, todos), index|
  puts unless index == 0 # blank line between dates
  puts "#{due_at}".colorize(color: (Date.parse(due_at) < Date.today ? :red : :green), mode: :bold)
  todos.group_by(&:todolist_id).each_with_index do |(todolist_id, todos), index|
    puts unless index == 0 # blank line between todolists
    todolist = todolists.find { |l| l.id == todolist_id }
    project = projects.find { |p| p.id == todolist.project_id.to_i }
    puts "[#{project.name}: #{todolist.name}]".colorize(mode: :bold)
    todos.each do |todo|
      puts "* #{todo.content}"
    end
  end
end
