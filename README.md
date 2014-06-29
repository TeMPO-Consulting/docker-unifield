# First use

    sudo docker build -t unifield:latest .
    sudo docker run -d -P --name unifield -v /home/olivier/projets/Unifield:/opt/Unifield unifield:latest /usr/bin/supervisord

# If stopped

    sudo docker start test2
    sudo docker attach test2

