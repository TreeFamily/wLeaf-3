class Commands
  include Cinch::Plugin
  prefix ">"
  match /(.+)(?: (.+))?/i , method: :command
  match /commands/ , method: :commands
  #*/
  def initialize(*args)
    super
    ObjectSpace.each_object(Team) do |teamObj|
      @team = teamObj
    end
    @mysql = nil
    ObjectSpace.each_object(Mysql) { |o|
	 @mysql = o
    }
    @commands = ["autovoice",
			  "join","part","quit",
			  "myaccess","access", "addhelper","addadmin","suspend","unsuspend",
			  "adduser",
			  "commands",
			  "createwebpass"
			  ]
  end
  
  def command(m,command)
    args = command.split(" ")
    return if @commands.include?(args[0]) || !@team.helper(m.user)
    m.user.send "command #{args[0]} is not known"
  end
  
  def commands(m)
    commandos = []
    m.user.send "I know the following commands:"
    @commands.each do |commando|
	  commandos.push("#{commando}")
	  if commandos.length > 4
	    m.user.send commandos.join(", ")
	    commandos = []
	  end
    end
    if commandos.length>0
	 m.user.send commandos.join(", ")
    end
  end


end