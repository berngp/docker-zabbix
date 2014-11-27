Docker Zabbix
========================

## Container

The container provides the following *Zabbix Services*, please refer to the [Zabbix documentation](http://www.zabbix.com/) for additional info.

* A *Zabbix Server* at port 10051.
* A *Zabbix Java Gateway* at port 10052.
* A *Zabbix Web UI* at port 80 (e.g. `http://$container_ip/zabbix` )
* A *Zabbix Agent*.
* A MySQL instance supporting *Zabbix*, user is `zabbix` and password is `zabbix`.
* A Monit deamon managing the processes (http://$container_ip:2812, user 'myuser' and password 'mypassword').


## Usage

You can run Zabbix as a service executing the following command.

```
docker run -d -P --name zabbix  berngp/docker-zabbix
```

The command above is requesting *docker* to run the *berngp/docker-zabbix* image in the background, publishing all ports to the host interface assigning the name of **zabbix** to the running instance.
Run `docker ps -f name=zabbix` to review which port was mapped to the container's port '80', the *Zabbix Web UI*.

Open `http://<ip of the host running the docker deamon>:<host port mapped to the container's port 80>/zabbix`

In the example bellow the container's port `80` is mapped to `49184`.

```
$ docker ps -f name=zabbix
CONTAINER ID        IMAGE                         COMMAND                CREATED             STATUS              PORTS                                                                                                NAMES
970eb1571545        berngp/docker-zabbix:latest   "/bin/bash /start.sh   18 hours ago        Up 2 hours          0.0.0.0:49181->10051/tcp, 0.0.0.0:49182->10052/tcp, 0.0.0.0:49183->2812/tcp, 0.0.0.0:49184->80/tcp   zabbix
```

If you want to bind the container's port with specific ports from the host running the docker daemon you can execute the following:

```
docker run -d \
           -p 10051:10051 \
           -p 10052:10052 \
           -p 80:80       \
           -p 2812:2812   \
           --name zabbix  \
           berngp/docker-zabbix
```

The above command will expose the *Zabbix Server* through port *10051* and the *Web UI* through port *80* on the host instance, among others and associate it with the name `zabbix`.
Be patient, it takes a minute or two to configure the MySQL instance and start the proper services. You can tail the logs using `docker logs -f $contaienr_id`.

After the container is ready the *Zabbix Web UI* should be available at `http://$container_ip/zabbix`. User is `admin` and password is `zabbix`.


## Exploring the Docker Zabbix Container

Sometimes you might just want to review how things are deployed inside a running container, you can do this by executing a _bash shell_ through _docker's exec_ command.
Execute the command bellow to do it.

```
docker exec -i -t zabbix /bin/bash
```

## Issues and Bugs.

Feel free to report any problems [here](https://github.com/berngp/docker-zabbix/issues).


# Developers

I suggest you install docker through your distribution, if using Mac OSX I suggest you leverage [boot2docker](http://boot2docker.io/), as an option the project has a *Vagrantfile* that you can leverage.

## Setting your Docker environment with the Vagrantfile

To run the included _Vagrantfile_ you will need [VirtualBox](https://www.virtualbox.org/) and [Vagrant](http://www.vagrantup.com/) installed. Currently I am testing it against _VirtualBox_ 4.3.6 and _Vagrant_ 1.4.1. The _Vagrantfile_ uses a minimal _Ubuntu Precise 64_ box and installs the _VirtualBox Guest Additions_ along with _Docker_ and its dependencies. The first time you execute a `vagrant up` it will go through an installation and build process, after its done you will have to execute a `vagrant reload`. After that you should be able to do a `vagrant ssh` and find that _Docker_ is available using a `which docker` command.

*Be aware* that the _Vagrantfile_ depends on the version of _VirtualBox_ and may run into problems if you don't have the latest versions.

Once your _Vagrant_ instance is up you should be able to ssh in (`vagrant ssh`) and have the `docker` command available. By default _Docker_ is also started as a service/daemon.

## Building the Docker Zabbix Repository.

Within an environment that is already running _docker_, checkout the *docker-zabbix* code to a known directory. If you are using the _Vagrantfile_, as mentioned above, it will be available by default in the `/docker/docker-zabbix` directory. From there you can execute a build and run the container.

e.g.

```
# CD into the docker container code.
cd /docker/docker-zabbix
# Build the contaienr code.
docker build -t berngp/docker-zabbix .
# Run it!
docker run -i -t -P --name=zabbix berngp/docker-zabbix
```

## Contributing.

Appreciate any contribution regardless of the size. If your contribution is associated with any reported [issue](https://github.com/berngp/docker-zabbix/issues) please add the details in the comments of the PR (Pull Request).

### Contributions from:

* [CosmicQ](https://github.com/CosmicQ)


Thank you and happy metrics gathering!
