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
    @count = 0
  end
  
  def addUser(m,params)
    return unless @team.helper(m.user)
    args = params.split(" ")
    staff = force = false
    if args.last == "$staff" 
	 args.pop()
	 staff = true
    elsif args.last == "$force"
	 args.pop()
	 force = true
    end
    if args.last == "$staff" 
	 args.pop()
	 staff = true
    elsif args.last == "$force"
	 args.pop()
	 force = true
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
    
    createAccount(args[0],auth,account,pass,staff,teamler,m.user,newUser,force)
    
  end
  
  def createAccount(nick,auth,account,pass,staffserver,teamler,requester,user,force)
    target = "*admin"
    server = "user.znc.treefamily.nl 6667"
    if staffserver && (teamler || @team.admin(requester))
	 target = "=admin"
	 server = "staff.znc.treefamily.nl 9999"
	 allowAccount = allowAuth = true
    elsif staffserver
	 requester.send "Sorry, but you cant make an account on the staffserver for this users, ask an admin for help"
	 return
    else
	 allowAccount = !checkZncExists(account)
	 allowAuth = !checkAuthExists(account)
    end
    
    if (allowAuth && allowAccount) || (force && @team.admin(requester))
	 added= {'error' => false}
	 added = addUserToDb(auth,account) unless staffserver
	 if !added['error'] || (staffserver && (@team.admin(requester) || teamler)) || (force && @team.admin(requester))
		@bot.send(target,"CloneUser clone #{account}")
		@bot.send(target,"set password #{account} #{pass}")
		@bot.send(target,"set nick #{account} #{auth}")
		@bot.send(target,"set altnick #{account} #{auth}`")
		@bot.send(target,"set ident #{account} #{account}")
		@bot.send(target,"set realname #{account} TreeZNC ~ #tree ~ #{auth}")
	   if nick != requester.nick
		user.send "Hi #{nick}, #{requester.nick} just made you a ZNC account"
		user.send "Account information"
		user.send "Server:      #{server}"
		user.send "Accountname: #{account}"
		user.send "Password:    #{pass}"
		user.send "If you need help with setting up your IRCClient, #{requester.nick} is able to help you"
		@bot.raw "CS #tree adduser *#{auth} 1"
		@bot.raw "CS #tree resync"
	   end
	   requester.send "Account #{account} created on #{server} with password: #{pass}"

	 else
	   requester.send  "Couldn't add #{nick}, Error: #{addedToDb['errormsg']}"
	 end
    elsif force
	 requester.send "Ask an admin to force add an account"
    else
	 if !allowAuth && !allowAccount
	   requester.send "Accountname already taken and authname already has a ZNC"
	 elsif !allowAuth
	   requester.send "Authname already has a ZNC"
	 else
	   requester.send "Accountname already taken"
	 end
    end
  end

  def password(size = 6)
    c = %w(b c d f g h j k l m n p qu r s t v w x z ch cr fr nd ng nk nt ph pr rd sh sl sp st th tr)
    v = %w(a e i o u y)
    f, r = true, ''
    (size * 2).times do
	 r << (f ? c[rand * c.size] : v[rand * v.size])
	 f = !f
    end
    r
  end
  
  def checkZncExists(accountname)
    r = false
    count = 0
    qry = "SELECT COUNT(*) FROM `users` WHERE `account`='#{accountname}'"
    res = @mysql.query(qry)
    res.each do |ret|
	 count = Integer(ret[0])
    end
    if count > 0
	 r = true
    end
    return r
  end
  def checkAuthExists(authname)
    r = false
    count = nil
    qry = "SELECT COUNT(*) FROM `users` WHERE `auth`='#{authname}'"
    res = @mysql.query(qry)
    res.each do |ret|
	 count = Integer(ret[0])
    end
    if count > 0
	 r = true
    end
    return r
  end
  def addUserToDb(auth,account)
    returnVal = {'error'=>false}
    begin
      @mysql.query "INSERT INTO `users` (`auth`, `account`, `suspended`) VALUES ('#{auth}','#{account}',0)"
	 rescue Mysql::Error => e
	   returnVal = {'error'=>true,'errormsg'=>e.error}
	   bot.logger.debug returnVal.to_s
	 ensure
    end
    return returnVal
  end


end