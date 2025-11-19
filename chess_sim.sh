#!/bin/bash

# chess_sim.sh - Chess Simulator using PGN files

# Function to display usage
usage() {
    echo "Usage: $0 <pgn_file>"
    exit 1
}

# Function to initialize the chess board
init_board() {
    # Initial chess board position
    # 8: black pieces, 1: white pieces
    board[0]="rnbqkbnr"  # rank 8
    board[1]="pppppppp"  # rank 7  
    board[2]="........"  # rank 6
    board[3]="........"  # rank 5
    board[4]="........"  # rank 4
    board[5]="........"  # rank 3
    board[6]="PPPPPPPP"  # rank 2
    board[7]="RNBQKBNR"  # rank 1
}

# Function to display the chess board
display_board() {
    echo "  a b c d e f g h"
    for (( rank=0; rank<8; rank++ )); do
        echo -n "$((8-rank)) "
        for (( file=0; file<8; file++ )); do
            piece="${board[rank]:file:1}"
            case "$piece" in
                .) echo -n ". " ;;
                *) echo -n "$piece " ;;
            esac
        done
        echo "$((8-rank))"
    done
    echo "  a b c d e f g h"
}

# Function to convert file letter to index (0-7)
file_to_index() {
    case "$1" in
        a) echo 0 ;; b) echo 1 ;; c) echo 2 ;; d) echo 3 ;;
        e) echo 4 ;; f) echo 5 ;; g) echo 6 ;; h) echo 7 ;;
    esac
}

# Function to convert rank number to index (0-7)
rank_to_index() {
    echo $((8-$1))
}

# Function to apply a UCI move to the board
apply_move() {
    local move="$1"
    local from_file="${move:0:1}"
    local from_rank="${move:1:1}"
    local to_file="${move:2:1}"
    local to_rank="${move:3:1}"
    local promotion="${move:4:1}"
    
    local from_file_idx=$(file_to_index "$from_file")
    local from_rank_idx=$(rank_to_index "$from_rank")
    local to_file_idx=$(file_to_index "$to_file")
    local to_rank_idx=$(rank_to_index "$to_rank")
    
    # Get the moving piece
    local piece="${board[from_rank_idx]:from_file_idx:1}"
    
    # Handle pawn promotion
    if [[ -n "$promotion" ]]; then
        piece="$promotion"
    fi
    
    # Move the piece
    board[from_rank_idx]="${board[from_rank_idx]:0:from_file_idx}.${board[from_rank_idx]:$((from_file_idx+1))}"
    board[to_rank_idx]="${board[to_rank_idx]:0:to_file_idx}${piece}${board[to_rank_idx]:$((to_file_idx+1))}"
}

# Function to undo the last move
undo_move() {
    if [ ${#move_history[@]} -gt 0 ]; then
        # Restore previous board state
        for (( i=0; i<8; i++ )); do
            board[i]="${board_history[${#board_history[@]}-1]:i:8}"
        done
        
        # Remove from history
        unset 'board_history[${#board_history[@]}-1]'
        unset 'move_history[${#move_history[@]}-1]'
    fi
}

# Function to save current board state
save_board_state() {
    for (( i=0; i<8; i++ )); do
        board_history[${#board_history[@]}]="${board[i]}"
    done
}

# Function to extract metadata from PGN file
extract_metadata() {
    local pgn_file="$1"
    echo "Metadata from PGN file:"
    grep -E '^\[.*\]' "$pgn_file" | head -10
    echo
}

# Function to extract moves from PGN file
extract_moves() {
    local pgn_file="$1"
    # Remove metadata and comments, then extract move sequence
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

# Main script execution
main() {
    # Check if file exists
    if [ $# -ne 1 ]; then
        usage
    fi
    
    if [ ! -f "$1" ]; then
        echo "File does not exist: $1"
        exit 1
    fi
    
    local pgn_file="$1"
    
    # Extract and display metadata
    extract_metadata "$pgn_file"
    
    # Extract moves from PGN
    moves_string=$(extract_moves "$pgn_file")
    
    # Convert PGN moves to UCI using Python script
    if ! command -v python3 &> /dev/null; then
        echo "Error: python3 is required but not installed"
        exit 1
    fi
    
    # Check if parse_moves.py exists
    if [ ! -f "parse_moves.py" ]; then
        echo "Error: parse_moves.py not found in current directory"
        exit 1
    fi
    
    # Convert moves to UCI format
    uci_moves=$(python3 parse_moves.py "$moves_string")
    
    # Parse UCI moves into array
    eval "moves_history=($uci_moves)"
    
    # Initialize board and history
    init_board
    declare -a board_history
    declare -a move_history
    current_move=0
    
    # Main interaction loop
    while true; do
        echo "Move $current_move/${#moves_history[@]}"
        display_board
        
        read -n1 -p "Press 'd' to move forward, 'a' to move back, 'w' to go to the start, 's' to go to the end, 'q' to quit: " key
        echo
        
        case "$key" in
            d)
                # Move forward
                if [ $current_move -lt ${#moves_history[@]} ]; then
                    save_board_state
                    move_history[${#move_history[@]}]="${moves_history[current_move]}"
                    apply_move "${moves_history[current_move]}"
                    ((current_move++))
                else
                    echo "No more moves available."
                fi
                ;;
            a)
                # Move back
                if [ $current_move -gt 0 ]; then
                    undo_move
                    ((current_move--))
                fi
                ;;
            w)
                # Go to start
                while [ $current_move -gt 0 ]; do
                    undo_move
                    ((current_move--))
                done
                ;;
            s)
                # Go to end
                while [ $current_move -lt ${#moves_history[@]} ]; do
                    save_board_state
                    move_history[${#move_history[@]}]="${moves_history[current_move]}"
                    apply_move "${moves_history[current_move]}"
                    ((current_move++))
                done
                ;;
            q)
                echo "Exiting."
                break
                ;;
            *)
                echo "Invalid key pressed: $key"
                ;;
        esac
        echo
    done
    
    echo "End of game."
}

# Run main function with all arguments
main "$@"