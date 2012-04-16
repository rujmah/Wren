require 'sinatra'
require 'mongoid'
require 'haml'
Mongoid.configure {|cfg| cfg.master = Mongo::Connection.new.db("sinatralist")}
class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name
  field :completed_at, type: DateTime
	validates_uniqueness_of :name
	key :name
end
get '/' do
  @tasks = Task.all
  haml :index, :format => :html5
end
post '/' do
  Task.create(:name => params[:name])
  redirect '/'   
end
get '/:id' do
  @task = Task.find(params[:id])
  haml :edit, :format => :html5
end
put '/:id' do
  task = Task.find(params[:id])
  task.completed_at = params[:completed] ?  Time.now : nil
  task.name = (params[:name])
  task.save ? (redirect '/') : (redirect '/' + task.id.to_s)
end
delete '/:id' do
  Task.find(params[:id]).destroy
  redirect '/' 
end
__END__
@@ layout
!!! 5
%html
	%head
		%meta(charset="utf-8")
		%title To Do List
		%style li.completed{text-decoration:line-through;}    
		%link{ rel: "stylesheet", type: "text/css", href: "http://degu.beetworks.com/css/bootstrap.css"}
		%link{ rel: "stylesheet", type: "text/css", href: "http://degu.beetworks.com/css/bootstrap-responsive.css"}
	%body
		%h1 <a title="Show Tasks" href="/">To Do List</a>
		= yield
@@ index
%form(action="/" method="POST")
	%input#name(type="text" name="name")
	%input(type="submit" value="Add Task!")
%ul#tasks
	-@tasks.each do |task|
		%li{:class => (task.completed_at ? "completed":  nil)}
			%a(href="/#{task.id}")= task.name
@@ edit
%form(action="#{@task.id}" method="POST")
	%input(name="_method" type="hidden" value="PUT")
	%input#name(type="text" name="name"value="#{@task.name}")
	%input#completed{:name => "completed",:type => "checkbox",:value => "done",:checked => (@task.completed_at ? "checked":  nil)}
	%input(name="commit" type="submit" value="Update")
%form(action="#{@task.id}" method="POST")
	%input(name="_method" type="hidden" value="DELETE")
	%input(type="submit" value="Delete") or <a href="/">Cancel</a>
