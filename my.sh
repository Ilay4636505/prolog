#!/bin/bash

#Preparing the board.
board() {
    board[0]="rnbqkbnr"
    board[1]="pppppppp"
    board[2]="........"
    board[3]="........"
    board[4]="........"
    board[5]="........"
    board[6]="PPPPPPPP"
    board[7]="RNBQKBNR"
}
getBoardStats() {
    local pgn_file="$1"
    echo "Metadata from PGN file:"
    grep -E '^\[.*\]' "$pgn_file" | head -10
    echo
}
getMovesFromPgn() {
    local pgn_file="$1"
    moves=$(sed -E 's/\{.*\}//g' "$pgn_file" | \
            sed -E 's/\[.*\]//g' | \
            sed -E 's/\$[0-9]+//g' | \
            tr -d '\n' | \
            sed -E 's/^[[:space:]]*//' | \
            sed -E 's/[[:space:]]*$//' | \
            sed -E 's/[0-9]+\.\.\.//g' | \
            sed -E 's/[0-9]+\./ /g' | \
            sed -E 's/\*//g' | \
            sed -E 's/1-0//g' | \
            sed -E 's/0-1//g' | \
            sed -E 's/1\/2-1\/2//g' | \
            sed -E 's/[[:space:]]+/ /g')
    echo "$moves"
}

showBoard() {
    #Top.
    echo "  a b c d e f g h"
    for (( i=0; i<8; i++ )); 
    do
        echo -n "$((8-i)) "
        for (( j=0; j<8; j++ )); 
        do
            piece="${board[i]:j:1}"
            case "$piece" in
                .) echo -n ". " ;;
                *) echo -n "$piece " ;;
            esac
        done
        echo "$((8-i))"
    done
    echo "  a b c d e f g h"
}
main() {
    local pgn_file="$1"
    
    # Extract and display metadata
    getBoardStats "$pgn_file"
    
    # Extract moves from PGN
    moves_string=$(getMovesFromPgn "$pgn_file")
    board()
    showBoard()
}