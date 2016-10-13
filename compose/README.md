Unifield for Linux AIO (All In One)
===================================

In this directory is a prototype of how we can ship a Unifield for
Linux AIO, using Docker Compose.

Installing Docker and Docker Compose
------------------------------------

If you are using a "container execution" system, like the Photon OS
from VMWare, you already have Docker.

If not, you'll need to install Docker, by following these
instructions:

You will need to install Docker Compose by doing
```sudo pip install docker-compose```.

Running the Containers
----------------------

Fetch the Unifield Linux AIO tar.gz file from:

Untar it.

From within the directory, run: ```docker-compose up -d```

Docker will pull the images from the Docker Hub (approximately 300
megs, one time), create the containers, link them together via
container networking, and then start them.

Unifield is now running, listening on the following ports:
 * http://localhost:8061 Web user interface
 * http://localhost:8069 XML-RPC over HTTP

You can stop the containers with ```docker-compose stop```.

If you use ```docker-compose down``` the containers will be
deleted. Since the uf-web and uf-server containers are stateless, this
does not delete any data. The PostgreSQL container is also stateless,
because it stores the database in a Docker volume.

Data is stored in the ```postgres-data``` sub-directory. Even if you
start and stop the containers, the data will continue to exist as long
as you do not delete that directory.  If you would like to restart
with no databases, use ```docker-compose down``` and then ```sudo rm
-rf postgres-data```.

Alternatively, as long as the db container is stopped, you can
use regular ```cp -pr``` to make snapshots of the Postgres database.
Be sure to use option ```-p``` with the copy, so that the permissions
and ownership stay the same. Other Unix tools like ```tar``` or
```rsync``` could be used to manage the Postgres snapshots as well, as long
as the ownership stays correct.

For example:

    docker-compose up -d
    # Load databases (see next section)
    docker-compose stop uf-server db
    sudo cp -pr postgres-data postgres-data-snap
    docker-compose start uf-server db
    # Run a test, corrupt all the product catalog. Oops.
    docker-compose stop uf-server db
    sudo rm -rf postgres-data && sudo cp -pr postgres-data-snap postgres-data
    docker-compose start uf-server db
    # Log in and find that the product catalog is not longer corrupted.


You do not need to restart the uf-web container because the Unifield
web server automatically reconnects if the Unifield server restarts
behind its back.

Loading data
------------

The container called uf-server has the ufload tool installed in it.

You can run it like this: ```docker-compose run uf-server ufload ...args...```

Because ufload is running in the uf-server container, if you will
be using the ```-file``` argument to load a file, you need to put
your file in the directory called uf-server, and then refer to the file
as /uf-server/filename. For example:

  cd unifield-aio-2-1-3
  docker-compose up -d
  sudo cp $HOME/databases/HQ1.dump uf-server
  docker-compose run uf-server ufload restore -i HQ1 -file /uf-server/HQ1.dump

When ufload is fetching from ownCloud, there is no need to copy the files
into the uf-server container. For example, this command will connect to
MSF's ownCloud as CloudUser, then restore all of the instances it finds
in the directory called AllHQ, leaving them with all user passwords
set to NotSoSecure:

  docker-compose run uf-server ufload \
    -user CloudUser -pw CloudUsersPassword -oc AllHQ restore \
    -adminpw NotSoSecure

See the ufload page on Github for more information on ufload.

Caveats
-------

Multiple Instances

Because the Docker Compose configuration is written to expose
ports 8061 and 8069, you cannot run more than one Unifield instance
at a time. If you made a copy of the directory, and edited
docker-compose.yml in the second copy to change "8061:8061" to just
"8061", then Docker will choose it's own port to expose. You can
find the port using ```docker-compose port uf-web 8061```, which
will print the local port.

Like this, you could potentially run several instances of Unifield
on the same server. Scripts that need to know how to contact them
could call ```docker-compose port``` to find out the current port
assignment.

Building and pushing
--------------------

Building and pushing is done by the Unifield Support team. If you just
want to run Unifield, you do not need to read this section.

Building is simplified by a makefile. Type "make help" to see the
targets.

The version of Unifield is set by the VER variable in the
Makefile. It can be set on the command line as in:

	make build push VER=2.1-3p1

