# First use

    sudo docker build -t unifield:latest .
    sudo docker run -d -P --name unifield -v /home/olivier/projets/Unifield:/opt/Unifield unifield:latest /usr/bin/supervisord

# If stopped

    sudo docker start test2
    sudo docker attach test2

# Find 5432 port

    sudo docker inspect --format='{{(index (index .NetworkSettings.Ports "5432/tcp") 0).HostPort}}' unifield

