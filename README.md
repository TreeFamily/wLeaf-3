wLeaf 3 - A ZNC management bot
===============================

Introduction
------------
wLeaf is a bot made for TreeFamily to manage our ZNC server.
The first 2 versions have been written from scratch in PHP

Requirements
------------
**RubyGems**

**Cinch (IRC bot framework)**

	gem install cinch
**Mysql-ruby**

	gem install mysql
**[Ansifilter](http://www.andre-simon.de/zip/download.html#ansifilter)** *only for the webinterface*

	
Databases
---------
**Team table**

	mysql> describe team;
	+-----------+--------------+------+-----+---------+----------------+----------------+
	| Field     | Type         | Null | Key | Default | Extra          | Comment        |
	+-----------+--------------+------+-----+---------+----------------+----------------+
	| id        | int(11)      | NO   | PRI | NULL    | auto_increment |                |
	| auth      | varchar(255) | NO   | UNI | NULL    |                |                |
	| access    | varchar(255) | NO   |     | NULL    |                | admin / helper |
	| suspended | tinyint(1)   | NO   |     | NULL    |                |                |
	+-----------+--------------+------+-----+---------+----------------+----------------+

**users table**

	mysql> describe users;
	+-----------+--------------+------+-----+---------+----------------+
	| Field     | Type         | Null | Key | Default | Extra          |
	+-----------+--------------+------+-----+---------+----------------+
	| id        | int(11)      | NO   | PRI | NULL    | auto_increment |
	| auth      | varchar(255) | NO   |     | NULL    |                |
	| account   | varchar(255) | NO   | UNI | NULL    |                |
	| suspended | tinyint(1)   | NO   |     | NULL    |                |
	+-----------+--------------+------+-----+---------+----------------+
	


Author
------

* [Werring](mailto:werring<at>treefamily<dot>com)