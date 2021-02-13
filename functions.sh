#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")"
export KAFKA_SCALA_VER='2.13'
export KAFKA_VER='2.7.0'
export KAFKA_DIR=kafka_$KAFKA_SCALA_VER-$KAFKA_VER
export KAFKA_TGZ=$KAFKA_DIR.tgz
export KAFKA_URL=https://downloads.apache.org/kafka/$KAFKA_VER/$KAFKA_TGZ
export KAFKA_LABS=$PWD
cd "$OLDPWD"

kafka-labs() {
	cd "$KAFKA_LABS"
}

kafka-dir() {
	kafka-labs && cd $KAFKA_DIR
}

kafka-download() {(
	cd "$KAFKA_LABS"
	mkdir -p downloads && wget -c $KAFKA_URL -O downloads/$KAFKA_TGZ
)}

kafka-extract() {(
	cd "$KAFKA_LABS"
	rm -rf $KAFKA_DIR
	tar xvfz downloads/$KAFKA_TGZ
)}


start-servers() {(
	local lab=$1
	kafka-dir
	echo "Starting ZooKeeper ..."
	tmux -2 new -d -s $lab -n 'Servers' \
		'bin/zookeeper-server-start.sh config/zookeeper.properties'
	sleep 2
	echo "Starting Kafka ..."
	tmux splitw -v \
		'bin/kafka-server-start.sh config/server.properties'
)}

start-consumer-producer() {(
	local lab=$1
	kafka-dir
	echo "Creating topic (quickstart-events) ..."
	bin/kafka-topics.sh --create --topic quickstart-events --bootstrap-server localhost:9092
	echo "Starting Consumer and Producer (you will be redirected to their window) ..."
	tmux neww -t $lab:1 -n 'Consumer/Producer' \
		'bin/kafka-console-consumer.sh --topic quickstart-events --bootstrap-server localhost:9092'
	tmux splitw -v \
		'bin/kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9092'
)}

lab1-dir() {
	kafka-dir
}

lab1-setup() {
	kafka-labs && kafka-download && kafka-extract
}

lab1-start() {(
	start-servers lab1
	sleep 3
	start-consumer-producer lab1
	sleep 1
	tmux attach
)}

lab1-cleanup() {
	rm -rf /tmp/kafka-logs /tmp/zookeeper
}

lab2-dir() {
	kafka-labs
	cd final/lab2
}

lab3-dir() {
	kafka-labs
	cd $KAFKA_DIR
}

lab4-dir() {
	kafka-labs
	cd final/lab4
}

which wget &> /dev/null || {
	echo "Install wget!"
	return 1
}
case "$OSTYPE" in
  darwin*)
    which gsed &> /dev/null || {
      echo -e "Install gsed!\n$ brew install gnu-sed"
      return 1
    }
    sed() { gsed "$@"; }
    which ggrep &> /dev/null || {
      echo -e "Install ggrep!\n$ brew install grep"
      return 1
    }
    function grep { ggrep "$@"; }
esac
type jdk &> /dev/null && jdk 1.8
profile=~/.bash_profile
[[ $OSTYPE =~ ^linux ]] && profile=~/.bashrc
functions_sh=$KAFKA_LABS/functions.sh
if ! [ -f $profile ] || ! grep -q "^source \"$functions_sh\"$" $profile; then
  echo "source \"$functions_sh\"" >> $profile
  echo "'source \"$functions_sh\"' added to $profile"
fi
