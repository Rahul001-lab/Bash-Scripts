#!/bin/bash

PLAN_DIR="$HOME/daily_plans"
DATE=$(date +"%Y-%m-%d")
PLAN="$PLAN_DIR/$DATE.txt"

mkdir -p "$PLAN_DIR"

if [ ! -f "$PLAN" ]; then
echo "=================================" > "$PLAN"
echo "       DAILY PLAN - $DATE" >> "$PLAN"
echo "=================================" >> "$PLAN"
echo >> "$PLAN"

```
echo "Daily plan created for $DATE."
```

else
echo "Today's plan already exists."
fi

echo
echo "1. Add task"
echo "2. View today's tasks"
echo "3. Mark task as completed"
echo "4. Exit"
echo

read -p "Choose an option: " choice

case "$choice" in
1)
read -p "Enter task: " task

```
    if [ -z "$task" ]; then
        echo "Task cannot be empty."
        exit 1
    fi

    echo "[ ] $task" >> "$PLAN"
    echo "Task added."
    ;;

2)
    echo
    cat "$PLAN"
    ;;

3)
    read -p "Enter task text to mark complete: " task

    if grep -Fq "[ ] $task" "$PLAN"; then
        sed -i "s/\[ \] $task/[✓] $task/" "$PLAN"
        echo "Task completed."
    else
        echo "Task not found."
    fi
    ;;

4)
    echo "Goodbye."
    ;;

*)
    echo "Invalid option."
    ;;
```

esac
