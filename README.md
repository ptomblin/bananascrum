# Directions for setting up on a new install of Debian 5 #

# Install JDK 6 #
	sudo apt-get install open-jdk-6-jdk
	vim .profile
	  add 'export SSL_CERT_FILE=/etc/java-6-openjdk/' to the end of file
	. .profile

# Install mysql #
	sudo apt-get install mysql-server
	  root password: <pick a secure password>
* login to mysql
	mysql -u root -p '<password_from_above>'
* create bananascrum user and database:
	CREATE USER 'bananascrum'@'localhost' IDENTIFIED BY '<pick a secure password>';
	CREATE DATABASE bananascrum DEFAULT CHARACTER SET utf8;
	GRANT ALL ON bananascrum.* TO 'bananascrum'@'localhost';

# Install git (if needed) #
	sudo apt-get install libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev build-essential
	wget https://github.com/git/git/archive/v2.6.2.tar.gz
	tar -zxf v2.6.2.tar.gz
	cd git-2.6.2
	make prefix=/usr/local all
	sudo make prefix=/usr/local install
	cd ~
	sudo ln -s /usr/local/bin/git /usr/bin/git

# Install Ant #
	sudo apt-get install ant

# Install memcached #
	sudo apt-get install memcached

# Install jruby 1.7.4 #
	wget https://s3.amazonaws.com/jruby.org/downloads/1.7.4/jruby-bin-1.7.4.tar.gz
	tar -zxf jruby-bin-1.7.4.tar.gz
	sudo mv jruby-1.7.4/ /usr/lib/jruby
	sudo ln -s /usr/lib/jruby/bin/jruby /usr/bin/jruby
	sudo ln -s /usr/lib/jruby/bin/jrubyc /usr/bin/jrubyc

# Install required gems #
	jruby -S gem install rake
	jruby -S gem install bundle --no-ri --no-rdoc

# Install other required software #
	sudo apt-get install python-sphinx
	sudo apt-get install zip

# Build bananascrum #
	cd bananascrum
	jruby -S bundle install --without development test
	jruby -S rake dist:package
	cd bananascrum/build
	cp config.yml.sample config.yml
	cp database.yml.sample database.yml
	cp livesync_hosts.yml.sample livesync_hosts.yml
	vim database.yml
	  change database to bananascrum
	  change username:password to bananascrum:<bananascrum_password_from_above>
	ant
	cd ~

# Install Glassfish 3 #
	wget http://download.java.net/glassfish/3.1.2.2/release/glassfish-3.1.2.2.zip
	unzip glassfish-3.1.2.2.zip
	sudo mv glassfish3 /opt/glassfish3
	vim .profile
	  add 'export PATH=/opt/glassfish3/bin:$PATH' to the end of file
	. .profile
	asadmin start-domain

# Deploying WAR file to Glassfish #
	asadmin deploy ~/bananascrum/build/bananascrum.war

# Manually create the dqm admin account #
* Make a salt & hash your password
	jruby -S irb
	  require 'digest/sha1'
	  password = 'yourpassword'
	  salt = self.object_id.to_s + rand.to_s
	  Digest::SHA1.hexdigest(password + "adirockscs" + salt)
  * Connect to your mysql instance and run this query (filling in the needed information)
	INSERT INTO users (
	 `id`,
	 `login`,
	 `first_name`,
	 `last_name`,
	 `email_address`,
	 `password`,
	 `salt`,
	 `active_project_id`,
	 `type`,
	 `domain_id`,
	 `new_offers`,
	 `service_updates`,
	 `terms_of_use`,
	 `active`,
	 `blocked`,
	 `like_spam`)
 
	VALUES (1, 'username', 'firstname', 'lastname', 'admin@domain.com', 'result_of_digest_above', 'salt_from_above', NULL, 'Admin', 1, 0, 0, 1, 1, 0, 0);