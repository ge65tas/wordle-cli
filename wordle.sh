#!/bin/bash

# get solution from nyt
day="$(date --date 'today' +%Y-%m-%d)"
regex="solution\":\"([a-z]+)\""

solution_json="$(curl "https://www.nytimes.com/svc/wordle/v2/$day.json" 2> /dev/null)"

if [[ $solution_json =~ $regex ]]
then
    solution="${BASH_REMATCH[1]}"
else
    echo "could not get solution from nyt"
    exit 1
fi

# ensure solution is in accepted words
grep -wFq $solution wordle_words.txt
if [[ $? -ne 0 ]]; then
    echo $solution >> wordle_words.txt
fi


correct_color=$(tput setab 28)
present_color=$(tput setab 100)
absent_color=$(tput setab 242)
default_color=$(tput setab 0)


for ((j=1;j<7;j++)); do

    # get user input
    echo "Your guess number $j/6:"
    output1=()
    temp_input=()
    temp_solution=$solution
    status=1
    # only accept valid words
    until [ $status -eq 0 ]; do
        read guess
        grep -wFq $guess wordle_words.txt
        status=$?
    done

    #first pass: correct letters
    for ((i=0;i<5;i++)); do
        if [[ ${guess:$i:1} == ${solution:$i:1} ]]
        then
            output1+=("${correct_color}${guess:$i:1}")
            temp_solution=$(echo $temp_solution | sed "s/./#/$((i+1))")
        else
        output1+=("#")
        temp_input+=($i)
        fi
    done


    # second pass: present and absent letters
    for i in ${temp_input[@]}; do
        if [[ $temp_solution  == *${guess:$i:1}* ]]; then
            output1[i]="${present_color}${guess:$i:1}"
            temp_solution=${temp_solution/${guess:$i:1}/#}
        else
            output1[i]="${absent_color}${guess:$i:1}"
        fi
    done

    output=""
    for i in ${output1[@]}; do
        output+=$i
    done

    echo "$output$default_color"

    if [[ $temp_solution == "#####" ]]; then
        echo "Congratulations!"
        exit 0
    fi
done
