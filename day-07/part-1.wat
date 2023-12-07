(module
    (export "main" (func $main))
    (export "memory" (memory $mem))
    (import "aoc" "input_len" (func $aoc.input_len (result i32)))
    (import "aoc" "input" (func $aoc.input (param i32) (result i32)))
    (import "dbg" "panic" (func $dbg.panic (param i32)))
    (import "dbg" "mem" (func $dbg.mem (param i32) (param i32)))
    (import "dbg" "mem:10:line" (func $dbg.line (param i32) (result i32)))
    (import "dbg" "mem:8:card" (func $dbg.card (param i32) (result i32)))
    (import "dbg" "mem:5:justcard" (func $dbg.justcard (param i32) (result i32)))
    (import "dbg" "mem:16:vecheader" (func $dbg.vecheader (param i32) (result i32)))
    (import "dbg" "inspect:x_in_a_row" (func $dbg.x_in_a_row (param i32 i32 i32) (result i32 i32 i32)))
    (import "dbg" "inspect:is_five_of_a_kind" (func $dbg.is_five_of_a_kind (param i32) (result i32)))
    (import "dbg" "inspect:is_four_of_a_kind" (func $dbg.is_four_of_a_kind (param i32) (result i32)))
    (import "dbg" "inspect:is_full_house" (func $dbg.is_full_house (param i32) (result i32)))
    (import "dbg" "inspect:is_three_of_a_kind" (func $dbg.is_three_of_a_kind (param i32) (result i32)))
    (import "dbg" "inspect:is_two_pair" (func $dbg.is_two_pair (param i32) (result i32)))
    (import "dbg" "inspect:is_one_pair" (func $dbg.is_one_pair (param i32) (result i32)))

    (import "dbg" "inspect:x_in_a_row.start" (func $dbg.x_in_a_row.start (param i32 i32) (result i32 i32)))
    (import "dbg" "inspect:    x_in_a_row.first" (func $dbg.x_in_a_row.first (param i32) (result i32)))
    (import "dbg" "inspect:    x_in_a_row.next_item" (func $dbg.x_in_a_row.next_item (param i32) (result i32)))
    (import "dbg" "inspect:    x_in_a_row.is_eq" (func $dbg.x_in_a_row.is_eq (param i32) (result i32)))
    (import "dbg" "inspect:    x_in_a_row.new_result" (func $dbg.x_in_a_row.new_result (param i32) (result i32)))
    (import "dbg" "mem:10:swap_ptr" (func $dbg.swap_ptr (param i32) (result i32)))
    (import "dbg" "inspect:vec_capacity" (func $dbg.vec_capacity (param i32 i32) (result i32 i32)))
    (import "dbg" "inspect:score" (func $dbg.score (param i32 i32 i32) (result i32 i32 i32)))

    ;; Create memory with at least 1 page of 64k of memory    
    (memory $mem 5)

    ;; Initialize the first several bytes of the memory with some text
    ;; (data (i32.const 0) "xx23456789TJQKA")
    (; byte offset       0123456789012345 ;)
    (;                             1      ;)

    ;; our main function!
    (func $main (result i32)
        (local $input_len i32)
        (local $input_ptr i32)
        (local $lines i32)

        (local.set $input_len
            (call $aoc.input_len))
        (local.set $input_ptr
            (call $alloc
                (local.get $input_len)))
        (drop
            (call $aoc.input
                (local.get $input_ptr)))
        (local.set $lines
            (call $parse_input
                (local.get $input_ptr)
                (local.get $input_len)))

        ;; (call $dbg.lines
        ;;     (local.get $lines))

        (call $lines.sort
            (local.get $lines))

        ;; (call $dbg.lines
        ;;     (local.get $lines))
        
        (call $get_score_from_sorted_lines
            (local.get $lines))
    )

    (func $get_score_from_sorted_lines (param $vec i32) (result i32)
        (local $sum i32)
        (local $counter i32)
        (local $idx i32)
        (local $bid i32)
        (local $veclen i32)
        (local $line i32)

        (local.set $veclen
            (call $vec.len
                (local.get $vec)))

        (block $break
            (loop $continue
                (br_if $break
                    (i32.ge_u
                        (local.get $counter)
                        (local.get $veclen)))

                (local.set $idx
                    (i32.add
                        (local.get $counter)
                        (i32.const 1)))

                (local.set $line
                    (call $vec.get
                        (local.get $vec)
                        (local.get $counter)))

                (local.set $bid
                    (call $line.bid
                        (local.get $line)))

                (local.set $sum
                    (i32.add
                        (local.get $sum)
                        (i32.mul
                            (local.get $idx)
                            (local.get $bid))))
                
                ;; (drop
                ;;     (call $dbg.line
                ;;         (local.get $line)))
                ;; (drop (drop (drop
                ;;     (call $dbg.score
                ;;         (local.get $idx)
                ;;         (local.get $bid)
                ;;         (local.get $sum))
                ;; )))

                (local.set $counter
                    (i32.add
                        (local.get $counter)
                        (i32.const 1)))
                br $continue
            )
        )
    
        local.get $sum
    )

    (func $dbg.cards
        (param $vec i32)
        
        (local $counter i32)
        (local $veclen i32)
        (local.set $veclen
            (call $vec.len
                (local.get $vec)))

        (block $break
            (loop $continue
                (br_if $break
                    (i32.ge_u
                        (local.get $counter)
                        (local.get $veclen)))

                (drop
                    (call $dbg.justcard
                        (call $vec.get
                            (local.get $vec)
                            (local.get $counter))))
                
                (local.set $counter
                    (i32.add
                        (local.get $counter)
                        (i32.const 1)))

                br $continue
            )
        )
    )

    (func $dbg.lines
        (param $vec i32)
        
        (local $counter i32)
        (local $veclen i32)
        (local.set $veclen
            (call $vec.len
                (local.get $vec)))

        (block $break
            (loop $continue
                (br_if $break
                    (i32.ge_u
                        (local.get $counter)
                        (local.get $veclen)))

                (drop
                    (call $dbg.line
                        (call $vec.get
                            (local.get $vec)
                            (local.get $counter))))
                
                (local.set $counter
                    (i32.add
                        (local.get $counter)
                        (i32.const 1)))

                br $continue
            )
        )
    )

    (func $parse_input
        (param $input_ptr i32)
        (param $input_len i32)
        (result (; vec ;) i32)

        (local $vec i32)
        (local $curptr i32)
        (local $endptr i32)
        (local $card_dest_ptr i32)
        (local.set $curptr (local.get $input_ptr))
        (local.set $endptr (i32.add (local.get $input_ptr) (local.get $input_len)))

        (local.set $vec
            (call $vec.new
                (i32.const 10) ;; each element is 10 bytes
            )
        )

        (loop $loop
            (local.set $card_dest_ptr
                (call $vec.push
                    (local.get $vec)))

            (call $parse_line
                (local.get $curptr)
                (local.get $card_dest_ptr))

            local.get $curptr
            i32.add
            local.set $curptr

            local.get $curptr
            local.get $endptr
            i32.lt_u
            br_if $loop
        )

        local.get $vec
    )

    ;; struct Line {
    ;;   cards: [u8; 5], // starting index 0
    ;;   _padding: [u8; 2], // starting index 5
    ;;   type: u8, // starting index 7
    ;;   bid: u16, // starting index 8
    ;; }
    ;; note that bytes 0-7 can be read as a le i64 that is sortable.
    ;; total: 10 bytes
    (func $parse_line
        (param $offset i32)
        (param $ptr i32)
        (result (; parsed ;) i32)

        ;; (local $ptr i32)
        (local $num_len i32)
        (local $card0 i32)
        (local $card1 i32)
        (local $card2 i32)
        (local $card3 i32)
        (local $card4 i32)

        ;; i32.const 10
        ;; call $alloc
        ;; local.set $ptr

        ;; parse card 0
        (local.set $card0
            (call $parse_card
                (local.get $offset)))
        (i32.store8
            (local.get $ptr)
            (local.get $card0))

        ;; parse card 1
        (local.set $card1
            (call $parse_card
                (i32.add (local.get $offset) (i32.const 1))))
        (i32.store8
            (i32.add (local.get $ptr) (i32.const 1))
            (local.get $card1))

        ;; parse card 2
        (local.set $card2
            (call $parse_card
                (i32.add (local.get $offset) (i32.const 2))))
        (i32.store8
            (i32.add (local.get $ptr) (i32.const 2))
            (local.get $card2))

        ;; parse card 3
        (local.set $card3
            (call $parse_card
                (i32.add (local.get $offset) (i32.const 3))))
        (i32.store8
            (i32.add (local.get $ptr) (i32.const 3))
            (local.get $card3))

        ;; parse card 4
        (local.set $card4
            (call $parse_card
                (i32.add (local.get $offset) (i32.const 4))))
        (i32.store8
            (i32.add (local.get $ptr) (i32.const 4))
            (local.get $card4))
        
        (i32.add (local.get $ptr) (i32.const 8))
        (i32.add (local.get $offset) (i32.const 6)) ;; skip the space
        call $i32.parse_from_memory
        local.set $num_len
        i32.store16
        
        (call $sort_hand
            (local.get $ptr))

        (i32.store8
            (i32.add (local.get $ptr) (i32.const 7))
            (call $classify_hand
                (local.get $ptr)))

        ;; To *classify* the hand, it needed to be sorted. But when ordering the
        ;; hands apparently the original order of the cards is important. So, to
        ;; make the first card matter the most, we put it in slot 4 so that it's
        ;; most important when loading the cards as a LE i64, etc.
        (i32.store8
            (i32.add (local.get $ptr) (i32.const 4))
            (local.get $card0))
        (i32.store8
            (i32.add (local.get $ptr) (i32.const 3))
            (local.get $card1))
        (i32.store8
            (i32.add (local.get $ptr) (i32.const 2))
            (local.get $card2))
        (i32.store8
            (i32.add (local.get $ptr) (i32.const 1))
            (local.get $card3))
        (i32.store8
            (i32.add (local.get $ptr) (i32.const 0))
            (local.get $card4))


        (i32.add (i32.const 7 (; 5 bytes for cards, 1 byte for space, 1 byte for newline ;)) (local.get $num_len))
    )

    (func $line.bid (param $ptr i32) (result i32)
        (i32.load16_u
            (i32.add
                (local.get $ptr
                (i32.const 8))))
    )

    ;; Gonna assume that this always succeeds. We have well-known input.
    (func $parse_card
        (param $offset i32)
        (result (; card value, 2-13 ;) i32)

        (local $byte i32)
        (local $value i32)
        
        local.get $offset
        i32.load8_u
        local.set $byte

        (block $ret
            (local.set $value (i32.const 14))
            local.get $byte
            i32.const 0x41 ;; "A"
            i32.eq
            br_if $ret

            (local.set $value (i32.const 13))
            local.get $byte
            i32.const 0x4b ;; "K"
            i32.eq
            br_if $ret

            (local.set $value (i32.const 12))
            local.get $byte
            i32.const 0x51 ;; "Q"
            i32.eq
            br_if $ret

            (local.set $value (i32.const 11))
            local.get $byte
            i32.const 0x4a ;; "J"
            i32.eq
            br_if $ret

            (local.set $value (i32.const 10))
            local.get $byte
            i32.const 0x54 ;; "T"
            i32.eq
            br_if $ret

            local.get $byte
            i32.const 0x30 ;; "0"
            i32.sub
            local.set $value
        )

        local.get $value
    )

    ;; a custom implementation of bubble sort that works on exactly 5 u8s.
    (func $sort_hand (param $ptr i32)
        (local $hold i32)

        (call $bubble_sort_u8_helper (local.get $ptr))
        (call $bubble_sort_u8_helper (i32.add (local.get $ptr) (i32.const 1)))
        (call $bubble_sort_u8_helper (i32.add (local.get $ptr) (i32.const 2)))
        (call $bubble_sort_u8_helper (i32.add (local.get $ptr) (i32.const 3)))

        (call $bubble_sort_u8_helper (local.get $ptr))
        (call $bubble_sort_u8_helper (i32.add (local.get $ptr) (i32.const 1)))
        (call $bubble_sort_u8_helper (i32.add (local.get $ptr) (i32.const 2)))

        (call $bubble_sort_u8_helper (local.get $ptr))
        (call $bubble_sort_u8_helper (i32.add (local.get $ptr) (i32.const 1)))

        (call $bubble_sort_u8_helper (local.get $ptr))
    )

    ;; read the two i8s at $ptr and $ptr+1. Swap them if the first is greater than the second
    (func $bubble_sort_u8_helper (param $ptr i32)
        (local $val1 i32)
        (local $val2 i32)

        (i32.load8_u (local.get $ptr))
        local.tee $val1
        (i32.load8_u (i32.add (local.get $ptr) (i32.const 1)))
        local.tee $val2

        (if (i32.gt_u)
            (then
                local.get $ptr
                local.get $val2
                i32.store8

                (i32.add (local.get $ptr) (i32.const 1))
                local.get $val1
                i32.store8
            )
        )
    )

    (func $classify_hand (param $ptr i32) (result i32)
        ;; 6: Five of a kind, where all five cards have the same label: AAAAA
        ;; 5: Four of a kind, where four cards have the same label and one card has a different label: AA8AA
        ;; 4: Full house, where three cards have the same label, and the remaining two cards share a different label: 23332
        ;; 3: Three of a kind, where three cards have the same label, and the remaining two cards are each different from any other card in the hand: TTT98
        ;; 2: Two pair, where two cards share one label, two other cards share a second label, and the remaining card has a third label: 23432
        ;; 1: One pair, where two cards share one label, and the other three cards have a different label from the pair and each other: A23A4
        ;; 0: High card, where all cards' labels are distinct: 23456

        (local $result i32)

        (block $block
            (local.set $result (i32.const 6))
            (call $is_five_of_a_kind (local.get $ptr))
            br_if $block

            (local.set $result (i32.const 5))
            (call $is_four_of_a_kind (local.get $ptr))
            br_if $block

            (local.set $result (i32.const 4))
            (call $is_full_house (local.get $ptr))
            br_if $block

            (local.set $result (i32.const 3))
            (call $is_three_of_a_kind (local.get $ptr))
            br_if $block

            (local.set $result (i32.const 2))
            (call $is_two_pair (local.get $ptr))
            br_if $block

            (local.set $result (i32.const 1))
            (call $is_one_pair (local.get $ptr))
            br_if $block

            (local.set $result (i32.const 0))
        )

        local.get $result
    )

    (func $is_five_of_a_kind (param $ptr i32) (result i32)
        (call $x_in_a_row (i32.const 5) (local.get $ptr))
        ;; call $dbg.is_five_of_a_kind
    )

    (func $is_four_of_a_kind (param $ptr i32) (result i32)
        (call $x_in_a_row (i32.const 4) (local.get $ptr) )
        (call $x_in_a_row (i32.const 4) (i32.add (local.get $ptr) (i32.const 1)))
        i32.or
        ;; call $dbg.is_four_of_a_kind
    )

    (func $is_full_house (param $ptr i32) (result i32)
        (call $x_in_a_row (i32.const 3) (local.get $ptr))
        (call $x_in_a_row (i32.const 2) (i32.add (local.get $ptr) (i32.const 3)))
        i32.and

        (call $x_in_a_row (i32.const 2) (local.get $ptr))
        (call $x_in_a_row (i32.const 3) (i32.add (local.get $ptr) (i32.const 2)))
        i32.and

        i32.or
        ;; call $dbg.is_full_house
    )

    (func $is_three_of_a_kind (param $ptr i32) (result i32)
        (call $x_in_a_row (i32.const 3) (local.get $ptr) )
        (call $x_in_a_row (i32.const 3) (i32.add (local.get $ptr) (i32.const 1)))
        (call $x_in_a_row (i32.const 3) (i32.add (local.get $ptr) (i32.const 2)))
        i32.or
        i32.or
        ;; call $dbg.is_three_of_a_kind
    )

    (func $is_two_pair (param $ptr i32) (result i32)
        (call $x_in_a_row (i32.const 2) (local.get $ptr) )
        (call $x_in_a_row (i32.const 2) (i32.add (local.get $ptr) (i32.const 2)))
        i32.and

        (call $x_in_a_row (i32.const 2) (local.get $ptr) )
        (call $x_in_a_row (i32.const 2) (i32.add (local.get $ptr) (i32.const 3)))
        i32.and

        (call $x_in_a_row (i32.const 2) (i32.add (local.get $ptr) (i32.const 1)))
        (call $x_in_a_row (i32.const 2) (i32.add (local.get $ptr) (i32.const 3)))
        i32.and

        i32.or
        i32.or
        ;; call $dbg.is_two_pair
    )

    (func $is_one_pair (param $ptr i32) (result i32)
        (call $x_in_a_row (i32.const 2) (local.get $ptr))
        (call $x_in_a_row (i32.const 2) (i32.add (local.get $ptr) (i32.const 1)))
        (call $x_in_a_row (i32.const 2) (i32.add (local.get $ptr) (i32.const 2)))
        (call $x_in_a_row (i32.const 2) (i32.add (local.get $ptr) (i32.const 3)))
        
        i32.or
        i32.or
        i32.or
        ;; call $dbg.is_one_pair
    )

    (func $x_in_a_row (param $count i32) (param $ptr i32) (result i32)
        (local $first i32)
        (local $ctr i32)
        (local $result i32)
        (local.set $first (i32.load8_u (local.get $ptr)))
        (local.set $result (i32.const 1))
        (local.set $ctr (i32.const 1))

        (loop
            ;; get the next item [] -> [i8]
            local.get $ptr
            local.get $ctr
            i32.add
            i32.load8_u

            ;; see if it's the same as the first item [i8] -> [i8]
            local.get $first
            i32.eq
            
            ;; and it with the result [i8] -> [i8]
            local.get $result
            i32.and

            ;; and store the result [i8] -> []
            local.set $result

            (local.tee $ctr (i32.add (local.get $ctr) (i32.const 1)))
            local.get $count
            i32.lt_u
            br_if 0
        )

        local.get $result
    )

    (func $line.gt (param $ptr1 i32) (param $ptr2 i32) (result i32)
        (i64.load (local.get $ptr1))
        (i64.load (local.get $ptr2))
        i64.gt_u
    )

    (func $line.swap (param $ptr1 i32) (param $ptr2 i32) (param $scratchptr i32)
        (memory.copy
            (local.get $scratchptr)
            (local.get $ptr1)
            (i32.const 10))

        (memory.copy
            (local.get $ptr1)
            (local.get $ptr2)
            (i32.const 10))

        (memory.copy
            (local.get $ptr2)
            (local.get $scratchptr)
            (i32.const 10))
    )

    (func $lines.sort
        (param $vec i32)

        (call $lines.sortbuf
            (call $vec.buffer_ptr
                (local.get $vec))
            (call $vec.len
                (local.get $vec)))
    )

    (func $lines.sortbuf
        (param $bufptr i32)
        (param $item_count i32)

        (local $swap_ptr i32) ;; When we swap two lines, we need some extra memory to do that.
        (local $cur_count i32)
        
        ;; swap memory the size of a single line
        (local.set $swap_ptr
            (call $alloc
                (i32.const 10)))

        (local.set $cur_count
            (local.get $item_count))

        (block $block
            (loop $loop
                ;; if our count is down to 1, stop sorting.
                (br_if $block
                    (i32.le_u
                        (local.get $cur_count)
                        (i32.const 1)))

                (call $lines.sortbuf_once
                    (local.get $bufptr)
                    (local.get $cur_count)
                    (local.get $swap_ptr))

                (local.set $cur_count
                    (i32.sub
                        (local.get $cur_count)
                        (i32.const 1)))

                br $loop
            )
        )
    )

    (func $lines.sortbuf_once
        (param $bufptr i32)
        (param $item_count i32)
        (param $swap_ptr i32)

        (local $curptr i32)
        (local $nextptr i32)
        (local $endptr i32)

        (local.set $curptr
            (local.get $bufptr))
        (local.set $nextptr
            (i32.add
                (local.get $bufptr)
                (i32.const 10)))
        (local.set $endptr
            (i32.add
                (local.get $bufptr)
                (i32.mul
                    (i32.const 10) ;; bytes in a line
                    (local.get $item_count)
                )
            )
        )

        (loop $loop
            (call $line.gt
                (local.get $curptr)
                (local.get $nextptr))
            
            (if (; the current item is greater than the next item ;)
                (then
                    (call $line.swap
                        (local.get $curptr)
                        (local.get $nextptr)
                        (local.get $swap_ptr))
                )
            )

            ;; increment everything and keep looping if necessary
            (local.set $curptr
                (i32.add
                    (local.get $curptr)
                    (i32.const 10)))
            (local.set $nextptr
                (i32.add
                    (local.get $nextptr)
                    (i32.const 10)))
            (br_if $loop
                (i32.lt_u
                    (local.get $nextptr)
                    (local.get $endptr)))
        )
    )

    ;; Parse a number from the given memory offset as an i32
    (func $i32.parse_from_memory (param $offset i32) (result (;value;) i32 (;bytes read;) i32)
        (local $current_offset i32)
        (local $accum i32)
        (local $consumed i32 (; the total number of bytes consumed;))
        
        ;; $current_offset = $offset
        local.get $offset
        local.set $current_offset

        (block $outer
            (loop $loop
                ;; get the next digit in memory
                local.get $current_offset
                call $i32.parse_byte_as_decimal

                ;; at this point, top-1 is the value, top is how many bytes were consumed

                ;; if the number of bytes consumed was zero, we're done.
                i32.const 0
                i32.eq
                br_if $outer

                ;; at this point, top is the value parsed between 0 and 9 inclusive, as an i32

                ;; $accum = $accum * 10 + $digit
                local.get $accum
                i32.const 10
                i32.mul
                i32.add
                local.set $accum

                ;; $current_offset += 1
                local.get $current_offset
                i32.const 1
                i32.add
                local.set $current_offset

                ;; keep looping
                br $loop
            )
        )

        ;; $consumed = $current_offset - $offset
        local.get $current_offset
        local.get $offset
        i32.sub
        local.set $consumed

        ;; return our two values
        local.get $accum
        local.get $consumed
    )

    ;; Parse a single byte of memory as an i32, returning the value and the number of bytes read
    ;; note that the number of bytes read is either 1 or 0, so number of bytes read can also
    ;; be interpreted as whether the function succeeded or failed to find a number at the given offset
    (func $i32.parse_byte_as_decimal (param $offset i32) (result (;value;) i32 (;bytes read;) i32)
        (local $parsed i32 (; the value that was parsed ;))
        (local $success i32 (; whether the value is actually a 0-9 digit ;))

        ;; ascii "0" is decimal 48, hex 0x30
        ;; so normalize the byte we received by subtracting that
        local.get $offset
        i32.load8_u
        i32.const 0x30
        i32.sub
        local.set $parsed
        
        ;; is it greater than or equal to 0? (wait, there's no gte instruction?)
        ;; (leave the result on the stack)
        local.get $parsed
        i32.const -1
        i32.gt_s

        ;; is it less than 10?
        ;; (leave the result on the stack)
        local.get $parsed
        i32.const 10
        i32.lt_s

        ;; top-1: is it greater than or equal to zero
        ;; top: is it less than 10
        ;; so we can and those two together.
        i32.and
        local.set $success

        ;; The parsed value, or 0 if a value couldn't be parsed
        ;;
        ;; this is just being kind. We could just return the weird normalized
        ;; value if it isn't between 0-9, and expect the caller to actually use
        ;; the "how many bytes were read/success" result to know whether it's
        ;; meaningful or not.
        ;;
        ;; if we were doing that, this would be as simple as
        ;;   local.get $parsed
        ;;
        ;; but I'm getting fancy. `select` looks at top and returns top-2 if it
        ;; is true or top-1 if it is false, so we can normalize our parsed value
        ;; pretty easily.
        local.get $parsed
        i32.const 0
        local.get $success
        select

        ;; How many bytes were read
        local.get $success
    )

    ;; Parse a number from the given memory offset as an i64
    (func $i64.parse_from_memory (param $offset i32) (result (;value;) i64 (;bytes read;) i32)
        (local $current_offset i32)
        (local $accum i64)
        (local $consumed i32 (; the total number of bytes consumed;))
        
        ;; $current_offset = $offset
        local.get $offset
        local.set $current_offset

        (block $outer
            (loop $loop
                ;; get the next digit in memory
                local.get $current_offset
                call $i32.parse_byte_as_decimal

                ;; at this point, top-1 is the value, top is how many bytes were consumed

                ;; if the number of bytes consumed was zero, we're done.
                i32.const 0
                i32.eq
                br_if $outer

                ;; at this point, top is the value parsed between 0 and 9 inclusive, as an i32
                i64.extend_i32_u

                ;; $accum = $accum * 10 + $digit
                local.get $accum
                i64.const 10
                i64.mul
                i64.add
                local.set $accum

                ;; $current_offset += 1
                local.get $current_offset
                i32.const 1
                i32.add
                local.set $current_offset

                ;; keep looping
                br $loop
            )
        )

        ;; $consumed = $current_offset - $offset
        local.get $current_offset
        local.get $offset
        i32.sub
        local.set $consumed

        ;; return our two values
        local.get $accum
        local.get $consumed
    )

    ;; the pointer of the next allocation
    (global $alloc.offset (mut i32) (i32.const 32))
    (func $alloc (param $size i32) (result (;pointer;) i32)
        (local $this_alloc_ptr i32)
        (local $next_alloc_ptr i32)
        (local $current_capacity i32)

        ;; If the requested size is more than a 64k page, fail.
        local.get $size
        i32.const 65536
        i32.gt_u
        (if
            (then
                i32.const 0x01
                call $dbg.panic
            )
        )

        ;; calculate the current ptr and the next ptr
        global.get $alloc.offset
        local.tee $this_alloc_ptr
        local.get $size
        i32.add
        local.set $next_alloc_ptr
        
        ;; If this allocation extends into a page of memory we haven't reserved
        ;; we need to reserve more memory
        memory.size
        i32.const 65536
        i32.mul
        local.set $current_capacity

        local.get $next_alloc_ptr
        local.get $current_capacity
        i32.gt_u
        (if
            (then
                i32.const 1
                memory.grow

                ;; if memory couldn't grow, panic
                i32.const -1
                i32.eq
                (if
                    (then
                        i32.const 0x02
                        call $dbg.panic
                    )
                )
            )
        )

        ;; store the ptr to the next allocation
        local.get $next_alloc_ptr
        global.set $alloc.offset

        ;; and return the current pointer
        local.get $this_alloc_ptr
    )

    (func $free (param $size i32)
        ;; Haha no. Let's just let memory live forever.
    )

    ;; vec: a vector where the elements are of arbitrary length
    ;;
    ;; layout is:
    ;; * i32: current length
    ;; * i32: reserved length (not length * size)
    ;; * i32: element size
    ;; * i32: pointer to the data
    (func $vec.new (param $element_size i32) (result (;pointer;) i32)
        (local $addr i32)
        (local $reserved_size i32)
        (local $buffer i32)

        ;; allocate the header
        i32.const 16 ;; 4 i32s x 4 bytes per i32
        call $alloc
        local.set $addr

        i32.const 2 ;; initial reserved size
        local.set $reserved_size

        ;; Does memory start are zeroed? I'm not sure. Let's store 0 in the
        ;; current size
        local.get $addr
        i32.const 0
        i32.store

        ;; Store the initial reserved size in the second part of the header
        local.get $addr
        i32.const 4 ;; size of an i32; the reserved size count is at offset 1
        i32.add
        local.get $reserved_size
        i32.store

        local.get $addr
        i32.const 8
        i32.add
        local.get $element_size
        i32.store

        ;; reserve the amount of memory we need for the buffer
        local.get $reserved_size
        local.get $element_size
        i32.mul ;; now we have the number of bytes we need to allocate
        call $alloc ;; now we have the ptr to the buffer
        local.set $buffer

        ;; And store the ptr to the buffer in the fourth field (offset 3)
        local.get $addr
        i32.const 12 ;; 3 x size of an i32; offset 3
        i32.add
        local.get $buffer
        i32.store

        ;; and finally, return the addr
        local.get $addr
    )
    (func $i32vec.new (result i32)
        i32.const 4
        call $vec.new
    )

    (func $vec.debug (param $vec i32)
        (local $buffer_len i32)
        ;; mem-debug the header
        (call $dbg.mem
            (local.get $vec)
            (i32.const 16))

        ;; mem-debug the buffer
        (local.set $buffer_len
            (i32.mul
                (call $vec.capacity
                    (local.get $vec))
                (call $vec.element_size
                    (local.get $vec))))
        (call $dbg.mem
            (call $vec.buffer_ptr (local.get $vec))
            (local.get $buffer_len))
    )

    ;; double the buffer allocation
    (func $vec.realloc (param $vec i32)
        (local $oldptr i32)
        (local $newptr i32)
        (local $oldcapacity i32)
        (local $newcapacity i32)
        (local $element_size i32)

        (local.set $oldcapacity
            (call $vec.capacity
                (local.get $vec)))

        (local.set $element_size
            (call $vec.element_size
                (local.get $vec)))

        (local.set $newcapacity
            (i32.mul
                (local.get $oldcapacity)
                (i32.const 2)))

        (local.set $newptr
            (call $alloc
                (i32.mul
                    (local.get $newcapacity)
                    (local.get $element_size))))

        (local.set $oldptr
            (call $vec.buffer_ptr
                (local.get $vec)))

        (memory.copy
            (local.get $newptr)
            (local.get $oldptr)
            (i32.mul
                (local.get $oldcapacity)
                (local.get $element_size)))

        (call $free
            (local.get $oldptr))

        ;; store the new capacity in the 2nd slot
        (i32.store
            (i32.add (local.get $vec) (i32.const 4))
            (local.get $newcapacity))

        ;; store the new ptr in the 4th slot
        (i32.store
            (i32.add (local.get $vec) (i32.const 12))
            (local.get $newptr))
    )

    ;; get the number of items in the vec
    (func $vec.len (param $vec i32) (result i32)
        local.get $vec
        i32.load
    )
    ;; get the reserved capacity of the vec
    (func $vec.capacity (param $vec i32) (result i32)
        local.get $vec
        i32.const 4
        i32.add
        i32.load
    )
    ;; get the element size of the vec
    (func $vec.element_size (param $vec i32) (result i32)
        local.get $vec
        i32.const 8
        i32.add
        i32.load
    )
    ;; get the address of the buffer of the vec
    (func $vec.buffer_ptr (param $vec i32) (result i32)
        local.get $vec
        i32.const 12
        i32.add
        i32.load
    )
    (func $vec.assert_in_bounds (param $vec i32) (param $index i32)
        local.get $vec
        call $vec.len

        local.get $index

        i32.gt_u
        (if
            (then)
            (else
                ;; panic if the length of the vec isn't greater than the index
                i32.const 0x03
                call $dbg.panic
            )
        )
    )
    (func $vec.address_of_index (param $vec i32) (param $index i32) (result i32)
        local.get $vec
        local.get $index
        call $vec.assert_in_bounds

        local.get $vec
        call $vec.buffer_ptr

        (i32.mul
            (local.get $index)
            (call $vec.element_size (local.get $vec)))

        i32.add
    )

    ;; get the address of the given index
    (func $vec.get (param $vec i32) (param $index i32) (result i32)
        local.get $vec
        local.get $index
        call $vec.address_of_index
    )

    ;; get the i32 at the given index
    ;;
    ;; (it's up to you to make sure the element size is 4)
    (func $i32vec.get (param $i32vec i32) (param $index i32) (result i32)
        local.get $i32vec
        local.get $index
        call $vec.get

        i32.load
    )
    ;; set the ptr at the given index
    ;;
    ;; (it's up to you to make sure the element size is 4)
    (func $i32vec.set (param $i32vec i32) (param $index i32) (param $value i32)
        local.get $i32vec
        local.get $index
        call $vec.address_of_index

        local.get $value
        
        i32.store
    )
    ;; push a new value onto the vec
    ;;
    ;; the new value is unitialized; the return is a pointer to the memory to
    ;; use
    (func $vec.push (param $vec i32) (result i32)
        (local $oldlen i32)
        (local $newlen i32)
        (local $buffer_ptr i32)
        (local $element_size i32)

        ;; get the current length
        local.get $vec
        i32.load
        local.tee $oldlen

        ;; add one
        i32.const 1
        i32.add

        ;; store as the new length
        local.set $newlen

        ;; if the new length exceeds the capacity, reallocate.
        (call $vec.capacity (local.get $vec))
        (local.get $newlen)
        i32.lt_u
        (if
            (then
                local.get $vec
                call $vec.realloc
            )
        )

        ;; record the new length
        local.get $vec
        local.get $newlen
        i32.store

        local.get $vec
        local.get $oldlen
        call $vec.get
    )
    ;; push a new ptr onto the vec
    (func $i32vec.push (param $i32vec i32) (param $value i32)
        local.get $i32vec
        call $vec.push

        local.get $value

        i32.store
    )
    ;; free memory created by this vec
    (func $vec.drop (param $vec i32)
        local.get $vec
        call $vec.buffer_ptr
        call $free

        local.get $vec
        call $free
    )
)