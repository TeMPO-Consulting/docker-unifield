# Requirement

Local user should be in this group: **docker**

Then fetch this repository:

    git clone git@github.com:TeMPO-Consulting/docker-unifield

And go into this one.

# Build

Then you have to build an image from this repository:

     docker build -t unifield:latest .

Now you have to run the container. But have a look to an example of what could be done:

    docker run -d -P --name unifield3 -v /home/qt/Development/Unifield:/opt/Unifield unifield:latest /usr/bin/supervisord

We know that:

  * it will be run in daemon (**-d** option)
  * we open all ports given by *EXPOSE* option in the Dockerfile
  * the name of the container will be **unifield3**
  * we mount our local directory */home/olivier/projets/Unifield* as */opt/Unifield* in our new container
  * on our machine, we use the **unifield:latest** docker base to create this container (we built it previously)
  * the default command used when the container is launched is **/usr/bin/supervisord** so that all services will be available (ssh, postgresql, etc.)

And now you're running postgreSQL/ssh for Unifield.

# Access to the container

As SSHD is launched on the machine, we just have to do:

    ssh -p 49153 docker@localhost

And we enter in the container.

> Where do you found that 49153 is the right port for that?

To find the right port, you have some solutions.

## Use static ports

When you launch your container, just give ports you want. For previous command that run the container, we can have:

    docker run -d -p :5432 -p :22 -p 8000:8061 --name unifield3 -v /home/qt/Development/Unifield:/opt/Unifield unifield:latest /usr/bin/supervisord

This follow this rule:

    -p IP:host_port:container_port

So we launch the container with 5432 and 22 static ports and 8061 port is redirected to 8000 one.

## List ports for each docker container

Just do this:

    docker ps

And you will see in the "ports" column the ports translations.

## Use a script

You can find the given port for SSH using this command:

    docker inspect --format='{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostPort}}' unifield3

This will return *49153* for an example.

# Manage containers

If you want to stop the container:

    docker stop unifield3

To run an existing container:

    docker start unifield3

That's all!

# Find 5432 port

Just do this:

    docker inspect --format='{{(index (index .NetworkSettings.Ports "5432/tcp") 0).HostPort}}' unifield

# Use X11 capabilities and run Eclipse into the Docker environment

**Before** launching the build of this directory, decomment this line:

    RUN apt-get install -y eclipse

Then:

  * build your docker
  * run a docker
  * access it via ssh using this command:

    ssh -X -p 49153 docker@localhost

replace **49153** by the port used by your ssh connection.

Then, in the given SSH prompt, just tape:

    eclipse

and it will launch Eclipse.
