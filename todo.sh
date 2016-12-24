
SELFDIR=$(cd $(dirname $0); pwd)
TODO_FILE="$SELFDIR/.todo_list"
DONE_FILE="$SELFDIR/.done_list"
if [ ! -f $TODO_FILE ]; then
  touch $TODO_FILE
fi
if [ ! -f $DONE_FILE ]; then
  touch $DONE_FILE
fi


usage() {
  echo "usage: todo [ add | list | done | remove | change ] ..."
}

add() {
  echo add
  echo $@
}

list() {
  (
    while read line; do
      echo $line
    done < $TODO_FILE
  ) | column -t
}

_done() {
  echo done
}

remove() {
  echo remove
}

change() {
  echo change
}


case $1 in
  add|a) add ${@:2:3};;
  list|l) list ${@:2};;
  "done"|d) _done ${@:2:1};;
  remove|r) remove ${@:2:1};;
  change|c) change ${@:2};;
  *) usage
esac
  
