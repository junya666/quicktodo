
SELFDIR=$(cd $(dirname $0); pwd)
TODO_FILE="$SELFDIR/.todo_list"
if [ ! -f $TODO_FILE ]; then
  touch $TODO_FILE
fi


Usage() {
  case $1 in
    add) echo add_usage: ... ;;
    _done) echo done_usage: ... ;;
    *)
      echo "usage: todo [ add | list | done | remove | change ] ..." ;;
  esac
  exit 0
}


# todo の追加
# -l ... ラベルの設定
Add() {
  if [ $# -eq 0 ]; then
    Usage add
  fi
  args=($@)
  label="none"
  todo="-"
  created_at=`date '+%y/%m/%d(%a)'`
  done_at="-"

  # idの設定
  tail=`tail -1 $TODO_FILE`
  if [ "$tail" = "" ]; then
    id=1
  else
    id=`echo $tail | awk -F, '{print $1+1}'`
  fi

  # labelオプションの確認
  for i in `seq 0 1`; do
    if [ "${args[$i]}" = "-l" ]; then
      unset args[$i]
      i=$(($i+1))
      label=${args[$i]}
      unset args[$i]
      break
    fi
  done

  # todo取り出し
  args=("${args[@]}")
  todo=${args[0]}

  if [ "$todo" = "" -o "$label" = "" ]; then
    Usage add
  fi

  #TODO ファイル先頭に追加できるといいけどsedが環境依存でめんどい
  echo $id,$label,$todo,$created_at,$done_at >> $TODO_FILE

<< COMMENT
  (
    echo Label,TODO,Created_at,Done_at
    echo $label,$todo,$created_at,$done_at
  ) | column -t -s ,
COMMENT
}


# リスト表示．
# -l ... ラベル指定
# -d ... Doneのリスト表示
# -a ... Doneも含めた全リスト表示
List() {
  #TODO -a|-dがなければDone_atカラムは表示しない
  (
    echo ID,Label,TODO,Created_at
    while read line; do
      echo $line | awk -F, -v OFS="," '{if($5=="-")print $1,$2,$3,$4}'
    done < $TODO_FILE
  ) | column -t -s ,
}


# 指定したtodoをDoneに変更
Done() {
  # 引数が整数か判定
  expr $1 + 1 > /dev/null 2>&1
  RET=$?
  if [ $RET -ge 2 ]; then
    Usage _done
  else
    del_id=$1
  fi

  line_num=1
  done_at=`date '+%y/%m/%d(%a)'`
  (
  while read line; do
    new_line=`echo $line |
      awk -F, -v i="$del_id" -v d="$done_at" -v OFS="," \
      '{ if($1 == i){ $5 = d; print $0} else print $0 }' `
    echo $new_line
    line_num=$(($line_num+1))
  done < $TODO_FILE
  ) > "${TODO_FILE}x"
  mv "${TODO_FILE}x" $TODO_FILE
}


# 指定したtodoを削除
Remove() {
  echo remove
}


# todoの変更
# -c ... 内容の変更
# -l ... ラベルの変更
Change() {
  echo change
}


case $1 in
  add|a) Add ${@:2:3};;
  list|l) List ${@:2};;
  "done"|d) Done ${@:2:1};;
  remove|r) Remove ${@:2:1};;
  change|c) Change ${@:2};;
  *) Usage
esac
  
