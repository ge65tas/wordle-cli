curl https://www.nytimes.com/games-assets/v2/8044.da4a6f0a9810390740e9.js | grep -oE "\"[a-z]{5}\"" | sed "s/\"//g" | sort | uniq > "wordle_words.txt"
