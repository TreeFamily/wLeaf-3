class Znc
  include Cinch::Plugin
  prefix ">"
  match /adduser(?: (.+))?/i , method: :addUser
  
  
  
  def initialize(*args)
    super
    ObjectSpace.each_object(Team) do |teamObj|
      @team = teamObj
    end
    @mysql = nil
    ObjectSpace.each_object(Mysql) { |o|
	 @mysql = o
    }
  end
  
  def addUser(m,params)
    return unless @team.helper(m.user)
    args = params.split(" ")
    if args.last == "$staff"
	 args.pop()
	 staff = true
    else
	 staff = false
    end
    case args.length
    when 0
	 m.user.send "Missing parameters"
	 return
    when 1
	 newUser = User(args[0])
	 teamler = @team.helper(newUser)
	 auth = newUser.authname
	 account = newUser.authname
    when 2
	 newUser = User(args[0])
	 teamler = @team.helper(newUser)
	 auth = newUser.authname
	 account = args[1]
    when 3
	 newUser = User(args[0])
  	 teamler = @team.helper(newUser)
	 auth = args[1]
	 account = args[2] 
    end
    pass = password
    if (account =~ /^[a-zA-Z][a-zA-Z0-9_.@-]*$/) != 0
	 m.user.send "Accountname doesn't match regex for allowed accountnames: /^[a-zA-Z][a-zA-Z0-9_.@-]*$/"
	 return
    end
    
    createAccount(args[0],auth,account,pass,staff,teamler,m.user,newUser)
    
  end
  
  def createAccount(nick,auth,account,pass,staffserver,teamler,requester,user)
    target = "*admin"
    server = "user.znc.treefamily.nl 6667"
    if staffserver && (teamler || @team.admin(requester))
	 target = "=admin"
	 server = "staff.znc.treefamily.nl 9999"
	 allow = true
    elsif staffserver
	 requester.send "Sorry, but you cant make an account on the staffserver for this users, ask an admin for help"
	 return
    else
	 allow = !checkZncExists(account,auth)
    end
    @bot.send(target,"CloneUser clone #{account}")
    @bot.send(target,"set password #{account} #{pass}")
    @bot.send(target,"set nick #{account} #{auth}")
    @bot.send(target,"set ident #{account} #{account}")
    @bot.send(target,"set realname #{account} TreeZNC ~ #tree ~ #{auth}")
    user.send "Hi #{nick}, #{requester.nick} just made you an ZNC account"
    user.send "Account information"
    user.send "Server:      #{server}"
    user.send "Accountname: #{account}"
    user.send "Password:    #{pass}"
    user.send "If you need help with setting up your IRCClient, #{requester.nick} is able to help you"
    requester.send "Account #{account} created on #{server} with password: #{pass}"
    @bot.raw "CS #tree adduser *#{auth} 1"
    @bot.raw "CS #tree resync"
  end

  def password(size = 8)
    c = %w(b c d f g h j k l m n p qu r s t v w x z ch cr fr nd ng nk nt ph pr rd sh sl sp st th tr)
    v = %w(a e i o u y)
    f, r = true, ''
    (size * 2).times do
	 r << (f ? c[rand * c.size] : v[rand * v.size])
	 f = !f
    end
    r
  end
  
  def checkZncExists(accountname,authname)
    r = false
    
    begin
	 
    end
    
    
    return r
  end

end