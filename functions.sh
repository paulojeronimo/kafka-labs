#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")"

export SCALA_VER='2.13'
export KAFKA_VER='2.7.0'
export KAFKA_DIR=kafka_$SCALA_VER-$KAFKA_VER
export KAFKA_TGZ=$KAFKA_DIR.tgz
export KAFKA_URL=https://downloads.apache.org/kafka/$KAFKA_VER/$KAFKA_TGZ
export KAFKA_TUT=$PWD

kafka-tut() {
	cd "$KAFKA_TUT"
}

kafka-dir() {
	kafka-tut
	! [ -d $KAFKA_DIR ] || cd $KAFKA_DIR
}

kafka-download() {(
	cd "$KAFKA_TUT"
	mkdir -p downloads && wget -c $KAFKA_URL -O downloads/$KAFKA_TGZ
)}

kafka-extract() {(
	cd "$KAFKA_TUT"
	rm -rf $KAFKA_DIR
	tar xvfz downloads/$KAFKA_TGZ
)}

zookeeper-server-start() {(
	cd "$KAFKA_TUT/$KAFKA_DIR"
	bin/zookeeper-server-start.sh config/zookeeper.properties
)}

kafka-server-start() {
	cd "$KAFKA_TUT/$KAFKA_DIR"
	bin/kafka-server-start.sh config/server.properties
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
kafka-dir
profile=~/.bash_profile
[[ $OSTYPE =~ ^linux ]] && profile=~/.bashrc
functions_sh=$KAFKA_TUT/functions.sh
if ! [ -f $profile ] || ! grep -q "^source \"$functions_sh\"$" $profile; then
  echo "source \"$functions_sh\"" >> $profile
  echo "'source \"$functions_sh\"' added to $profile"
fi
