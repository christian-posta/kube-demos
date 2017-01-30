#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

### Zookeeper
desc "let's start up zookeeper"
run "docker run -itd --name zookeeper -p 2181:2181 -p 2888:2888 -p 3888:3888 debezium/zookeeper:0.3"

desc "let's make sure ZK started up correctly"
run "docker logs zookeeper" 

backtotop

### Kafka
desc "now let's run kafka"
run "docker run -itd --name kafka -p 9092:9092 --link zookeeper:zookeeper debezium/kafka:0.3"

desc "let's make sure Kafka came up correctly"
run "docker logs kafka"

backtotop

### MySQL
desc "Now, let's create a database"
run "docker run -itd --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=debezium -e MYSQL_USER=mysqluser -e MYSQL_PASSWORD=mysqlpw debezium/example-mysql:0.3" 

desc "Check the mysql logs"
docker logs -f mysql &
TASK_PID=$!
sleep 15s
kill $TASK_PID

backtotop

### MySQL Client
desc "Now let's create a client to the database"
read -s

tmux split-window -v
tmux select-layout even-vertical
tmux select-pane -t 0

tmux send-keys -t 1 "docker run -it --rm --name mysqlterm --link mysql --rm mysql:5.7 sh -c 'exec mysql -h\"\$MYSQL_PORT_3306_TCP_ADDR\" -P\"\$MYSQL_PORT_3306_TCP_PORT\" -uroot -p\"\$MYSQL_ENV_MYSQL_ROOT_PASSWORD\"'" C-m

read -s

desc "lets use the inventory database and check it out a bit"
tmux send-keys -t 1 C-l
tmux send-keys -t 1 "use inventory\;"
read -s

tmux send-keys -t 1 C-m
read -s

desc "list the tables we have in this DB"
tmux send-keys -t 1 C-l
tmux send-keys -t 1 "show tables\;" 
read -s
tmux send-keys -t 1 C-m
read -s

desc "whats in the customer table"
tmux send-keys -t 1 C-l
tmux send-keys -t 1 "SELECT * FROM customers\;"
read -s
tmux send-keys -t 1 C-m
read -s

### Kafka Connect
desc "Start up Kafka Connect"
read -s
tmux split-window -v
tmux select-layout even-vertical
tmux select-pane -t 0

# the kafka connect pane becomes #1 and mysql becomes #2

tmux send-keys -t 1 "docker run -itd --name connect -p 8083:8083 -e GROUP_ID=1 -e CONFIG_STORAGE_TOPIC=my_connect_configs -e OFFSET_STORAGE_TOPIC=my_connect_offsets --link zookeeper:zookeeper --link kafka:kafka --link mysql:mysql debezium/connect:0.3" C-m

tmux send-keys -t 1 "docker logs -f connect" C-m
# note: this will port forward to the minishift machine, but we need the port available locally
# so let's do an SSH port forward. We have to make sure to clean this up when we're done. We'll
# also add this to the cleanup.sh script
command minishift ssh -- -vnNTL *:8083:$(minishift ip):8083 > /dev/null  2>&1 &


read -s

desc "Lets see what connectors we have"
run "curl -H \"Accept:application/json\" localhost:8083/connectors/"

desc "let's see what a connector definition looks like:"
run "cat $(relative inventory-connector.json) | pretty-json"

backtotop

CONNECTOR_FILE=$(relative inventory-connector.json)

desc "Now let's add a connector that monitors our inventory database"
run "curl -i -X POST -H \"Accept:application/json\" -H \"Content-Type:application/json\" localhost:8083/connectors/ -d @$CONNECTOR_FILE"

backtotop

desc "Now we should see our inventory connector"
run "curl -H \"Accept:application/json\" localhost:8083/connectors/"

desc "Lets see the connector itself"
run "curl -H \"Accept:application/json\" localhost:8083/connectors/inventory-connector | pretty-json"

desc "We're going to leave Kafka Connect with the Debezium connector running, but navigate away from its logs for a second."
read -s
tmux send-keys -t 1 C-c

desc "We still have the docker container for Kafka Connect running"
run "docker ps"


backtotop
desc "Let's subscribe to a kafka topic that should have the customers table data"
tmux send-keys -t 1 C-l
read -s

# now the kafka subscription becomes pane #1, the KC window is #2 and mysql is #3
tmux send-keys -t 1 "docker run -it --name watcher --rm --link zookeeper:zookeeper debezium/kafka:0.3 watch-topic -a -k dbserver1.inventory.customers" C-m

read -s

desc "Now let's pretend we're an application making changes to the database"
read -s
tmux send-keys -t 2 C-l
tmux send-keys -t 2 "SELECT * FROM customers\;" 
read -s
tmux send-keys -t 2  C-m
read -s

tmux send-keys -t 2 "UPDATE customers SET first_name='Anne Marie' WHERE id=1004\;"
read -s
tmux send-keys -t 2  C-m
read -s

tmux send-keys -t 2 C-l
tmux send-keys -t 2 "SELECT * FROM customers\;"
read -s 
tmux send-keys -t 2  C-m
read -s

desc "lets try a delete"
tmux send-keys -t 2 C-l
tmux send-keys -t 2 "DELETE FROM customers WHERE id=1004\;"
read -s
tmux send-keys -t 2 C-m
read -s

desc "Let's try to stop the Connect process and watch that it restarts from where it left off"
run "docker stop connect"


desc "Now let's add some more data to mysql"
tmux send-keys -t 2 C-l
read -s
tmux send-keys -t 2 "INSERT INTO customers VALUES (default, \"Sarah\", \"Thompson\", \"kitt@acme.com\")\;"
read -s
tmux send-keys -t 2  C-m

read -s
tmux send-keys -t 2 "INSERT INTO customers VALUES (default, \"Kenneth\", \"Anderson\", \"kander@acme.com\")\;"
read -s
tmux send-keys -t 2  C-m

read -s

desc "Now let's restart the kafka connect process which hosts our debezium connector"
run "docker start connect"


