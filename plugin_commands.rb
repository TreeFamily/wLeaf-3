class Commands
  include Cinch::Plugin
  prefix ">"
  match /(.+)(.)*/i , method: :command
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
			  "myaccess","access", "addhelper","addadmin","suspend","unsuspend"
			  ]
  end
  
  def command(m,*args)
    return if @commands.include?(args[0]) || @team.helper(m.user)!=true
    m.user.send "command #{args[0]} is not known"
  end


end